# Launch the ShinyApp (Do not remove this comment)

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

if (!requireNamespace("remotes", quietly = TRUE))
    install.packages("remotes")

options(repos = BiocManager::repositories())

if (!requireNamespace("BiocPkgDash", quietly = TRUE))
    BiocManager::install("Bioconductor/BiocPkgDash")

BiocPkgDash::BiocPkgDash(email = "maintainer@bioconductor.org") # add parameters here (if any)
