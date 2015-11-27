#
#   Requires the following data files:
#
#       AirBAse Data v8 from 1998 to 2012
#           data/AirBase_BG_v8/AirBase_BG_v8_stations.csv
#           data/AirBase_BG_v8/AirBase_BG_v8_statistics.csv
#               Extracted from AirBase v8 for Bulgaria, obrainable from:
#               http://www.eea.europa.eu/data-and-maps/data/airbase-the-european-air-quality-database-8
#

library(shiny)

# Pre-defined list of elements
elements <- c("PM10", "PM2.5", "NO2", "Pb", "Cd", "CO")

# Pre-defined limits on the elements
# see http://ec.europa.eu/environment/air/quality/standards.htm
limits <- c(40, 25, 40, 0.5, 5, 10)
names(limits) <- elements

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
stats <- read.table("data/AirBase_BG_v8/AirBase_BG_v8_statistics.csv", header = T, sep = "\t")

# Select only Sofia station statistics
sofia_stats <- stats[stats$station_european_code %in% sofia_codes_list,]

# Filter on the elements we're interested in
ses <- sofia_stats[sofia_stats$component_caption %in% elements, ]

# Select the type of statistic: Max, Mean, P50, P95, P98, ...
# We now allow the user to chose the statistic to display
ses_mean <- ses

# Aggregate by year, component, and DB version (sum of means of each station)
ses_mean_agg <- aggregate(ses_mean$statistic_value,
                        by = list(
                            statistics_year=ses_mean$statistics_year,
                            component_caption=ses_mean$component_caption,
                            statistic_shortname=ses_mean$statistic_shortname,
                            measurement_unit=ses_mean$measurement_unit),
                        FUN=mean)

# Fix the value column name
names(ses_mean_agg)[names(ses_mean_agg) == 'x'] <- 'statistic_value'

shinyServer(
    function(input, output) {
        # Plot the graphic
        output$newGraphic <- renderPlot({
            # Values for the given statistic and component
            mean_stats = ses_mean_agg[ses_mean_agg$statistic_shortname == input$stat,]
            mean_stats = mean_stats[mean_stats$component_caption == input$component,]

            # Read the measurement unit
            measurement_unit = mean_stats[1,]$measurement_unit
            limit = limits[input$component]

            # Calculate range
            value_max = max(max(mean_stats$statistic_value), limit)
            value_min = min(min(mean_stats$statistic_value), limit)
            value_range = value_max - value_min

            # Extend max / min with 10% of range
            value_min = value_min - value_range / 10
            value_max = value_max + value_range / 10

            plot(mean_stats$statistics_year, mean_stats$statistic_value,
                 xlab = "Year", ylab = paste(input$component, "(", measurement_unit, ")"),
                 ylim = c(value_min, value_max),
                 type = "b", col = mean_stats$component_caption, lwd = 3)
            abline(h = limit, lwd = 3, col = "red")
       } )

        # Render the statistic used
        output$newStat <- renderText({input$stat})
    }
)
