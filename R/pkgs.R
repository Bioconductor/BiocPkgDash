pkgsServer <- function(id, reset_signal, populate_signal) {
    moduleServer(
        id,
        function(input, output, session) {
            packages <- reactiveVal(character(0L))
            observeEvent(
                input$submit_pkgs,
                {
                    if (nzchar(input$packages)) {
                        pkgs <- strsplit(input$packages, ",\\s*")[[1]]
                        parsed_pkgs <- Filter(nzchar, pkgs)
                    } else {
                        parsed_pkgs <- character(0L)
                    }
                    packages(parsed_pkgs)
                }
            )
            observeEvent(
                reset_signal(),
                {
                    updateTextAreaInput(
                        session = session,
                        inputId = "packages",
                        value = ""
                    )
                    packages(character(0L))
                }
            )
            observeEvent(
                populate_signal(),
                {
                    pkgs <- populate_signal()
                    updateTextAreaInput(
                        session = session,
                        inputId = "packages",
                        value = paste(pkgs, collapse = ", ")
                    )
                },
                ignoreInit = TRUE
            )
            return(packages)
        }
    )
}

pkgsUI <- function(id, label = "packages") {
    ns <- NS(id)
    tagList(
        textAreaInput(
            inputId = ns("packages"),
            label = "Enter package names:",
            value = "",
            placeholder = "e.g., BiocGenerics, BiocStyle, BiocBaseUtils, ...",
            rows = 4,
            width = "100%"
        ),
        actionButton(
            inputId = ns("submit_pkgs"),
            label = "Submit",
            class = "btn-primary"
        )
    )
}
