.html_report_link <- function(pkg, ver, type) {
    paste0(
        paste0(
            "<a href='",
            .build_report_link(pkg, ver, type),
            "' target='_blank'>",
            pkg,
            "</a>"
        ),
        collapse = ", "
    )
}

.build_report_link <- function(pkg, ver, type) {
    paste0(
        "https://bioconductor.org/checkResults/",
        ver,
        "/",
        type,
        "-LATEST/",
        pkg,
        "/"
    )
}

depReportServer <- function(id, package_name, biocver, bioctype) {
    moduleServer(
        id,
        function(input, output, session) {
            output$dependency_ui <- renderUI({
                if (is.null(package_name())) {
                    div(
                        style =
                            "padding: 20px; text-align: center; color: #888;",
                        h4(
                            paste(
                                "Select a package from the 'Badges' tab view",
                                "its reverse dependencies."
                            )
                        )
                    )
                } else {
                    type <- .get_pkgTypes_from_URL(package_name(), biocver())
                    div(
                        style = "padding: 20px;",
                        h4(
                            HTML(
                                paste(
                                    "Reverse Dependencies for:",
                                    .html_report_link(
                                        package_name(),
                                        biocver(),
                                        type
                                    )
                                )
                            )
                        ),
                        DT::dataTableOutput(
                            session$ns("dependency_table")
                        )
                    )
                }
            })
            dependency_data <- reactive({
                req(package_name(), biocver())
                showNotification(
                    paste("Fetching dependencies for:", package_name()),
                    type = "message"
                )
                deps <- tryCatch(
                    {
                        BiocPkgTools::pkgBiocRevDeps(
                            pkg = package_name(),
                            version = biocver(),
                            pkgType = bioctype(),
                            which = "most",
                            only.bioc = TRUE
                        )
                    },
                    error = function(e) {
                        showNotification(
                            paste(
                                "Error fetching dependencies:",
                                conditionMessage(e)
                            ),
                            type = "error"
                        )
                        return(NULL)
                    }
                )
                if (is.null(deps) || !length(deps)) {
                    showNotification(
                        "No dependency data found for this package.",
                        type = "warning"
                    )
                    return(NULL)
                }
                totals <- lengths(deps)
                revdepslinks <- vapply(
                    deps,
                    function(p) {
                        if (!length(p))
                            return("")
                        type <- .get_pkgTypes_from_URL(p, biocver())
                        .html_report_link(p, biocver(), type)
                    },
                    character(1L)
                )
                deps_df <- cbind.data.frame(
                    DependencyType = c(
                        "Depends on Me",
                        "Imports Me",
                        "LinkingTo Me",
                        "Suggests Me"
                    ),
                    Packages = revdepslinks,
                    Total = totals
                )
                return(deps_df)
            })

            output$dependency_table <- DT::renderDataTable({
                req(dependency_data())
                DT::datatable(
                    dependency_data(),
                    rownames = FALSE,
                    escape = FALSE,
                    options = list(
                        pageLength = 10,
                        dom = "t"
                    )
                )
            })
        }
    )
}

depReportUI <- function(id) {
    ns <- NS(id)
    uiOutput(
        ns("dependency_ui")
    )
}
