# Launch the ShinyApp (Do not remove this comment)

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

options(repos = BiocManager::repositories())

if (!requireNamespace("BiocPkgDash", quietly = TRUE))
    BiocManager::install("Bioconductor/BiocPkgDash")

BiocPkgDash::BiocPkgDash() # add parameters here (if any)
