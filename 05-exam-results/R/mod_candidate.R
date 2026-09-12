# One candidate, station by station.

candidate_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("candidate"), "Candidate", candidates),
    plotOutput(ns("chart"), height = "340px"),
    tableOutput(ns("table"))
  )
}

candidate_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    mine <- reactive({
      rows <- station_scores[station_scores$candidate_id == input$candidate, ]
      rows[order(rows$station), ]
    })

    output$chart <- renderPlot({
      par(mar = c(5, 12, 1, 1))   # wide left margin for the station names
      barplot(mine()$percent, horiz = TRUE, names.arg = mine()$station,
              las = 1, cex.names = 0.85, border = NA, xlim = c(0, 100),
              col = ifelse(mine()$passed, "#59A14F", "#E15759"), xlab = "Score (%)")
      abline(v = PASS_MARK, lty = 2)
    })

    output$table <- renderTable(data.frame(
      Station     = mine()$station,
      Score       = sprintf("%d / %d", mine()$score, mine()$max_score),
      `Score %`   = mine()$percent,
      Outcome     = ifelse(mine()$passed, "Pass", "Fail"),
      check.names = FALSE
    ), striped = TRUE)
  })
}
