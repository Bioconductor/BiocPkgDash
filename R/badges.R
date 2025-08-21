badgesServer <- function(id, data, codecov) {
    moduleServer(
        id,
        function(input, output, session) {
            output$badge_out <- DT::renderDataTable({
                    columns_to_hide <-
                        if (codecov())
                            list(list(targets = 3, visible = FALSE))
                        else
                            list()
                DT::datatable(
                    badgesDF(
                        data = data()
                    ),
                    escape = FALSE,
                    rownames = FALSE,
                    selection = "single",
                    options = list(
                        columnDefs = columns_to_hide,
                        dom = "ftp",
                        pageLength = 20,
                        lengthChange = FALSE,
                        paging = TRUE
                    )
                )
            })
            selected_package <- reactive({
                selected_row <- input$badge_out_rows_selected
                if (length(selected_row))
                    as.character(data()[selected_row, "Package"])
                else
                    NULL
            })
            return(selected_package)
        }
    )
}

badgesUI <- function(id, label = "badges") {
    ns <- NS(id)
    tagList(
        shinybiocloader::withLoader(
            DT::dataTableOutput(ns("badge_out")),
            loader = "biocspin"
        )
    )
}
