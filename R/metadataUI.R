metadataUI <- function(id, label = "metadata") {
    ns <- NS(id)
    tagList(
        DT::dataTableOutput(ns("metadata_out"))
    )
}
