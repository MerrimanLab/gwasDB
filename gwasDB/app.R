#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(tidyverse)
library(dbplyr)
library(RPostgreSQL)
library(DBI)
library(config)

Sys.setenv(R_CONFIG_ACTIVE = "gwasdb_ro")
conf <- config::get()
con <- dbConnect(odbc::odbc(),
                 driver = conf$driver,
                 database = conf$database,
                 servername = conf$server,
                 port = conf$port,
                 UID = conf$username,
                 PWD = conf$password,
                 timeout = 100)

onStop(function() {
    dbDisconnect(con)
})

study_tbl <- tbl(con, "study") %>% collect()

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("gwasDB"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            h3("Filter Markers"),
            radioButtons("marker_filter",
                         label = "Select by marker or position",
                         choices = list(Position = "position",
                                        Marker = "marker")),
            textInput("probe_id",
                      label = "Probe ID",
                      value = NULL,
                      placeholder = "Enter a valid probe id (not currently implemented"),
            numericInput("marker_chr", value = 1, label = "Chr", width = 150),
            numericInput("marker_start", value = 1, min = 1, label = "Start"),
            numericInput("marker_end", value = 1e5, min = 1, label = "End"),
            hr(),
            h3("Plot Options"),
            radioButtons("facet_options",
                         label = "Facet By",
                         choices = list(None = "none",
                                        Ancestry = "ancestry",
                                        Sex = "sex")),
            selectInput("gwas_study", label = "Gwas Study", choices = study_tbl$name, selected = NULL, multiple = TRUE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            p("Click on a marker name"),
            fluidRow(
                dataTableOutput("marker_tbl_subset")),
            fluidRow(textOutput("probename")),
            fluidRow(
                plotOutput("local_manhattan_plot")
            ))
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    # marker table
    markers_tbl_pos <- reactive(tbl(con, "b37") %>%
                                    filter(chr == !!input$marker_chr,
                                           between(pos,
                                                   !!input$marker_start,
                                                   !!input$marker_end))
    )

    markers_tbl_probe <- reactive({
        mkr_tbl <- tbl(con, "b37") %>%
            select(chr, pos, kgp_id) %>%
            head(0) %>%
            select(kgp_id, chr, pos) %>%
            arrange(pos)

        if (!is.null(input$probe_id)  & input$probe_id != "") {
            mkr_tbl <- tbl(con, "b37") %>%
                select(chr, pos, kgp_id) %>%
                filter(str_detect(kgp_id, !!input$probe_id)) %>%
                select(kgp_id, chr, pos) %>%
                arrange(chr, pos)
        }
        mkr_tbl
    })

    markers_table_pos_or_probe <- reactive({
        if (input$marker_filter == "position") {
            tab <- markers_tbl_pos()
        }else{
            tab <- markers_tbl_probe()
        }
        tab
    })

    output$marker_tbl_subset <- renderDataTable(
        datatable({
            markers_table_pos_or_probe() %>% collect()},
            selection = list(target = "row",
                             mode = "single"),
            rownames = FALSE)
    )

    # watches for the marker table to be clicked and updates everything
    observeEvent(input$markers_table_cell_clicked, {
        cell <- input$markers_table_cell_clicked
        if (!is.null(cell$value)) {
            if (colnames(markers_table_pos_or_probe())[[cell$col + 1]] == "kgp_id") {
                output$cell <- renderPrint(cell)
            }}
    })

    combined_tbl <- tbl(con, "combined")
    # filter the data to be supplied for plotting
    highlight_data <- reactive({
        marker_tbl <- markers_table_pos_or_probe()

        # initially set marker to be *something*
        marker <- "1:10505_A_T"
        if (!is.null(input$markers_cell_clicked$col)) {
            # if the marker table has been clicked, set the marker to be the marker name that was clicked
            if (colnames(marker_tbl)[input$markers_cell_clicked$col + 1] == "kgp_id") {
                marker <- input$markers_cell_clicked$value
                print(marker)
            }
        }

        # pull out the position information about the marker to use for filtering
        marker_detail <- marker_tbl %>% filter(kgp_id == marker) %>% collect()
        out_dat <- combined_tbl %>%
            filter(chr == !!marker_detail$chr[1],
                   between(pos,
                           (!!marker_detail$pos[1] - 10000),
                           (!!marker_detail$pos[1] + 10000))) %>%
            collect()

        out_dat
    })



    # Plot of the intensities for the chosen marker
    output$local_manhattan_plot <- renderPlot({
        dat <- tbl(con, "combined") %>%
            filter(chr == !!input$marker_chr,
                   between(pos, !!input$marker_start, !!input$marker_end)) %>%
            collect()

        # match up selected studies
        selected_study_ids <- study_tbl %>% filter(name %in% input$gwas_study) %>% pull(id)

        if (NROW(dat) == 0) {
            return(NULL)
        }

        if (!is.null(input$gwas_study)) {
            dat <- dat %>% filter(name %in% !!input$gwas_study)
        }
        selected_colour <- input$colour_options
        plot_title <- paste0("chr", input$marker_chr, ":", input$marker_start, "-", input$marker_end)

        # coordinate plotting options
        p <- dat  %>% ggplot(aes(x = pos, y = neg_log10_p)) + geom_point()

        # faceting
        if (input$facet_options == "none") {
            p <- p + facet_wrap(~ name)
        } else {
            facet <- paste0(input$facet_options, "~ name")
            p <- p + facet_grid(facet)
        }

        p <- p + ggtitle(plot_title) + theme_bw()

        p
    })


}

# Run the application
shinyApp(ui = ui, server = server)
