library(openair)
library(dplyr)
library(openairmaps)
library(latex2exp)
library(lubridate)
#### Datasets used are: 
#### a) Joappa Variogram data for the month of Jan 2023, 
#### b) Joappa PM data for Jan 2023, 
pm_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Joppa_Jan_2023.csv")
pm_data$dateTime = strftime(pm_data$dateTime)
write.csv(pm_data,"D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Joppa_Jan_2023_tz_fixed.csv",row.names  = FALSE)

# pm_data$dateTime = as.POSIXct(pm_data$dateTime,format="%Y-%m-%dT%H:%M:%S")
# attr(pm_data$dateTime, "tzone") <- "America/Chicago"

# pm_data$date = as.Date(pm_data$dateTime)
# unique(pm_data$date)
range_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Wind_TPH_Range.csv")
range_data$RollingTime = as.POSIXct(range_data$RollingTime,format="%Y-%m-%dT%H:%M:%S",tz = "UTC")
range_data$RollingTime = attr(range_data$RollingTime, "tzone") <- "America/Chicago"

range_data$dateTime = strftime(as.POSIXct(range_data$RollingTime,format="%Y-%m-%dT%H:%M:%S"))
write.csv(range_data,"D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Wind_TPH_Range_tz_fixed.csv",row.names = FALSE)
#Creating an array with time scales for various PM size fraction
pm_range = c(range_data$pm0.1,range_data$pm0.3,range_data$pm0.5,
             range_data$pm1.0,range_data$pm2.5,range_data$pm5.0,
             range_data$pm10.0)
pm_range = round(na.omit(pm_range),digits=2)

#Specifying the upper limit and lower limit on the color bar using the pm_range aka all the time scales
lim = quantile(pm_range, c(0.01,.99))

# For simplicity, I am copying the data into the variable specified in the package, 
# in order to avoid errors, because the data is in tibble format.
# We can create our own tibble, but make sure all the columns in the tibble are
# following the same data type as mentioned in the example:
range_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Wind_TPH_Range_tz_fixed.csv")
range_tibble$date = as.POSIXlt()



rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")

#title = "2023-01-01 - 2023-01-07"
title = "01-02-2023"
range_tibble$ws = range_tibble$MeanWindSpeed
range_tibble$wd = range_tibble$MeanWindDirection

polarPlot(range_tibble,pollutant = "pm0.1",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{0}._1$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble,pollutant = "pm0.3",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{0}._3$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble,pollutant = "pm0.5",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{0}._5$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble,pollutant = "pm1.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{1}._0$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble,pollutant = "pm2.5",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{2}._5$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble,pollutant = "pm5.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{5}._0$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble,pollutant = "pm10.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{10}._0$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))



#mydata_sample = mydata[c(1:nrow(wind_data)),]# sub-setting the mydata(the variable specified in the package) variable 
#Copied all the data from the wind_data variable to mydata_sample
# mydata_sample$date = as.POSIXct(wind_data$RollingTime,format="%Y-%m-%dT%H:%M:%S")
# mydata_sample$pm2.5 = round(wind_data$pm2.5,digits = 2)
# mydata_sample$ws = wind_data$MeanWindSpeed
# mydata_sample$wd = wind_data$MeanWindDirection
# mydata_sample$lat = c(32.715)
# mydata_sample$lon = c(-96.748)
# mydata_sample$Temperature = wind_data$MeanTemperature
# mydata_sample$Pressure = wind_data$MeanPressure
# mydata_sample$Humidity = wind_data$MeanHumidity


pm_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Joppa_Jan_2023_tz_fixed_hope.csv")

################# Very IMPORTANT sTEP ####################
df <- pm_data %>%
  mutate(dateTime = ymd_hms(dateTime) %>% force_tz("America/Chicago"))
pm_data_tibble = as_tibble(df)
pm_data_tibble$date = pm_data_tibble$dateTime
################################################
pm_data_tibble = subset(pm_data_tibble, select = -c(dateTime))

################# Very IMPORTANT sTEP ####################
df <- range_data %>%
  mutate(dateTime = ymd_hms(dateTime) %>% force_tz("America/Chicago"))
range_tibble = as_tibble(df)
range_tibble$date = range_tibble$dateTime
################################################

pm_data_tibble_min <- timeAverage(pm_data_tibble, avg.time = "min")
calendarPlot(pm_data_tibble, pollutant = "pm2_5",
             main = TeX('Calendar Plot for $PM_{2.5}$ Concentration                         '),
             key.header = TeX("Concentration (μg/m$^{3}$)"),
             par.settings=list(fontsize=list(text=7.5)))

wind_data_joppa = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Joppa_wind_data_Jan_2023.csv")
wind_data_joppa$dateTime = as.POSIXct(wind_data_joppa$dateTime,format="%Y-%m-%dT%H:%M:%S",tz = "UTC")
attr(wind_data_joppa$dateTime, "tzone") <- "America/Chicago"

df_wind <- wind_data_joppa %>%
  mutate(dateTime = ymd_hms(dateTime) %>% force_tz("America/Chicago"))
wind_data_tibble = as_tibble(df_wind)
wind_data_tibble$ws = wind_data_tibble$windSpeedMetersPerSecond
wind_data_tibble$wd = wind_data_tibble$windDirectionTrue
wind_data_tibble$date = wind_data_tibble$dateTime

df__pm_wind_combined <- merge( pm_data_tibble,wind_data_tibble, by="date", how="left")

calendarPlot(df__pm_wind_combined, pollutant = "pm2_5",, annotate = "ws",
             main = TeX('Calendar Plot for $PM_{2.5}$\\Concentration with Wind Direction                              '),
             key.header = TeX("Concentration (μg/m$^{3}$)"),
             par.settings=list(fontsize=list(text=7.5)))


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
title = "01-02-2023                                        "
#range_tibble = subset(range_tibble, select = -c(X,RollingTime,dateTime))
colnames(range_tibble)[15:19] = c("ws","wd","Temperature","Pressure","Humidity")
################################### 3 types of Pollution Roses ######################################
range_tibble$pm2.5 = round(range_tibble$pm2.5,digits = 2)
pollutionRose(range_tibble,
              pollutant = "pm2.5",
              type = "Temperature",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5$ Measurement Time (Minutes)'),
              key.footer = " ",key.position = "right",par.settings=list(fontsize=list(text=7.5)))

pollutionRose(range_tibble,
              pollutant = "pm2.5",
              type = "Pressure",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5$ Measurement Time (Minutes)'),
              key.footer = " ",key.position = "right",par.settings=list(fontsize=list(text=7.5)))


pollutionRose(range_tibble,
              pollutant = "pm2.5",
              type = "Humidity",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5$ Measurement Time (Minutes)'),
              key.footer = " ",key.position = "right",par.settings=list(fontsize=list(text=7.5)),
              subtitles = subplot_titles)






