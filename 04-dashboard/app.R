library(shiny)
library(bslib)

chicks <- ChickWeight
diets <- levels(chicks$Diet)
palette <- c("#4E79A7", "#59A14F", "#E15759", "#B07AA1")

ui <- page_sidebar(
  title = "Chick Growth Dashboard",
  sidebar = sidebar(
    selectInput("diet", "Diet", c("All diets", diets)),
    actionButton("clear", "Clear selection"),
    helpText("Click a point on the growth chart to follow one chick.")
  ),
  layout_columns(
    fill = FALSE,
    value_box("Chicks", textOutput("n_chicks")),
    value_box("Mean final weight", textOutput("final_weight")),
    value_box("Selected", textOutput("selected"))
  ),
  navset_card_tab(
    nav_panel("Growth", plotOutput("growth", click = "growth_click")),
    nav_panel("Table", tableOutput("table"))
  )
)

server <- function(input, output, session) {

  # reactiveVal holds state that outlives any single input change.
  chosen <- reactiveVal(NULL)

  shown <- reactive({
    if (input$diet == "All diets") chicks else chicks[chicks$Diet == input$diet, ]
  })

  observeEvent(input$growth_click, {
    hit <- nearPoints(shown(), input$growth_click,
                      xvar = "Time", yvar = "weight", maxpoints = 1)
    if (nrow(hit) == 1) chosen(as.character(hit$Chick))
  })

  observeEvent(input$clear, chosen(NULL))
  observeEvent(input$diet, chosen(NULL))

  output$n_chicks <- renderText(length(unique(shown()$Chick)))

  output$final_weight <- renderText({
    last <- shown()[shown()$Time == max(shown()$Time), ]
    sprintf("%.0f g", mean(last$weight))
  })

  output$selected <- renderText(if (is.null(chosen())) "None" else paste("Chick", chosen()))

  output$growth <- renderPlot({
    plot(weight ~ Time, data = shown(), pch = 16, col = palette[shown()$Diet],
         xlab = "Days", ylab = "Weight (g)")

    for (id in unique(shown()$Chick)) {
      one <- shown()[shown()$Chick == id, ]
      lines(one$Time, one$weight, col = adjustcolor(palette[one$Diet[1]], 0.3))
    }

    if (!is.null(chosen())) {
      one <- shown()[shown()$Chick == chosen(), ]
      lines(one$Time, one$weight, col = "black", lwd = 3)
    }
    legend("topleft", paste("Diet", diets), col = palette, pch = 16, bty = "n")
  })

  output$table <- renderTable({
    if (is.null(chosen())) {
      rows <- aggregate(weight ~ Diet, shown(), function(w) c(n = length(w), mean = mean(w)))
      data.frame(Diet = rows$Diet, Rows = rows$weight[, "n"], `Mean weight` = rows$weight[, "mean"],
                 check.names = FALSE)
    } else {
      one <- shown()[shown()$Chick == chosen(), c("Time", "weight", "Diet")]
      setNames(one, c("Day", "Weight (g)", "Diet"))
    }
  })
}

shinyApp(ui, server)
