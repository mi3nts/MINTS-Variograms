library(openair)
library(dplyr)
library(openairmaps)
library(latex2exp)

#### Datasets used are: 
#### a) Joappa Variogram data for the month of Jan 2023, 
#### b) Joappa PM data for Jan 2023, 

wind_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Wind_TPH_Range.csv")

#Creating an array with time scales for various PM size fraction
pm_range = c(wind_data$pm0.1,wind_data$pm0.3,wind_data$pm0.5,
             wind_data$pm1.0,wind_data$pm2.5,wind_data$pm5.0,
             wind_data$pm10.0)
pm_range = na.omit(pm_range)

#Specifying the upper limit and lower limit on the color bar using the pm_range aka all the time scales
lim = quantile(pm_range, c(0.05,.95))

# For simplicity, I am copying the data into the variable specified in the package, 
# in order to avoid errors, because the data is in tibble format.
# We can create our own tibble, but make sure all the columns in the tibble are
# following the same data type as mentioned in the example:


mydata_sample$date = as.POSIXct(wind_data$RollingTime,format="%Y-%m-%dT%H:%M:%S")
mydata_sample$pm2.5 = round(wind_data$pm2.5,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection
mydata_sample$lat = c(32.715)
mydata_sample$lon = c(-96.748)
mydata_sample$Temperature = wind_data$MeanTemperature
mydata_sample$Pressure = wind_data$MeanPressure
mydata_sample$Humidity = wind_data$MeanHumidity

