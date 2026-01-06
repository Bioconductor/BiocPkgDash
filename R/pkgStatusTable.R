.get_pkgTypes_from_URL <-
    function(packages, version) {
        repos <- BiocManager:::.repositories_bioc(version)
        pkgsdb <- utils::available.packages(repos = repos)
        pkgTypes <- structure(rep("bioc", length(packages)), names = packages)
        pkgs_in_db <- rownames(pkgsdb) %in% packages
        repo_urls <- pkgsdb[pkgs_in_db, "Repository"]
        tail_urls <- vapply(
            strsplit(repo_urls, paste0(version, "/")),
            "[",
            character(1L),
            2L
        )
        biocType <- gsub("/src/contrib", "", tail_urls)
        pkgTypes[names(biocType)] <- gsub("/", "-", biocType, fixed = TRUE)
        pkgsnot <- !packages %in% names(biocType)
        npkgs <- paste(packages[pkgsnot], collapse = ", ")
        if (any(pkgsnot))
            warning(
                "Bioconductor package category not found for: ",
                npkgs,
                call. = FALSE
            )
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
#' @inheritParams biocapi::maintainerPkgs
#'
#' @param status `character()` The status of the builders to include in the
#'   function. These values are obtained from the `result` column in
#'   [biocapi::buildreport()]. The default is all:
#'   `c("OK", "WARNINGS", "ERROR", "TIMEOUT", "skipped")`.
#'
#' @param stage `character()` vector of the Bioconductor Build System (BBS)
#'   stages to include. These values are obtained from the `stage`
#'   [biocapi::buildreport()]. The default is all stages:
#'   `c("install", "buildsrc", "checksrc", "buildbin")`.
#'
#' @param data `tibble()` / `data.frame()` of maintained packages. This is used
#'   internally to avoid repeated calls to the [biocapi::maintainerPkgs()]
#'   function.
#'
#' @returns A `tibble()` / `data.frame()` with the package build statuses for
#'   the given `data` input.
#'
#' @importFrom biocapi buildstatus maintainerPkgs
#'
#' @examplesIf interactive()
#' data <- biocapi::maintainerPkgs(
#'     main = "maintainer@bioconductor.org"
#' )
#' pkgStatusTable(data = data)
#' @export
pkgStatusTable <- function(
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
    ) |>
        dplyr::rename(
            Hostname = .data[["node"]],
            Stage = .data[["stage"]],
            Status = .data[["result"]]
        )

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
