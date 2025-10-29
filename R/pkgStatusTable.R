#' @importFrom biocapi biocpkgtype
.get_pkgTypes_from_API <-
    function(packages, version) {
        pkgTypes <- biocpkgstypes(pkg = packages, version = version)
        naornull <- is.na(pkgTypes) | is.null(pkgTypes)
        if (any(naornull)) {
            warning(
                "Bioconductor package category not found for: ",
                paste(packages[naornull], collapse = ", "),
                call. = FALSE
            )
            pkgTypes[naornull] <- "bioc"
        }
        pkgTypes
    }

.get_codecov_from_BugReports <- function(bugreports, package) {
    stopifnot(
        identical(length(bugreports), length(package))
    )
    names(bugreports) <- package
    Map(
        function(bugreplink, pkg) {
            expl <- strsplit(bugreplink, "/")[[1L]]
            owner <- expl[which(expl == "issues") - 2L]
            if (is.na(bugreplink))
                owner <- "Bioconductor"
            app_url <- paste0(
                .CODECOV_APP_URL, owner, "/", pkg
            )
            .build_codecov_badge(app_url, owner, pkg)
        },
        bugreplink = bugreports,
        pkg = package
    ) |>
        as.character()
}

.build_html_status <- function() {
    builder_url <- paste0(
        "https://bioconductor.org/checkResults/",
        "{{version}}/{{pkgType}}-LATEST/{{Package}}/",
        "{{Hostname}}-{{Stage}}.html"
    )
    paste0(
        '<a href=',
        dQuote(builder_url, q = FALSE),
        ' target="_blank">',
        '<span class="icon-status-{{Status}}">{{{svgIcon}}} {{Status}}</span>',
        '</a>'
    )
}

#' Build a table of package build statuses
#'
#' @description This function builds a table of package build statuses for a
#'  given Bioconductor version and email combination. It is mainly used for the
#'  Bioconductor Package Dashboard.
#'
#' @details Note that binary build stages for the Linux builders are marked as
#'   `skipped` in the table. This is because the binaries are built on GitHub
#'   Actions and their result are not included in the Bioconductor Build System
#'   (BBS) database. Provide the `data` argument to avoid recomputing the
#'   list of maintained packages for a given email and Bioconductor version.
#'   Annotation packages are not included in the table because they are not
#'   built regularly by the BBS.
#'
#' @param data `tibble()` / `data.frame()` A table of maintained packages.
#'   This is used internally to avoid repeated calls to the
#'   [BiocPkgTools::biocMaintained()] function.
#'
#' @param status `character()` The status of the builders to include in the
#'   table. These values are obtained from the `result` column in
#'   [BiocPkgTools::biocBuildReport()]. The default is all:
#'   `c("OK", "WARNINGS", "ERROR", "TIMEOUT", "skipped")`.
#'
#' @param stage `character()` A vector of the Bioconductor Build System (BBS)
#'   stages to include in the plot. These values are obtained from the `stage`
#'   [BiocPkgTools::biocBuildReport()]. The default is all stages:
#'   `c("install", "buildsrc", "checksrc", "buildbin")`.
#'
#' @returns A `tibble()` / `data.frame()` with the package build statuses for
#'   the given `data` input.
#'
#' @examplesIf interactive()
#' data <- BiocPkgTools::biocMaintained("maintainer@bioconductor.org")
#' pkgStatusTable(data)
#' @export
pkgStatusTable <- function(
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

    ## adjust for missing package types
    data <- data[match(names(biocTypes), data[["Package"]]), ]
    data <- dplyr::bind_cols(data, pkgType = biocTypes)
    sdat <-
        BiocPkgTools::biocBuildStatusDB(
            version = version,
            pkgType = pkgType
        )
    biocTypes <- .get_pkgTypes_from_API(data[["Package"]], version)
    names(sdat) <- c("Package", "Hostname", "Stage", "Status")

    lmain <- sdat[["Package"]] %in% data[["Package"]]
    lstage <- sdat[["Stage"]] %in% stage
    lstatus <- sdat[["Status"]] %in% status
    statusPkgs <- sdat[lmain & lstage & lstatus, ]
    if (!length(statusPkgs))
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
    statusPkgs <- tidyr::complete(
        statusPkgs,
        .data[["Package"]],
        .data[["Hostname"]],
        .data[["Stage"]]
    )

    statusPkgs <- dplyr::left_join(
        statusPkgs,
        data[, c("Package", "pkgType")],
        by = c("Package" = "Package")
    )
    statusPkgs[["StageLabel"]] <- factor(
        statusPkgs[["Stage"]],
        levels = c("install", "buildsrc", "checksrc", "buildbin"),
        labels = c(
            "Install",
            "Build Source",
            "Check Source",
            "Build Binary"
        ),
        ordered = TRUE
    )
    glyphSuffix <- factor(
        statusPkgs[["Status"]],
        levels = c("ERROR", "WARNINGS", "TIMEOUT", "OK", "skipped", "NA"),
        labels = c(
            "x-circle",
            "exclamation-circle",
            "clock",
            "check2-circle",
            "dash-circle",
            "question-circle"
        ),
        ordered = FALSE
    )
    glyphSuffix[is.na(glyphSuffix)] <- "question-circle"
    statusPkgs <- dplyr::bind_cols(statusPkgs, glyphSuffix = glyphSuffix)
    statusPkgs[["Status"]][is.na(statusPkgs[["Status"]])] <- "NA"
    statusPkgs[["svgIcon"]] <- vapply(
        statusPkgs[["glyphSuffix"]],
        function(x) as.character(bsicons::bs_icon(x)),
        character(1L)
    )

    build_urls <- apply(
        statusPkgs,
        1L,
        function(x, ver) {
            whisker::whisker.render(
                template = .build_html_status(),
                data = c(as.list(x), version = ver)
            )
        },
        ver = as.character(version)
    )
    statusPkgs[["build_url"]] <- build_urls

    dplyr::select(
        statusPkgs,
        "Package",
        "Hostname",
        "StageLabel",
        "build_url"
    ) |>
        tidyr::pivot_wider(
            names_from = "StageLabel",
            values_from = "build_url",
            values_fn = unique
        )
}
