cardsServer <- function(id, data) {
    moduleServer(
        id,
        function(input, output, session) {
            output$pkg_count <- renderText({
                nrow(data())
            })

            output$dl_count <- renderText({
                all_dls <- vapply(
                    data()[["Package"]],
                    function(pkg) {
                        dl_pkg <- BiocPkgTools::pkgDownloadStats(pkg)
                        dls <- sum(dl_pkg[["Nb_of_distinct_IPs"]])
                        if (!length(dls)) 0 else dls
                    },
                    numeric(1L)
                )
                prettyNum(
                    sum(all_dls),
                    big.mark = ",",
                    scientific = FALSE
                )
            })

            output$dep_count <- renderText({
                total_deps <- vapply(
                    data()[["Package"]],
                    function(pkg) {
                        deps <- BiocPkgTools::pkgBiocDeps(
                            pkg,
                            which = "all"
                        )
                        length(unlist(deps))
                    },
                    numeric(1L)
                )
                prettyNum(
                    sum(total_deps),
                    big.mark = ",",
                    scientific = FALSE
                )
            })
        }
    )
}

cardsUI <- function(id, label = "cards") {
    ns <- NS(id)
    tagList(
        bslib::value_box(
            title = "Total Packages",
            value = textOutput(ns("pkg_count")),
            showcase = bsicons::bs_icon("hash"),
            theme = "primary"
        ),
        bslib::value_box(
            title = "Year-To-Date Downloads",
            value = textOutput(ns("dl_count")),
            showcase = bsicons::bs_icon(
                "cloud-download"
            ),
            theme = "secondary"
        ),
        bslib::value_box(
            title = "Total No. of Dependencies",
            value = textOutput(ns("dep_count")),
            showcase = bsicons::bs_icon("collection"),
            theme = "warning"
        )
    )
}
