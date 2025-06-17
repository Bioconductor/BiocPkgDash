depReportServer <- function(id, package_name, biocver) {
    moduleServer(
        id,
        function(input, output, session) {
            dependency_data <- reactive({
                req(package_name(), biocver())
                showNotification(
                    paste("Fetching dependencies for:", package_name()),
                    type = "message"
                )
                .build_report_link <- function(pkg, ver) {
                    paste0(
                        "https://bioconductor.org/checkResults/",
                        ver,
                        "/bioc-LATEST/",
                        pkg,
                        "/"
                    )
                }
                deps <- tryCatch({
                    BiocPkgTools::pkgBiocRevDeps(
                        pkg = package_name(),
                        version = biocver(),
                        pkgType = "software",
                        which = "most",
                        only.bioc = TRUE
                    )
                }, error = function(e) {
                    showNotification(
                        paste(
                            "Error fetching dependencies:", conditionMessage(e)
                        ),
                        type = "error"
                    )
                    return(NULL)
                })
                if (is.null(deps) || !length(deps)) {
                    showNotification(
                        "No dependency data found for this package.",
                        type = "warning"
                    )
                    return(NULL)
                }
                deps_df <- cbind.data.frame(
                    DependencyType =
                        c("Depends", "Imports", "LinkingTo", "Suggests"),
                    Packages = vapply(
                        deps,
                        function(p) {
                            if (length(p))
                                paste0(
                                    paste0(
                                        "<a href='",
                                        .build_report_link(p, biocver()),
                                        "' target='_blank'>", p, "</a>"
                                    ),
                                    collapse = ", "
                                )
                            else
                                ""
                        },
                        character(1L)
                    )
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
                        dom = "ftp"
                    )
                )
            })
        }
    )
}

depReportUI <- function(id) {
    ns <- NS(id)
    DT::dataTableOutput(ns("dependency_table"))
}
