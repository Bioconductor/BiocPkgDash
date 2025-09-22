.BIOC_PKG_STATUSES <- c("OK", "WARNINGS", "ERROR", "TIMEOUT", "skipped", "NA")

#' A Summary Plot for Package Statuses
#'
#' This function generates a stacked bar plot of package statuses for
#' a given Bioconductor version and email combination. It is mainly used
#' for the Bioconductor Package Dashboard.
#'
#' @details Note that binary build stages for the Linux builders are not
#'   included in the plot. This is because the binaries are built on GitHub
#'   Actions and their result are not included in the Bioconductor Build System
#'   (BBS) database.
#'
#' @param data `tibble()` / `data.frame()` A data frame of maintained packages.
#'   This is used internally to avoid repeated calls to the
#'   [BiocPkgTools::biocMaintained()] function.
#'
#' @param status `character()` A vector of `INSTALL`, `build` and `check`
#'   statuses to include in the plot. These values are obtained from the
#'   `result` column in `BiocPkgTools::biocBuildReport()`. The default is all:
#'   `c("OK", "WARNINGS", "ERROR", "TIMEOUT", "skipped")`.
#'
#' @param stage `character()` A vector of the Bioconductor Build System (BBS)
#'   stages to include in the plot. These values are obtained from the `stage`
#'   `BiocPkgTools::biocBuildReport()`. The default is all stages:
#'   `c("install", "buildsrc", "checksrc", "buildbin")`.
#'
#' @importFrom BiocPkgTools biocMaintained
#' @importFrom ggplot2 ggplot aes geom_col facet_grid coord_flip
#'   scale_fill_manual ggtitle theme element_blank
#' @importFrom dplyr full_join mutate count .data
#' @importFrom tidyr complete
#' @importFrom plotly ggplotly
#'
#' @returns An interactive `ggplotly` object.
#'
#' @examplesIf interactive()
#' data <- BiocPkgTools::biocMaintained("maintainer@bioconductor.org")
#' pkgStatusPlot(data)
#' @export
pkgStatusPlot <- function(
    data = NULL,
    status = c("OK", "WARNINGS", "ERROR", "TIMEOUT", "skipped"),
    stage = c("install", "buildsrc", "checksrc", "buildbin")
) {
    if (missing(data))
        stop("Argument 'data' from 'biocMaintained()' is required.")
    status <- match.arg(status, several.ok = TRUE)
    stage <- match.arg(stage, several.ok = TRUE)

    pkgType <- attr(data, "pkgType")
    version <- attr(data, "version")

    pkg_type_map <- tibble::tibble(
        Package = data[["Package"]],
        PkgType = .get_pkgTypes_from_URL(data[["Package"]], version)
    )

    sdat <-
        BiocPkgTools::biocBuildStatusDB(
            version = version,
            pkgType = pkgType
        )
    names(sdat) <- c("Package", "Hostname", "Stage", "Status")

    lmain <- sdat[["Package"]] %in% data[["Package"]]
    lstage <- sdat[["Stage"]] %in% stage
    lstatus <- sdat[["Status"]] %in% status
    statusPkgs <- sdat[lmain & lstage & lstatus, ]
    if (!nrow(statusPkgs))
        stop("No packages found with specified maintainer.")

    statusPkgs <- dplyr::left_join(
        statusPkgs,
        pkg_type_map,
        by = "Package"
    )
    statusPkgs[["Stage"]] <- factor(
        statusPkgs[["Stage"]],
        levels = c("install", "buildsrc", "checksrc", "buildbin"),
        ordered = TRUE
    )
    statusPkgs[["Status"]] <- factor(
        statusPkgs[["Status"]],
        levels = .BIOC_PKG_STATUSES,
        ordered = TRUE
    )
    statusPkgs <- complete(
        statusPkgs,
        .data[["Package"]],
        .data[["Hostname"]],
        .data[["Stage"]]
    )
    statusPkgs <- full_join(
        statusPkgs,
        count(
            statusPkgs,
            .data[["Hostname"]],
            .data[["Stage"]],
            .data[["Status"]]
        ),
        by = c("Hostname", "Stage", "Status")
    )
    statusPkgs <- mutate(statusPkgs, Packages = 1)

    statusPkgs <- mutate(
        statusPkgs,
        url = ifelse(
            !is.na(.data[["Status"]]),
            paste0(
                "https://bioconductor.org/checkResults/", version, "/",
                .data[["PkgType"]], "-LATEST/", .data[["Package"]], "/",
                .data[["Hostname"]], "-", .data[["Stage"]], ".html"
            ),
            NA_character_
        )
    )

    cat_colors <-
        c('darkgreen', 'darkorange', 'darkred', 'purple', 'black', 'grey')
    names(cat_colors) <- .BIOC_PKG_STATUSES

    p <- ggplot(
        statusPkgs,
        aes(
            x = .data[["Hostname"]],
            y = .data[["Packages"]],
            label = .data[["Package"]],
            tooltip = .data[["n"]],
            customdata = .data[["url"]]
        )
    ) +
        geom_col(aes(fill = .data[["Status"]])) +
        facet_grid(. ~ .data[["Stage"]]) +
        coord_flip() +
        scale_fill_manual(values = cat_colors) +
        ggtitle(paste0("Bioconductor version ", as.character(version))) +
        theme(
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank()
        )

    p_interactive <-  ggplotly(
        p, tooltip = c("label", "n", "Status", "Stage", "Hostname")
    )

    htmlwidgets::onRender(
        p_interactive,
        "
        function(el, x) {
            el.on('plotly_click', function(d) {
                // get customdata (URL) from the clicked point
                var url = d.points[0].customdata;
                // if the url exists, open it in a new tab
                if (url) {
                    window.open(url, '_blank');
                }
            });
        }
        "
    )
}
