BiocPkgList <- function(packages, version = BiocManager::version()) {
    if (missing(packages))
        stop("Argument 'packages' is required.")

    pkgs <- BiocPkgTools::biocPkgList(
        version = version, addBiocViewParents = FALSE
    )

    inPkgs <- packages %in% pkgs[["Package"]]
    if (!all(inPkgs)) {
        missings <- packages[!inPkgs]
        warning(
            sprintf(
                "Packages not found in Bioconductor package list: %s",
                paste(missings, collapse = ", ")
            )
        )
    }

    pkgs[inPkgs, drop = FALSE]
}
