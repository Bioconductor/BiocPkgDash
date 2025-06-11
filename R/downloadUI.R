## downloadUI function to create UI for downloading data
downloadUI <- function(id, label = "download") {
    ns <- NS(id)
    downloadButton(
        outputId = ns("btnSend"),
        label = "Download HTML"
    )
}
