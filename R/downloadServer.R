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
                    BiocPkgDash:::renderHTMLfrag(
                        file = file,
                        data = data()
                    )
                }
            )
        }
    )
}
