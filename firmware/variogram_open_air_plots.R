library(openair)
library(dplyr)
library(openairmaps)
library(latex2exp)

#### Datasets used are: 
#### a) Joappa Variogram data for the month of Jan 2023, 
#### b) Joappa PM data for Jan 2023, 
pm_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Joappa_Jan_2023.csv")

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


mydata_sample = mydata[c(1:nrow(wind_data)),]# sub-setting the mydata(the variable specified in the package) variable 
#Copied all the data from the wind_data variable to mydata_sample
mydata_sample$date = as.POSIXct(wind_data$RollingTime,format="%Y-%m-%dT%H:%M:%S")
mydata_sample$pm2.5 = round(wind_data$pm2.5,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection
mydata_sample$lat = c(32.715)
mydata_sample$lon = c(-96.748)
mydata_sample$Temperature = wind_data$MeanTemperature
mydata_sample$Pressure = wind_data$MeanPressure
mydata_sample$Humidity = wind_data$MeanHumidity

pm_data_tibble = as_tibble(pm_data)
pm_data_tibble$date = as.POSIXct(pm_data_tibble$dateTime,format="%Y-%m-%dT%H:%M:%S")
pm_data_tibble = subset(pm_data_tibble, select = -c(dateTime))

pm_data_tibble_min <- timeAverage(pm_data_tibble, avg.time = "min")
calendarPlot(pm_data_tibble_min, pollutant = "pm2_5")

wind_data_joppa = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Joappa_wind_data_Jan_2023.csv")
wind_data_joppa_tibble = as_tibble(wind_data_joppa)
wind_data_joppa_tibble$date = as.POSIXct(wind_data_joppa_tibble$dateTime,format="%Y-%m-%dT%H:%M:%S")
wind_data_joppa_tibble = subset(wind_data_joppa_tibble, select = -c(dateTime))
wind_data_joppa_tibble_min <- timeAverage(wind_data_joppa_tibble, avg.time = "min")

df__pm_wind_combined <- merge( pm_data_tibble_min,wind_data_joppa_tibble_min, by="date", how="left")
df__pm_wind_combined = df__pm_wind_combined %>% 
  rename(
    wd =  windDirectionTrue ,
    ws = windSpeedMetersPerSecond 
  )
calendarPlot(df__pm_wind_combined, pollutant = "pm2_5", annotate = "ws")




rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")


#Added the title
title = "January 2023"

################################### 3 types of Pollution Roses ######################################
pollutionRose(mydata_sample,
              pollutant = "pm2.5",
              type = "Temperature",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5\\ Range(Minutes)$'),
              key.position = "right",par.settings=list(fontsize=list(text=7.5)))

pollutionRose(mydata_sample,
              pollutant = "pm2.5",
              type = "Pressure",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5\\ Range(Minutes)$'),
              key.position = "right",par.settings=list(fontsize=list(text=7.5)))

pollutionRose(mydata_sample,
              pollutant = "pm2.5",
              type = "Humidity",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5\\ Range(Minutes)$'),
              key.position = "right",par.settings=list(fontsize=list(text=7.5)))
