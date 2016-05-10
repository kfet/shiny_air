# Shiny Air

A [Shiny](http://shiny.rstudio.com) application for graphical exploration of the EU AirBase statiscs, specifically pollution in Sofia, Bulgaria.

Demo: [shiny_air](https://kfet.shinyapps.io/shiny_air) at shinyapps.io.

### Overview

The application displays an interactive graphic of the measurments of selected air pollutants, accross a number of years. Masurements are aggregated according to the selected function (mean, max) for the given year, and accros all the stations located in Sofia, Bulgara.

The app imports the data in its native format, as provided in AirBase - The European air quality database. The data needs to be extracted in a predefined directory first.

### Requirements

Install [R](https://cran.r-project.org), and the [Shiny package](http://rstudio.github.io/shiny/tutorial/).

### Installation


#### Extract the data
Download the data for Bulgaria from the AirBase site (choose "Data by country"):
http://www.eea.europa.eu/data-and-maps/data/airbase-the-european-air-quality-database-8

Create a sub-directory "data" (inside the "shiny_air" directory), and extract the downloaded AirBase_BG_v8.zip in sub-directory "AirBase_BG_v8".

The requiried files are:
```
 AirBase_BG_v8_stations.csv
 AirBase_BG_v8_statistics.csv
```


#### Run the app
Change working directory to "shiny_air"
```
 $ cd shiny_air
```

Start the application
```
$ Rscript -e "library(shiny)" -e "runApp()"
```
