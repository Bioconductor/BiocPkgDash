BiocPkgList <- function(packages, version = BiocManager::version()) {
    if (missing(packages))
        stop("Argument 'packages' is required.")

    pkgs <- BiocPkgTools::biocPkgList(
        version = version, addBiocViewParents = FALSE
    )

    inPkgs <- packages %in% pkgs[["Package"]]
    if (!all(inPkgs)) {
        missings <- packages[!inPkgs]
        showNotification(
            sprintf(
                "Packages not found in Bioconductor package list: %s",
                paste(missings, collapse = ", ")
            ),
            type = "warning",
            duration = 10
        )
    }

    filtered <- subset(pkgs, pkgs[["Package"]] %in% packages)
    attr(filtered, "version") <- version
    filtered
}
