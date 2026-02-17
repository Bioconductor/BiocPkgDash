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
                        paging = TRUE,
                        initComplete = DT::JS(
                            "function(settings, json) {
                                Shiny.setInputValue(
                                    'badges1-badge_render_complete',
                                    Math.random()
                                );
                            }"
                        )
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
            list(
                selected_package = selected_package,
                render_complete = reactive({
                    input$badge_render_complete
                })
            )
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
