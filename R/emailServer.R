emailServer <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            emailValue <- reactiveVal("maintainer@bioconductor.org")
            observe({
                query <- parseQueryString(session$clientData$url_search)
                if (!is.null(query[["email"]])) {
                    updateTextInput(
                        session = session,
                        inputId = "email",
                        value = query[["email"]]
                    )
                    emailValue(query[["email"]])
                }
            })

            observeEvent(
                input$submit,
                {
                    emailValue(input$email)
                }
            )
            return(emailValue)
        }
    )
}
