bioctypeServer <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            reactive(input$bioctype)
        }
    )
}

bioctypeUI <- function(id, label = "bioctype") {
    ns <- NS(id)
    tagList(
        checkboxGroupInput(
            inputId = ns("bioctype"),
            label = "Bioconductor package type:",
            choices = c(
                "software",
                "data-experiment",
                "data-annotation",
                "workflows"
            ),
            selected = "software"
        )
    )
}
