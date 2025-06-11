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
                        dl_pkg <- suppressWarnings({
                            BiocPkgTools::pkgDownloadStats(pkg)
                        })
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
