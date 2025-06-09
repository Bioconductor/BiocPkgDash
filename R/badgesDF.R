.SHIELDS_URL <- "http://bioconductor.org/shields/build/"
.CHECK_RESULTS_URL <- "http://bioconductor.org/checkResults/"

filterMaintained <- function(
    data = NULL,
    cols = c(
        "Package",
        "Version",
        "License",
        "NeedsCompilation",
        "Title",
        "hasREADME",
        "hasNEWS",
        "hasINSTALL",
        "hasLICENSE",
        "dependencyCount"
    )
) {
    if (length(cols)) data <- data[, cols]
    if (!nrow(data)) stop("No packages found")
    data[["dependencyCount"]] <- as.integer(data[["dependencyCount"]])
    data
}

badgesDF <- function(data) {
    if (missing(data)) stop("'data' argument is required")
    version <- attr(data, "version")
    pkgTypes <- .get_pkgTypes_from_URL(data[["Package"]], version)
    versions <- c("release", "devel")

    templates <- c(
        paste0(.SHIELDS_URL, versions, "/{{pkgType}}/{{package}}.svg"),
        paste0(
            .CHECK_RESULTS_URL,
            versions,
            "/{{pkgType}}-LATEST/{{package}}"
        )
    )
    names(templates) <- c("rshield", "dshield", "rresult", "dresult")

    ## adjust for missing package types
    data <- data[match(names(pkgTypes), data[["Package"]]), ]
    urldf <- .build_urls_temp(
        packages = data[["Package"]],
        pkgType = pkgTypes,
        templates = templates
    )
    rellink <- .build_html_link(
        urldf,
        "rshield",
        "rresult",
        "release"
    )
    devlink <- .build_html_link(
        urldf,
        "dshield",
        "dresult",
        "devel"
    )

    data.frame(
        Package = data[["Package"]],
        `Bioc-release` = rellink,
        `Bioc-devel` = devlink,
        row.names = NULL,
        check.names = FALSE
    )
}

#' @importFrom whisker whisker.render
.build_urls_temp <- function(packages, pkgType, templates) {
    .data <- data.frame(
        package = packages,
        pkgType = pkgType
    )
    result <- lapply(
        templates,
        function(template, tdata) {
            apply(
                tdata,
                1L,
                function(x) {
                    whisker::whisker.render(
                        template = template,
                        data = x
                    )
                }
            )
        },
        tdata = .data
    )
    cbind.data.frame(package = .data[["package"]], result)
}

renderHTMLfrag <- function(file, data = NULL) {
    version <- BiocManager:::.version_bioc(type = "devel")
    pkgType <- .get_pkgTypes_from_URL(data[["Package"]], version)

    versions <- c("release", "devel")
    templates <- c(
        paste0("https://bioconductor.org/packages/{{package}}"),
        paste0(.SHIELDS_URL, versions, "/{{pkgType}}/{{package}}.svg"),
        paste0(
            .CHECK_RESULTS_URL,
            versions,
            "/{{pkgType}}-LATEST/{{package}}"
        )
    )
    names(templates) <- c("pkgurl", "rshield", "dshield", "rresult", "dresult")
    ## adjust for missing package types
    data <- data[match(names(pkgType), data[["Package"]]), ]
    urldf <- .build_urls_temp(
        packages = data[["Package"]],
        pkgType = pkgType,
        templates = templates
    )

    datalist <- unname(split(urldf, urldf[["package"]]))
    tableTemplate <- c(
        "---",
        "title: Bioconductor Packages",
        "output: html_fragment",
        "---",
        "| Name | Bioc-release | Bioc-devel |",
        "|:-----:|:-----:|:-----:|",
        "{{#packages}}",
        paste0(
            "| [{{{package}}}]({{{pkgurl}}}) |",
            " [![Bioconductor-release Build Status]({{{rshield}}})]({{{rresult}}}) |",
            " [![Bioconductor-devel Build Status]({{{dshield}}})]({{{dresult}}}) |"
        ),
        "{{/packages}}"
    )
    rtext <- whisker::whisker.render(
        template = tableTemplate,
        data = list(packages = datalist)
    )
    mdfile <- tempfile(fileext = ".md")
    writeLines(text = rtext, con = mdfile)
    rmarkdown::render(input = mdfile, output_file = file)
}

.build_html_link <- function(.data, shieldCol, resultCol, version) {
    paste0(
        '<a href=',
        dQuote(.data[[resultCol]]),
        ' target="_blank">',
        '<img src=',
        dQuote(.data[[shieldCol]]),
        ' alt="Bioconductor-',
        version,
        ' Build Status"></a>'
    )
}
