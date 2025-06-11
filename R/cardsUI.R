cardsUI <- function(id, label = "cards") {
    ns <- NS(id)
    tagList(
        bslib::value_box(
            title = "Total Packages",
            value = textOutput(ns("pkg_count")),
            showcase = bsicons::bs_icon("hash"),
            theme = "primary"
        ),
        bslib::value_box(
            title = "Year-To-Date Downloads",
            value = textOutput(ns("dl_count")),
            showcase = bsicons::bs_icon(
                "cloud-download"
            ),
            theme = "secondary"
        ),
        bslib::value_box(
            title = "Total No. of Dependencies",
            value = textOutput(ns("dep_count")),
            showcase = bsicons::bs_icon("collection"),
            theme = "warning"
        )
    )
}
