codecovServer <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            reactive(input$codecovOff)
        }
    )
}

codecovUI <- function(id, label = "codecov") {
    ns <- NS(id)
    tagList(
        checkboxInput(
            inputId = ns("codecovOff"),
            label = "Hide code coverage",
            value = FALSE
        )
    )
}
