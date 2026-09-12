library(shiny)

ui <- fluidPage(
  titlePanel("Exam Results Dashboard"),
  tabsetPanel(
    tabPanel("Cohort",    br(), cohort_ui("cohort")),
    tabPanel("Candidate", br(), candidate_ui("candidate"))
  )
)

server <- function(input, output, session) {
  cohort_server("cohort")
  candidate_server("candidate")
}

shinyApp(ui, server)
