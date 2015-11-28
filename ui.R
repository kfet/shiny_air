library(shiny)

shinyUI(fluidPage(
    title = "Наблюдател на околната среда в София",

    theme = "paper/bootstrap.min.css",
    #   theme = "cerulean/bootstrap.min.css",
    #   theme = "darly/bootstrap.min.css",

    # Application title
    titlePanel("Качество на aтмосферния въздух в София, агрегирани данни за 7 станции"),
    sidebarLayout(
        sidebarPanel(
            h3("Вид графика"),
            selectInput("stat", "",
                        c("Mean", "Max"),
                        selected = "Mean"),
            h3("Замърсител"),
            selectInput("component", "",
                        c("PM10", "PM2.5", "NO2", "Pb", "Cd", "CO"),
                        selected = "PM10", selectize = F, size = 7)
        ),
        mainPanel = mainPanel(
            h3("Концентрация на замърсители във въздуха на София по години"),
            "Червената линия показва средната годишна пределно допустима концентрация (ПДК) на замърсителя според Европейското законодателство",
            plotOutput("newGraphic")
        )
    ),
    fluidRow("Code: ", a("Shiny Air on GitHub", href = "https://github.com/kfet/shiny_air")),
    fluidRow("Data sources: ",
             a("AirBase v8, Data for Bulgaria", href = "http://www.eea.europa.eu/data-and-maps/data/airbase-the-european-air-quality-database-8"),
             ", ", a("Air Quality Standards", href = "http://ec.europa.eu/environment/air/quality/standards.htm"))
))
