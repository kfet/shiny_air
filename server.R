#
#   Requires the following data files:
#
#       AirBAse Data v6 from 1998 to 2010
#           data/AirBase_BG_v6/AirBase_BG_v6_stations.csv
#           data/AirBase_BG_v6/AirBase_BG_v6_statistics.csv
#               Extracted from AirBase v6 for Bulgaria, obrainable from:
#               https://open-data.europa.eu/en/data/dataset/Af3mdjj2XhXWgw3OkFVSvA/resource/e8e48f3e-c10c-42fd-ac51-209cefc9c686
#
#       AirBAse Data v7 from 1998 to 2011
#           data/AirBase_BG_v7/AirBase_BG_v7_stations.csv
#           data/AirBase_BG_v7/AirBase_BG_v7_statistics.csv
#               Extracted from AirBase v7 for Bulgaria, obrainable from:
#               http://www.eea.europa.eu/data-and-maps/data/airbase-the-european-air-quality-database-7
#
#       AirBAse Data v8 from 1998 to 2012
#           data/AirBase_BG_v8/AirBase_BG_v8_stations.csv
#           data/AirBase_BG_v8/AirBase_BG_v8_statistics.csv
#               Extracted from AirBase v8 for Bulgaria, obrainable from:
#               http://www.eea.europa.eu/data-and-maps/data/airbase-the-european-air-quality-database-8
#

library(shiny)

#
# Load the Sofia stations data
#
stations <- read.table("data/AirBase_BG_v8/AirBase_BG_v8_stations.csv",
                       header = T, sep = "\t")
sofia_stations <- stations[stations$station_city=='Sofia',]
sofia_codes_list <- sofia_stations$station_european_code

#
# Load the Sofia measurement statistics
#

# Version 6
stats6 <- read.table("data/AirBase_BG_v6/AirBase_BG_v6_statistics.csv",
                    header = T, sep = "\t")
stats6$statistics_year <- as.character(stats6$statistics_year)
stats6$ver <- rep('Version 6',nrow(stats6))

# Version 7
stats7 <- read.table("data/AirBase_BG_v7/AirBase_BG_v7_statistics.csv", header = T, sep = "\t")
stats7$statistics_year <- as.factor(stats7$statistics_year)
stats7$ver <- rep('Version 7',nrow(stats7))

# Version 8
stats8 <- read.table("data/AirBase_BG_v8/AirBase_BG_v8_statistics.csv", header = T, sep = "\t")
stats8$statistics_year <- as.factor(stats8$statistics_year)
stats8$ver <- rep('Version 8',nrow(stats8))

# Merge all versions in a slingle variable
stats <- rbind(stats6, stats7)
stats <- rbind(stats, stats8)

# Select only Sofia station statistics
sofia_stats <- stats[stats$station_european_code %in% sofia_codes_list,]

# Filter on the elements we're interested in
elements <- list('PM10', 'PM2.5', 'NOX', 'NO2', 'Pb', 'Cd', 'CO', 'T-VOC')
ses <- sofia_stats[sofia_stats$component_caption %in% elements, ]

# Select the type of statistic: Max, Mean, P50, P95, P98, ...
ses_mean <- ses[ses$statistic_shortname=='Mean',]

# Aggregate by year, component, and DB version (sum of means of each station)
ses_mean_agg <- aggregate(ses_mean$statistic_value,
                        by = list(
                            statistics_year=ses_mean$statistics_year,
                            component_caption=ses_mean$component_caption,
                            ver=ses_mean$ver,
                            measurement_unit=ses_mean$measurement_unit),
                        FUN=sum)

# Fix the value column name
names(ses_mean_agg)[names(ses_mean_agg) == 'x'] <- 'statistic_value'

shinyServer(
    function(input, output) {
        # Plot the graphic
        output$newGraphic <- renderPlot({
            # Means for the given component, and DB version
            mean_stats = ses_mean_agg[ses_mean_agg$ver == input$ver,]
            mean_stats = mean_stats[mean_stats$component_caption == input$component,]

            # Read the measurement unit
            measurement_unit = mean_stats[1,]$measurement_unit

            plot(mean_stats$statistics_year, mean_stats$statistic_value,
                 xlab = "Year", ylab = paste(input$component, "(", measurement_unit, ")"),
                 type = "b", col = mean_stats$component_caption, lwd = 3)
        })

        # Render the DB version used
        output$newVersion <- renderText({input$ver})
    }
)
