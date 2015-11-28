# Shiny Air 0.0.1
# Homepage: https://github.com/kfet/shiny_air
# Copyright 2015 Kalin Fetvadjiev, Ivaylo Hlebarov
# Licensed under MIT
#
#   Requires the following data files:
#
#       AirBase Data v8 from 1998 to 2012
#           data/AirBase_BG_v8/AirBase_BG_v8_stations.csv
#           data/AirBase_BG_v8/AirBase_BG_v8_statistics.csv
#               Extracted from AirBase v8 for Bulgaria, obtainable from:
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

# Filter by 'day' average group
ses <- ses[ses$statistics_average_group == 'day',]

# Aggregate by year and component (means for each station)
ses_mean_agg <- ses[ses$statistic_shortname == 'Mean',]
ses_mean_agg <- aggregate(ses_mean_agg$statistic_value,
                        by = list(
                            statistics_year=ses_mean_agg$statistics_year,
                            component_caption=ses_mean_agg$component_caption,
                            statistic_shortname=ses_mean_agg$statistic_shortname,
                            measurement_unit=ses_mean_agg$measurement_unit),
                        FUN=mean)

# Aggregate by year and component (max for each station)
ses_max_agg <- ses[ses$statistic_shortname == 'Max',]
ses_max_agg <- aggregate(ses_max_agg$statistic_value,
                          by = list(
                              statistics_year=ses_max_agg$statistics_year,
                              component_caption=ses_max_agg$component_caption,
                              statistic_shortname=ses_max_agg$statistic_shortname,
                              measurement_unit=ses_max_agg$measurement_unit),
                          FUN=max)

ses_agg <- rbind(ses_mean_agg, ses_max_agg)

# Fix the value column name
names(ses_agg)[names(ses_agg) == 'x'] <- 'statistic_value'

shinyServer(
    function(input, output) {
        # Plot the graphic
        output$newGraphic <- renderPlot({
            # Values for the given statistic and component
            agg_stats = ses_agg[ses_agg$statistic_shortname == input$stat,]
            agg_stats = agg_stats[agg_stats$component_caption == input$component,]

            # Read the measurement unit
            measurement_unit = agg_stats[1,]$measurement_unit
            limit = limits[input$component]

            # Calculate range
            value_max = max(max(agg_stats$statistic_value), limit)
            value_min = min(min(agg_stats$statistic_value), limit)
            value_range = value_max - value_min

            # Extend max / min with 10% of range
            value_min = value_min - value_range / 10
            value_max = value_max + value_range / 10

            plot(agg_stats$statistics_year, agg_stats$statistic_value,
                 xlab = "Година", ylab = paste(input$component, "(", measurement_unit, ")"),
                 ylim = c(value_min, value_max),
                 type = "b", col = agg_stats$component_caption, lwd = 3)
            abline(h = limit, lwd = 3, col = "red")
       } )

        # Render the statistic used
        output$newStat <- renderText({input$stat})
    }
)
