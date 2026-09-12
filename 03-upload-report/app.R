library(shiny)

ui <- fluidPage(
  titlePanel("Upload & Report"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "CSV file", accept = ".csv"),
      selectInput("column", "Numeric column", choices = NULL),
      downloadButton("download", "Download summary")
    ),
    mainPanel(
      plotOutput("chart"),
      tableOutput("summary")
    )
  )
)

server <- function(input, output, session) {

  uploaded <- reactive({
    req(input$file)
    data <- read.csv(input$file$datapath)
    # validate() shows the message in the output instead of crashing the app.
    validate(need(any(sapply(data, is.numeric)), "No numeric columns found."))
    data
  })

  numeric_columns <- reactive(names(uploaded())[sapply(uploaded(), is.numeric)])

  # Refill the dropdown whenever a new file arrives.
  observeEvent(uploaded(), {
    updateSelectInput(session, "column", choices = numeric_columns())
  })

  values <- reactive({
    req(input$column %in% numeric_columns())
    uploaded()[[input$column]]
  })

  report <- reactive(data.frame(
    Column  = input$column,
    N       = length(values()),
    Mean    = mean(values()),
    SD      = sd(values()),
    Min     = min(values()),
    Max     = max(values())
  ))

  output$chart <- renderPlot({
    hist(values(), col = "steelblue", border = "white",
         main = "", xlab = input$column, ylab = "Count")
  })

  output$summary <- renderTable(report())

  output$download <- downloadHandler(
    filename = function() paste0("summary-", input$column, ".csv"),
    content  = function(path) write.csv(report(), path, row.names = FALSE)
  )
}

shinyApp(ui, server)
