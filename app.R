# Install required packages if not already installed
# install.packages(c("shiny", "DT"))

library(shiny)
library(DT)

# Define UI
ui <- fluidPage(
  titlePanel("Editable Data Table with DT and Proxy"),
  sidebarLayout(
    sidebarPanel(
      h4("Instructions"),
      p("Double-click any cell in the table to edit it."),
      p("Changes are saved to the data and displayed below.")
    ),
    mainPanel(
      DTOutput("table"),
      h4("Current Data State"),
      verbatimTextOutput("data_output")
    )
  )
)

# Define Server
server <- function(input, output, session) {
  # Reactive value to store the data
  data <- reactiveVal(mtcars)
  
  # Render the initial data table
  output$table <- renderDT({
    datatable(
      data(),
      editable = list(target = "cell", disable = list(columns = c(0))), # Allow editing except for row names
      rownames = TRUE,
      options = list(
        pageLength = 10,
        autoWidth = TRUE
      )
    )
  })
  
  # Proxy to update the table
  proxy <- dataTableProxy("table")
  
  # Observe cell edits
  observeEvent(input$table_cell_edit, {
    info <- input$table_cell_edit
    i <- info$row
    j <- info$col
    v <- info$value
    
    # Update the reactive data
    current_data <- data()
    current_data[i, j] <- as.numeric(v) # Ensure numeric input for mtcars
    data(current_data)
    
    # Update the table via proxy
    replaceData(proxy, data(), resetPaging = FALSE)
  })
  
  # Display the current state of the data
  output$data_output <- renderPrint({
    head(data())
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
