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
                img(
                    src = "images/bioconductor_logo_rgb_small.png",
                    align = "right",
                    style = "margin-right:10px"
                ),
                h1(id = "big-heading", "Bioconductor Package Dashboard")
            )
        ),
        sidebarLayout(
            sidebarPanel(
                biocverUI("biocver1"),
                bioctypeUI("bioctype1"),
                emailUI("email1"),
                hr(),
                HTML("Download the badge wall as an HTML fragment:"),
                downloadUI("download1"),
                width = 2
            ),
            mainPanel(
                tabsetPanel(
                    tabPanel(
                        "Badges",
                        badgesUI("badges1")
                    ),
                    tabPanel(
                        "Status",
                        statusUI("status1")
                    ),
                    tabPanel(
                        "Data",
                        dataUI("data1")
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
        rv <- reactiveValues(
            maintainedData = NULL
        )

        email <- emailServer("email1")
        biocver <- biocverServer("biocver1")
        bioctype <- bioctypeServer("bioctype1")

        observeEvent(
            list(email(), biocver(), bioctype()),
            {
                req(email(), biocver(), bioctype())
                withProgress(
                    message = "Fetching package data...",
                    detail = "This may take a moment",
                    value = 0.5,
                    {
                        tryCatch(
                            {
                                rv$maintainedData <-
                                    BiocPkgTools::biocMaintained(
                                        main = email(),
                                        version = biocver(),
                                        pkgType = bioctype()
                                    )
                            },
                            error = function(e) {
                                # Return empty dataframe with appropriate structure if error
                                message("Error fetching data: ", e$message)
                                rv$maintainedData <- NULL
                            }
                        )
                    }
                )
            },
            ignoreNULL = FALSE
        )

        getMaintainedData <- reactive({
            rv$maintainedData
        })

        downloadServer("download1", data = getMainainedData)
        badgesServer(
            "badges1",
            version = reactive(biocver()),
            data = getMaintainedData
        )
        statusServer(
            "status1",
            data = getMaintainedData
        )
        dataServer(
            "data1",
            data = getMaintainedData
        )

        # fmt: skip
        output$sessioninfo <- renderPrint({
            if (requireNamespace("sessioninfo", quietly = TRUE))
                utils::capture.output(sessioninfo::session_info())
            else
                utils::capture.output(utils::sessionInfo())
        })
    }

    shinyApp(ui, server)
}
