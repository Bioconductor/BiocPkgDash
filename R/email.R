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
            return(
                list(
                    email = emailValue,
                    submit_email = reactive(input$submit)
                )
            )
        }
    )
}

emailUI <- function(id, label = "email") {
    ns <- NS(id)
    tagList(
        textInput(
            inputId = ns("email"),
            label = "Enter maintainer e-mail:",
            placeholder = "maintainer@bioconductor.org"
        ),
        actionButton(
            inputId = ns("submit"),
            label = "Submit",
            class = "btn-primary"
        )
    )
}
