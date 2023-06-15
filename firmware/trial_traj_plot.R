library(openairmaps)
dplyr::glimpse(traj_data)

# Read in txt file
noaa_data <- read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\hysplit\\traj--bwd-23-04-23-12-1lat_42p83752_lon_-80p30364-hgt_50-24h.csv")
noaa_data$DATE <- as.Date(with(noaa_data, paste(YEAR, MONTH, DAY,sep="-")), "%Y-%m-%d")
dplyr::glimpse(noaa_data)
trial_data = traj_data[c(1:nrow(noaa_data)),]


trial_data$date = noaa_data$DATE
trial_data$year = noaa_data$YEAR
trial_data$month = noaa_data$MONTH
trial_data$day = noaa_data$DAY

trial_data$hour.inc= noaa_data$INC
trial_data$lat = noaa_data$LAT
trial_data$lon = noaa_data$LON
trial_data$pressure = noaa_data$PRESSURE



trajMap(trial_data)