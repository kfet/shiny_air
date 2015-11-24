#
# Data from 1998 to 2010
#   Requires the following data files:
#       data/AirBase_BG_v6/AirBase_BG_v6_stations.csv
#       data/AirBase_BG_v6/AirBase_BG_v6_statistics.csv
#
#       Extracted from AirBase v6 for Bulgaria, obrainable from:
#       https://open-data.europa.eu/en/data/dataset/Af3mdjj2XhXWgw3OkFVSvA/resource/e8e48f3e-c10c-42fd-ac51-209cefc9c686
#

library(shiny)

# Load the Sofia stations data
stations <- read.table("data/AirBase_BG_v6/AirBase_BG_v6_stations.csv",
                       header = T, sep = "\t")
sofia_stations <- stations[stations$station_city=='Sofia',]
sofia_codes_list <- sofia_stations$station_european_code

# Load the Sofia measurement statistics
stats <- read.table("data/AirBase_BG_v6/AirBase_BG_v6_statistics.csv",
                    header = T, sep = "\t")
stats$statistics_year <- as.character(stats$statistics_year)
sofia_stats <- stats[stats$station_european_code %in% sofia_codes_list,]

# Filter on the elements we're interested in
elements <- list('PM10', 'PM2.5', 'NOX', 'NO2', 'Pb', 'Cd', 'CO', 'T-VOC')
ses <- sofia_stats[sofia_stats$component_caption %in% elements, ]

# Max, Mean, P50, P95, P98, ...
ses_mean <- ses[ses$statistic_shortname=='Mean',]

# Aggregate by year and component (sum of means of each station)
ses_mean_agg <- aggregate(ses_mean$statistic_value,
                        by = list(
                            statistics_year=ses_mean$statistics_year,
                            component_caption=ses_mean$component_caption),
                        FUN=sum)
# Fix the value column name
names(ses_mean_agg)[names(ses_mean_agg) == 'x'] <- 'statistic_value'

shinyServer(
    function(input, output) {
        output$newGraphic <- renderPlot({
            # Means for the given component
            mean_stats = ses_mean_agg[ses_mean_agg$component_caption == input$component,]
            plot(mean_stats$statistics_year, mean_stats$statistic_value,
                 xlab = "Year", ylab = input$component,
                 type = "b", col = mean_stats$component_caption, lwd = 3)
        })
    }
)
