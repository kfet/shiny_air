library(shiny)

shinyUI(fluidPage(
    title = "AirBase - pollution in Sofia, Bulgaria",

    theme = "paper/bootstrap.min.css",
    #   theme = "cerulean/bootstrap.min.css",
    #   theme = "darly/bootstrap.min.css",

    # Application title
    titlePanel("AirBase version 8 - pollution in Sofia, Bulgaria"),
    sidebarLayout(
        sidebarPanel(
            h3("Statistic"),
            selectInput("stat", "",
                        c("Mean", "Max"),
                        selected = "Mean"),
            h3("Component"),
            selectInput("component", "",
                        c("PM10", "PM2.5", "NO2", "Pb", "Cd", "CO"),
                        selected = "PM10", selectize = F, size = 7)
        ),
        mainPanel = mainPanel(
            h3("Selected statistic aggregated across all Sofia stations, by year"),
            textOutput("newStat"),
            plotOutput("newGraphic")
        )
    ),
    fluidRow("Code: ", a("Shiny Air on GitHub", href = "https://github.com/kfet/shiny_air")),
    fluidRow("Data sources: ",
             a("AirBase v8, Data for Bulgaria", href = "http://www.eea.europa.eu/data-and-maps/data/airbase-the-european-air-quality-database-8"),
             ", ", a("Air Quolity Standards", href = "http://ec.europa.eu/environment/air/quality/standards.htm"))
))
