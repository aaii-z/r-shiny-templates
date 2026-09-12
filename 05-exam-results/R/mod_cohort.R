# How the whole cohort did, at one station or all of them.

cohort_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("station"), "Station", c("All stations", stations)),
    h4("Summary"),            tableOutput(ns("summary")),
    h4("Score distribution"), plotOutput(ns("chart"), height = "300px"),
    h4("Flagged questions"),  tableOutput(ns("flagged"))
  )
}

cohort_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    chosen <- reactive({
      if (input$station == "All stations") station_scores
      else station_scores[station_scores$station == input$station, ]
    })

    output$summary <- renderTable(summarise_stations(chosen()), striped = TRUE)

    output$chart <- renderPlot({
      hist(chosen()$percent, breaks = seq(0, 100, by = 5),   # fixed bins, so stations compare
           col = "#4E79A7", border = "white",
           main = "", xlab = "Station score (%)", ylab = "Candidates")
      abline(v = PASS_MARK, col = "#E15759", lwd = 2, lty = 2)
    })

    output$flagged <- renderTable({
      flagged <- flagged_questions
      if (input$station != "All stations")
        flagged <- flagged[flagged$station == input$station, ]

      if (nrow(flagged) == 0) return(data.frame(Result = "Nothing flagged."))

      data.frame(Station = flagged$station, Question = flagged$question_id,
                 `Mean score` = flagged$mean_score, `Facility %` = flagged$facility,
                 check.names = FALSE)
    }, striped = TRUE)
  })
}
