emailServer <- function(id, email = "") {
    moduleServer(
        id,
        function(input, output, session) {
            if (!nzchar(email) && .config_file_exists()) {
                email <- .get_config()[["email"]]
            } else if (nzchar(email) && !.config_file_exists()) {
                .set_config(email = email)
            }
            emailValue <- reactiveVal(email)
            observe({
                query <- parseQueryString(session$clientData$url_search)
                if (!is.null(query[["email"]])) {
                    updateTextInput(
                        session = session,
                        inputId = "email",
                        value = query[["email"]]
                    )
                    emailValue(query[["email"]])
                } else if (nzchar(email)) {
                    updateTextInput(
                        session = session,
                        inputId = "email",
                        value = email
                    )
                    emailValue(email)
                }
            })

            observeEvent(
                input$submit_email,
                {
                    emailValue(input$email)
                    updateQueryString(
                        queryString = paste0("?email=", input$email),
                        mode = "replace",
                        session = session
                    )
                },
                priority = 1
            )
            return(
                list(
                    email = emailValue,
                    submit_email = reactive(input$submit_email)
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
            inputId = ns("submit_email"),
            label = "Submit",
            class = "btn-primary"
        )
    )
}
