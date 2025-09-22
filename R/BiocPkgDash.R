#' @title The Bioconductor Package Dashboard
#'
#' @description A dashboard for Bioconductor package maintainers to monitor the
#'   status of their packages. The key input to the dashboard is the email the
#'   maintainer uses in their package's `DESCRIPTION` file. The dashboard
#'   displays the badge statuses of the package in both the `release` or `devel`
#'   branches of Bioconductor. The status is determined by the results of the
#'   Bioconductor nightly builds. The dashboard also provides a visualization of
#'   the status of the package checks on either the `release` or `devel`
#'   branches of Bioconductor.
#'
#' @param ... Additional parameters to pass to the `shinyApp()` function.
#'
#' @importFrom BiocPkgTools biocMaintained
#' @import shiny
#'
#' @return called for the side effect of initializing a shiny app
#'
#' @examples
#' if (interactive()) {
#'    BiocPkgDash()
#' }
#' @export
BiocPkgDash <- function(...) {
    ui <- fluidPage(
        theme = bslib::bs_theme(bootswatch = "minty"),
        titlePanel(
            windowTitle = "BiocPkgDash",
            title = div(
                style = paste(
                    "display: flex;",
                    "align-items: center;",
                    "justify-content: space-between;"
                ),
                h1(id = "big-heading", "Bioconductor Package Dashboard"),
                img(
                    src = "images/bioconductor_logo_rgb_small.png"
                )
            )
        ),
        sidebarLayout(
            sidebarPanel(
                biocverUI("biocver1"),
                bioctypeUI("bioctype1"),
                emailUI("email1"),
                hr(),
                codecovUI("codecov1"),
                hr(),
                ghTopicUI("topic1"),
                hr(),
                pkgsUI("pkgs1"),
                hr(),
                HTML("Download badge wall:"),
                br(),
                downloadUI("download1"),
                width = 2
            ),
            mainPanel(
                tabsetPanel(
                    tabPanel(
                        "Badges",
                        fluidRow(
                            column(
                                width = 9,
                                badgesUI("badges1")
                            ),
                            column(
                                width = 3,
                                cardsUI("cards1")
                            )
                        )
                    ),
                    tabPanel(
                        "Status",
                        statusUI("status1")
                    ),
                    tabPanel(
                        "Dependencies",
                        depReportUI("report1")
                    ),
                    tabPanel(
                        "Metadata",
                        metadataUI("data1")
                    ),
                    tabPanel(
                        "About",
                        aboutPanel(),
                        value = "about"
                    )
                ),
                width = 10
            )
        )
    )

    server <- function(input, output, session) {
        observe({
            query <- parseQueryString(session$clientData$url_search)
            if (!is.null(query[["email"]])) {
                updateTextInput(
                    session = session,
                    inputId = "email1-email",
                    value = query[["email"]]
                )
            }
        })
        email_data <- emailServer("email1")
        biocver <- biocverServer("biocver1")
        codecov <- codecovServer("codecov1")
        topic_packages <- ghTopicServer("topic1", biocver = biocver)
        bioctype <- bioctypeServer("bioctype1")
        pkgs <- pkgsServer(
            "pkgs1",
            reset_signal = email_data$submit_email,
            populate_signal = topic_packages
        )

        maintainedData <- reactive({
            withProgress(
                message = "Fetching package data...",
                detail = "This may take a moment",
                value = 0.5,
                {
                    result <- tryCatch(
                        {
                            if (length(pkgs()) || length(topic_packages())) {
                                packages <- c(pkgs(), topic_packages())
                                BiocPkgList(
                                    packages = packages,
                                    version = biocver()
                                )
                            } else {
                                req(email_data$email(), biocver(), bioctype())
                                BiocPkgTools::biocMaintained(
                                    main = email_data$email(),
                                    version = biocver(),
                                    pkgType = bioctype()
                                )
                            }
                        },
                        error = function(e) {
                            showNotification(
                                paste(
                                    "An error occurred while fetching ",
                                    "package data:",
                                    e$message
                                ),
                                type = "error",
                                duration = 15
                            )
                            return(NULL)
                        }
                    )
                    validate(
                        need(
                            !is.null(result) && nrow(result),
                            paste(
                                "No packages found for that email or ",
                                "packages provided are not in Bioconductor.",
                                "\nPlease verify the email address is correct",
                                " and is associated with\npackages for the",
                                " selected Bioconductor version and",
                                " package type(s)."
                            )
                        )
                    )
                    return(result)
                }
            )
        })

        clicked_package <- badgesServer(
            "badges1",
            data = maintainedData,
            codecov = codecov
        )
        cardsServer(
            "cards1",
            data = maintainedData
        )

        downloadServer(
            "download1",
            email = email_data$email,
            data = maintainedData
        )
        depReportServer(
            "report1",
            package_name = clicked_package,
            biocver = biocver,
            bioctype = bioctype
        )
        statusServer(
            "status1",
            data = maintainedData
        )
        metadataServer(
            "data1",
            data = maintainedData
        )

        output$sessioninfo <- renderPrint({
            if (requireNamespace("sessioninfo", quietly = TRUE))
                utils::capture.output(sessioninfo::session_info())
            else
                utils::capture.output(utils::sessionInfo())
        })
    }

    shinyApp(ui, server, ...)
}
