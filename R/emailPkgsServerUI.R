emailPkgsServer <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            rv_data <- reactiveVal(
                list(
                    email = "maintainer@bioconductor.org",
                    packages = character(0L)
                )
            )

            observe({
                query <- parseQueryString(session$clientData$url_search)
                if (!is.null(query[['email']])) {
                    updateTextInput(
                        session,
                        "email",
                        value = query[['email']]
                    )
                    current_data <- rv_data()
                    current_data$email <- query[['email']]
                    rv_data(current_data)
                }
            })
            observeEvent(
                input$submit,
                {
                    if (nzchar(input$packages)) {
                        pkgs <- strsplit(input$packages, ",\\s*")[[1]]
                        parsed_pkgs <- Filter(nzchar, pkgs)
                    } else {
                        parsed_pkgs <- character(0L)
                    }
                    rv_data(
                        list(
                            email = input$email,
                            packages = parsed_pkgs
                        )
                    )
                }
            )
            return(rv_data)
        }
    )
}

emailPkgsUI <- function(id) {
    ns <- NS(id)
    tagList(
        textInput(
            inputId = ns("email"),
            label = "Enter maintainer e-mail:",
            placeholder = "maintainer@bioconductor.org"
        ),
        h5("OR"),
        textAreaInput(
            inputId = ns("packages"),
            label = "Enter package names:",
            value = "",
            placeholder = "BiocGenerics, BiocStyle, BiocBaseUtils, ...",
            rows = 6,
            width = "100%"
        ),
        actionButton(
            inputId = ns("submit"),
            label = "Submit",
            class = "btn-primary",
            width = "100%"
        )
    )
}
