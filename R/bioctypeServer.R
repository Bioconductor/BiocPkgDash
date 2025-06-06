bioctypeServer <- function(id) {
    moduleServer(id, function(input, output, session) {
        return(
            reactive(
                {
                    input$bioctype
                }
            )
        )
    })
}
