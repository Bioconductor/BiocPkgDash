metadataServer <- function(id, data) {
    moduleServer(
        id,
        function(input, output, session) {
            output$metadata_out <- DT::renderDataTable({
                DT::datatable(
                    BiocPkgDash:::filterMaintained(
                        data = data()
                    ),
                    rownames = FALSE,
                    options = list(
                        dom = "ftp",
                        pageLength = 20,
                        paging = TRUE
                    )
                )
            })
        }
    )
}

metadataUI <- function(id, label = "metadata") {
    ns <- NS(id)
    tagList(
        shinybiocloader::withLoader(
            DT::dataTableOutput(ns("metadata_out")),
            loader = "biocspin"
        )
    )
}
