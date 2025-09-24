library(tinytest)
library(BiocPkgDash)
library(BiocPkgTools)

data <- biocMaintained(
    main = "maintainer@bioconductor.org",
    pkgType = "software"
)

res <- pkgStatusPlot(data = data)
expect_true(inherits(res, "plotly"))
