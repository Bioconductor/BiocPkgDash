# Launch the ShinyApp (Do not remove this comment)

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

if (!requireNamespace("remotes", quietly = TRUE))
    install.packages("remotes")

options(repos = BiocManager::repositories())

if (!requireNamespace("shinybiocloader", quietly = TRUE))
    BiocManager::install("Bioconductor/shinybiocloader")

if (!requireNamespace("BiocPkgDash", quietly = TRUE))
    BiocManager::install("Bioconductor/BiocPkgDash")

BiocPkgDash::BiocPkgDash() # add parameters here (if any)
