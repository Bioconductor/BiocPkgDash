bioctypeUI <- function(id, label = "bioctype") {
    ns <- NS(id)
    tagList(
        checkboxGroupInput(
            inputId = ns("bioctype"),
            label = "Bioconductor package type:",
            choices = c(
                "software",
                "data-experiment",
                "workflows",
                "data-annotation",
                "books"
            ),
            selected = "software"
        )
    )
}
