downloadServer <- function(id, email, data) {
    moduleServer(
        id,
        function(input, output, session) {
            output$btnSend <- downloadHandler(
                filename = function() {
                    em <- gsub("@", "_", email())
                    em <- gsub("\\.", "_", em)
                    paste0("pkgdash_", em, ".html")
                },
                content = function(file) {
                    renderHTMLfrag(
                        file = file,
                        data = data()
                    )
                }
            )
        }
    )
}

downloadUI <- function(id, label = "download") {
    ns <- NS(id)
    downloadButton(
        outputId = ns("btnSend"),
        label = "Download HTML"
    )
}
