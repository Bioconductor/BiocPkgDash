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
#' @inheritParams pkgStatusTable
#'
#' @importFrom biocapi buildstatus maintainerPkgs
#' @importFrom ggplot2 ggplot aes geom_col facet_grid coord_flip
#'   scale_fill_manual ggtitle theme element_blank
#' @importFrom dplyr full_join mutate count .data
#' @importFrom tidyr complete
#' @importFrom plotly ggplotly
#'
#' @returns An interactive `ggplotly` object.
#'
#' @examplesIf interactive()
#' data <- biocapi::maintainerPkgs(
#'     main = "maintainer@bioconductor.org"
#' )
#' pkgStatusPlot(data = data)
#' @export
pkgStatusPlot <- function(
    main,
    status = c("OK", "WARNINGS", "ERROR", "TIMEOUT", "skipped"),
    stage = c("install", "buildsrc", "checksrc", "buildbin"),
    version = BiocManager::version(),
    pkgType = c("software", "data-experiment", "data-annotation", "workflows"),
    data = NULL
) {
    if (missing(pkgType))
        pkgType <- "software"
    else
        pkgType <- match.arg(pkgType, several.ok = TRUE)

    status <- match.arg(status, several.ok = TRUE)
    stage <- match.arg(stage, several.ok = TRUE)

    if (!is.null(data))
        main <- attr(data, "maintainer")
    else if (missing(main) && is.null(data))
        stop("Argument 'main' or 'data' is required.")

    if (is.null(data))
        data <- biocapi::maintainerPkgs(
            main = main, version = version, pkgType = pkgType
        )

    sdat <- biocapi::buildstatus(
        main = main, version = version, pkgType = pkgType
    )

    sdat <- dplyr::rename(
        sdat,
        Hostname = .data[["node"]],
        Stage = .data[["stage"]],
        Status = .data[["result"]],
        PkgType = .data[["pkgType"]]
    )

    lmain <- sdat[["Package"]] %in% data[["Package"]]
    lstage <- sdat[["Stage"]] %in% stage
    lstatus <- sdat[["Status"]] %in% status
    statusPkgs <- sdat[lmain & lstage & lstatus, ]
    if (!nrow(statusPkgs))
        stop("No packages found with specified maintainer.")

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
