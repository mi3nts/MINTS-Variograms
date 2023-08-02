library(openairmaps)
library(leaflet)
library(tidygeocoder)
library(lubridate)
library(sp)
library(lubridate)

sources = read.csv("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/Annual Emissions Inventory Report (2020).xlsx - Dallas County.csv")
coordinates <- sources %>%
  geocode(Address)

#traj <- importTraj(site = "london", year = 2010)
#head(traj)
library("dplyr")
library("openair")
library("latex2exp")
library(raster)
library("tibble")

# wind_data = read.csv("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/monthly/monthlyWind_TPH_Range.csv")
# wind_data = wind_data %>% filter(RollingTime >= as.POSIXct('2023-01-03 00:00:00.0') & 
#                        RollingTime <= as.POSIXct('2023-01-31 23:59:59.0'))

# pm_range = c(wind_data$pm0.1,wind_data$pm0.3,wind_data$pm0.5,
#              wind_data$pm1.0,wind_data$pm2.5,wind_data$pm5.0,
#              wind_data$pm10.0)
# pm_range = na.omit(pm_range)

# lim = quantile(pm_range, c(0.05,.95))
# #lim = c(min(pm_range),max(pm_range))
# mydata_sample = mydata[c(1:nrow(wind_data)),]
# mydata_sample$pm0.1 = wind_data$pm0.1
# mydata_sample$ws = wind_data$MeanWindSpeed
# mydata_sample$wd = wind_data$MeanWindDirection
# mydata_sample$lat = c(32.715)
# mydata_sample$lon = c(-96.748)
# mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
# rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")

#title = "2023-01-01 - 2023-01-07"
# title = "2023-01-02"
# cols = c("ws","wd")
# mydata_sample = mydata_sample[!rowSums(is.na(mydata_sample[cols])), ]

# make map


traj_csv = read.csv("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/cleaned trajcsv/vardhanjan0130winter2023010200.csv")
parsed_date = as.POSIXct(traj_csv$date)
traj_tibble = as_tibble(traj_csv)
traj_tibble$date = parsed_date


length_custom_column = length(traj_csv$lat)
# traj_data = head(traj_data, n = length_custom_column)
traj_tibble$lat = traj_csv$lat
traj_tibble$lon = traj_csv$lon
traj_tibble$year = traj_csv$year
traj_tibble$month = traj_csv$month
traj_tibble$day = traj_csv$day
traj_tibble$hour = traj_csv$hour
traj_tibble$hour.inc = traj_csv$hour.inc
traj_tibble$height = traj_csv$height
traj_tibble = subset(traj_tibble, select = -c(Timestep.1,Potential_Temperature,Temperature,Relative_Humidity,Mixing_Depth,Mixing_Ratio,Temperature_C,Solar_Radiation,Terrain_Altitude,Rainfall,Specific_Humidity))


# parsed_date = as.POSIXct(traj_csv$date, format="%Y-%m-%d")
parsed_date = as.POSIXct(traj_csv$date)
traj_tibble$date = parsed_date

highway_lat = c(32.71379351677992, 32.705181559895564, 32.747219466295775, 32.66690548349706, 32.6979871429794)
highway_lon = c(-96.7566923885297, -96.74183041169637, -96.74881260359592, -96.71677392679625, -96.82354805077327)
railroad_lat = c(32.714904067912194, 32.73180868017088, 32.71172587750489)
railroad_lon = c(-96.75033979355528, -96.70912082517053, -96.7596750245495)

data <- data.frame(
  Type = c("Highway", "Highway", "Highway", "Highway", "Highway", "Railroad", "Railroad", "Railroad"),
  Latitude = c(highway_lat, railroad_lat),
  Longitude = c(highway_lon, railroad_lon)
)


# my_map <- leaflet(data = data) %>%
#   addTiles()

# highway_icon <- awesomeIcons(
#   icon = "car",
#   markerColor = "blue",
#   library = "fa",
#   iconColor = "white",
# )

# railroad_icon <- awesomeIcons(
#   icon = "train",
#   markerColor = "red",
#   library = "fa",
#   iconColor = "white",
# )

# for (i in 1:nrow(data)) {
#   if (data$Type[i] == "Highway") {
#     icon <- highway_icon
#   } else {
#     icon <- railroad_icon
#   }
  
#   my_map <- my_map %>%
#     addAwesomeMarkers(
#       lng = data$Longitude[i],
#       lat = data$Latitude[i],
#       icon = icon,
#       popup = paste(data$Type[i], "Marker")
#     )
# }

my_map <- trajMap(traj_tibble)

# my_map %>%
# addCircleMarkers(data = coordinates,lng = ~long, lat = ~lat,
#           popup = ~SITE,
#           label = ~SITE)

circle_lat <- 32.715
circle_lon <- -96.748

my_map %>%
addCircleMarkers(
  lng = circle_lon,
  lat = circle_lat,
  radius = 10,
  color = "green",
  popup = "Circle Marker"
)
