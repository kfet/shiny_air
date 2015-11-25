library(shiny)

shinyUI(fluidPage(
    title = "AirBase - pollution in Sofia, Bulgaria",
    # theme = "cerulean/bootstrap.min.css",
    # theme = "darly/bootstrap.min.css",
    theme = "paper/bootstrap.min.css",
    # Application title
    titlePanel("AirBase - pollution in Sofia, Bulgaria"),
    sidebarLayout(
        sidebarPanel(
            h3('AirBase DB Version'),
            selectInput('ver', '',
                        c('Version 6', 'Version 7', 'Version 8'),
                        selected = 'Version 8'),
            h3('Statistic'),
            selectInput('stat', '',
                        c('Max', 'Mean', 'P50', 'P95', 'P98'),
                        selected = 'Mean'),
            h3('Component'),
            selectInput('component', '',
                        c('PM10', 'PM2.5', 'NOX', 'NO2', 'Pb', 'Cd', 'CO', 'T-VOC'),
                        selected = 'PM10', selectize = F, size = 8)
        ),
        mainPanel = mainPanel(
            h3('Sum of the selected statistic of all stations, by year'),
            textOutput('newVersion'), textOutput('newStat'),
            plotOutput('newGraphic')
        )
    )
))
