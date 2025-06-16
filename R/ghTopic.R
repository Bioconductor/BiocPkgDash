ghTopicServer <- function(id, biocver) {
    moduleServer(
        id,
        function(input, output, session) {
            found_packages <- reactiveVal()
            observe({
                query <- parseQueryString(session$clientData$url_search)
                if (!is.null(query[["topic"]])) {
                    updateTextInput(
                        session = session,
                        inputId = "topic",
                        value = query[["topic"]]
                    )
                    packages <- .getBiocPackages(
                        topic = query[["topic"]],
                        version = biocver()
                    )
                    topicValue(packages)
                    pkgsval <- paste(packages, collapse = ", ")
                    updateTextAreaInput(
                        session = session,
                        inputId = "packages",
                        value = pkgsval
                    )
                }
            })
            observeEvent(input$submit_topic, {
                showModal(
                    modalDialog(
                        title = "GitHub Personal Access Token (optional)",
                        passwordInput(
                            session$ns("token_input"), "GitHub PAT:"
                        ),
                        footer = tagList(
                            modalButton("Cancel"),
                            actionButton(
                                session$ns("submit_modal"),
                                "Submit",
                                class = "btn-primary"
                            )
                        )
                    )
                )
            })
            observeEvent(input$submit_modal, {
                removeModal()
                req(input$topic)
                packages <- .getBiocPackages(
                    topic = input$topic,
                    version = biocver(),
                    token = input$token_input
                )
                found_packages(packages)
            })
            return(found_packages)
        }
    )
}

#' @importFrom BiocBaseUtils checkInstalled
.getBiocPackages <- function(topic, version, token = NULL) {
    tryCatch(
        checkInstalled("gh"),
        error = function(e) {
            msg <- conditionMessage(e)
            showNotification(
                paste(
                    "Missing dependencies are not installed; ",
                    msg
                ),
                type = "error",
                duration = 15
            )
        }
    )
    showNotification(
        paste("Searching for topic:", topic),
        type = "message",
        duration = 6
    )
    results <- gh::gh(
        "GET /search/repositories",
        q = paste0("topic:", topic),
        per_page = 100,
        token = token
    )
    repos <- vapply(results$items, `[[`, character(1L), "name")
    pkgsdb <- available.packages(
        repos = BiocManager:::.repositories_bioc(version = version)
    )
    repos[repos %in% rownames(pkgsdb)]
}

ghTopicUI <- function(id, label = "topic") {
    ns <- NS(id)
    tagList(
        textInput(
            inputId = ns("topic"),
            label = "Search packages by GitHub topic:",
            value = "",
            placeholder = "u24ca289073"
        ),
        actionButton(
            inputId = ns("submit_topic"),
            label = "Search",
            class = "btn-primary"
        )
    )
}
