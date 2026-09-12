library(shiny)

ui <- fluidPage(
  titlePanel("Hello Reactive"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Sample size", min = 10, max = 2000, value = 500, step = 10),
      sliderInput("bins", "Bins", min = 5, max = 60, value = 30)
    ),
    mainPanel(
      plotOutput("hist"),
      verbatimTextOutput("summary")
    )
  )
)

server <- function(input, output, session) {

  # A reactive is computed once per change, then reused by both outputs.
  sample <- reactive(rnorm(input$n))

  output$hist <- renderPlot({
    hist(sample(), breaks = input$bins, col = "steelblue", border = "white",
         main = "", xlab = "Value", ylab = "Count")
  })

  output$summary <- renderPrint(summary(sample()))
}

shinyApp(ui, server)
