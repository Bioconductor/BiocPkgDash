
data <- biocMaintained(
    main = "maintainer@bioconductor.org",
    pkgType = "software"
)

res <- pkgStatusTable(data)
expect_true(inherits(res, "tbl_df"))
packages <- res[["Package"]] |> unique()
expect_true(
    packages |>
        length() > 20
)
expect_true(
    all(
        c(
            "Package", "Hostname", "Install",
            "Build Source", "Check Source", "Build Binary"
        ) %in% colnames(res)
    )
)

expect_true(
    "BiocVersion" %in% packages
)
