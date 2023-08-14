library(openair)
library(dplyr)
library(openairmaps)
library(latex2exp)
library(lubridate)

range_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\ Wind_TPH_Range.csv")
range_data = subset(range_data, select = -c(dateTime))
colnames(range_data)[16:20] = c("ws","wd","Temperature","Pressure","Humidity")

# Create a POSIXct object representing a UTC time
utc_time <- ymd_hms(range_data$RollingTime, tz = "UTC")

# Convert the UTC time to Central Time
central_time <- with_tz(utc_time, tzone = "America/Chicago")

range_data$RollingTime =  central_time

range_tibble = as_tibble(range_data)
range_tibble$date = range_tibble$RollingTime


#range_hr = timeAverage(range_tibble,avg.time = "hour")
calendarPlot(range_tibble, 
             pollutant = "Temperature",
             main = TeX('Calendar Plot of Temperature for Joppa - Dallas, TX'),
             key.header = "Temperature (°C)",
             key.position = "bottom",
             par.settings=list(fontsize=list(text=15)))

calendarPlot(range_tibble, 
             pollutant = "Pressure",
             main = TeX('Calendar Plot of Pressure for Joppa - Dallas, TX'),
             key.header = "Pressure (hPa)",
             key.position = "bottom",
             par.settings=list(fontsize=list(text=15)))

calendarPlot(range_tibble, 
             pollutant = "Humidity",
             main = TeX('Calendar Plot of Humidity for Joppa - Dallas, TX'),
             key.header = "Humidity (%)",
             key.position = "bottom",
             par.settings=list(fontsize=list(text=15)))






pm_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Joppa_Jan_2023_tz_fixed_hope.csv")

df <- pm_data %>%
  mutate(dateTime = ymd_hms(dateTime) %>% force_tz("America/Chicago"))
pm_data_tibble = as_tibble(df)
pm_data_tibble$date = pm_data_tibble$dateTime
pm_data_tibble_min <- timeAverage(pm_data_tibble, avg.time = "min")
pm_data_tibble_hour <- timeAverage(pm_data_tibble, avg.time = "hour")

calendarPlot(pm_data_tibble, 
             pollutant = "pm2_5",
             main = TeX('Calendar Plot of $PM_{2.5}$ Concentration for Joppa - Dallas, TX'),
             key.header = TeX("Concentration (μg/m$^{3}$)"),
             key.position = "bottom",
             par.settings=list(fontsize=list(text=15)))

#range_data = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\ Wind_TPH_Range.csv")
#range_data = subset(range_data, select = -c(dateTime))
#colnames(range_data)[16:20] = c("ws","wd","Temperature","Pressure","Humidity")


#range_data$RollingTime = format(range_data$RollingTime, tz="UTC",usetz=TRUE)
#df <- range_data %>%
#  mutate(RollingTime = ymd_hms(RollingTime) %>% force_tz("America/Chicago"))

rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")

range_tibble$date = as.Date(range_tibble$RollingTime)


range_tibble_day=range_tibble[range_tibble$RollingTime >= as.Date("2023-01-02 00:00:00 CST") 
                              & range_tibble$RollingTime < as.Date("2023-01-03 00:00:00 CST"), ] 
pm_range = c(range_tibble_day$pm0.1,range_tibble_day$pm0.3,range_tibble_day$pm0.5,
             range_tibble_day$pm1.0,range_tibble_day$pm2.5,range_tibble_day$pm5.0,
             range_tibble_day$pm10.0)
pm_range = round(na.omit(pm_range),digits=2)
lim = quantile(pm_range, c(0.01,.99))







polarPlot(range_tibble_day,pollutant = "pm0.1",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{0}._1$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble_day,pollutant = "pm0.3",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{0}._3$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble_day,pollutant = "pm0.5",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{0}._5$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble_day,pollutant = "pm1.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{1}._0$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble_day,pollutant = "pm2.5",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{2}._5$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble_day,pollutant = "pm5.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{5}._0$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
polarPlot(range_tibble_day,pollutant = "pm10.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$PM_{10}._0$\\ Measurement Time (Minutes)'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))

title = "01-02-2023"
my.settings <- list(
  par.main.text = list(font = 10, # make it bold
                       just = "left", 
                       x = grid::unit(40, "mm")))

pollution_rose = pollutionRose(range_tibble_day,
              pollutant = "pm2.5",
              cols = rev_default_col,
              par.settings=my.settings,
              main = title,
              layout = c(1,1),
              key.header = TeX('$\\PM_2._5$ Measurement Time (Minutes)'),
              key.footer = " ",
              key.position = "right",
              )



 

pollutionRose(mydata, pollutant = "nox")




pollutionRose(range_tibble_day,
              pollutant = "pm2.5",
              type = "Temperature",
              cols = rev_default_col,
              main = title,
              layout = c(2, 2),
              key.header = TeX('$\\PM_2._5$ Measurement Time (Minutes)'),
              key.footer = " ",
              key.position = "right",
              par.settings=list(fontsize=list(text=7.5)))

pollutionRose(range_tibble_day,
              pollutant = "pm2.5",
              type = "Pressure",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5$ Measurement Time (Minutes)'),
              key.footer = " ",key.position = "right",par.settings=list(fontsize=list(text=7.5)))


pollutionRose(range_tibble_day,
              pollutant = "pm2.5",
              type = "Humidity",cols = rev_default_col,main = title,
              layout = c(2, 2),key.header = TeX('$\\PM_2._5$ Measurement Time (Minutes)'),
              key.footer = " ",key.position = "right",par.settings=list(fontsize=list(text=7.5)),)
