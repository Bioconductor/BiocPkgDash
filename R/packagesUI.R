packagesUI <- function(id, label = "packages") {
    ns <- NS(id)
    tagList(
        textAreaInput(
            inputId = ns("packages"),
            label = "Enter package names, separated by commas:",
            value = "",
            placeholder = "BiocGenerics, BiocStyle, BiocBaseUtils, ...",
            rows = 6,
            width = "100%"
        )
    )
}
