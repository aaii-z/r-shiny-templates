library(shiny)

readings <- read.csv("data/airquality.csv")
readings$Month <- month.name[readings$Month]

measures <- c("Ozone", "Temp", "Wind", "Solar.R")

ui <- fluidPage(
  titlePanel("CSV Explorer"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("months", "Months",
                         choices = unique(readings$Month),
                         selected = unique(readings$Month)),
      selectInput("measure", "Measure", measures),
      sliderInput("temp", "Temperature range",
                  min = min(readings$Temp), max = max(readings$Temp),
                  value = range(readings$Temp))
    ),
    mainPanel(
      plotOutput("chart"),
      tableOutput("table")
    )
  )
)

server <- function(input, output, session) {

  # req() stops here (blank output, no error) when nothing is selected.
  filtered <- reactive({
    req(input$months)
    readings[readings$Month %in% input$months &
             readings$Temp >= input$temp[1] &
             readings$Temp <= input$temp[2], ]
  })

  output$chart <- renderPlot({
    values <- filtered()[[input$measure]]
    boxplot(values ~ factor(filtered()$Month, levels = month.name),
            col = "steelblue", border = "grey30",
            main = "", xlab = "", ylab = input$measure)
  })

  output$table <- renderTable(head(filtered()[order(-filtered()$Temp), ], 10))
}

shinyApp(ui, server)
