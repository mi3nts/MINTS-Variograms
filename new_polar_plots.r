library(openair)
library(dplyr)
library(openairmaps)
library(latex2exp)
library(worldmet)

wind_data = read.csv("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/monthly/monthlyWind_TPH_Range.csv")
#wind_data = subset(wind_data,date == '2023-01-03')

#Creating an array with all the time scales
pm_range = c(wind_data$pm0.1,wind_data$pm0.3,wind_data$pm0.5,
             wind_data$pm1.0,wind_data$pm2.5,wind_data$pm5.0,
             wind_data$pm10.0)
pm_range = na.omit(pm_range)


#Specifying the upper limit and lower limit on the color bar using the pm_range aka all the time scales
lim = quantile(pm_range, c(0.05,.95))
#lim = c(min(pm_range),max(pm_range))

# For simplicity, I am copying the data into the variable specified in the package, 
# in order to avoid errors, because the data is in tibble format.
# We can create our own tibble, but make sure all the columns in the tibble are
# following the same data type as mentioned in the example:

mydata_sample = mydata[c(1:nrow(wind_data)),]# sub-setting the mydata(the variable specified in the package) variable 
#Copied all the data from the wind_data variable to mydata_sample
mydata_sample$date = as.POSIXct(wind_data$RollingTime,format="%Y-%m-%dT%H:%M:%S")
mydata_sample$pm0.1 = round(wind_data$pm0.1,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection
mydata_sample$lat = c(32.715)
mydata_sample$lon = c(-96.748)
mydata_sample$Temperature = wind_data$MeanTemperature
mydata_sample$Pressure = wind_data$MeanPressure
mydata_sample$Humidity = wind_data$MeanHumidity

rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")

title = "01/01/2023 - 01/31/2023"

pollutionRose(mydata_sample, pollutant = "pm0.1",main = title,cols = rev_default_col,key.position = "right",
              key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),  
              key.footer =NULL,
              limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Temperature",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Pressure",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))


# #pollution plots sorted by humidity
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Humidity",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# #shows which wind dir. contributed the most
# pollutionRose(mydata_sample, pollutant = "pm0.1", statistic = "prop.mean",cols = rev_default_col)

# #width of each angle segment is given by seg
# pollutionRose(mydata_sample, pollutant = "pm0.1", seg = 1,cols = rev_default_col,
#               key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'))

# # weighted mean pm2.5 time scale
# polarFreq(mydata_sample, pollutant = "pm0.1", 
#            statistic = "weighted.mean", 
#            key.header = "Weighted Mean of pm0.1 Measurement Time ", 
#            key.footer =NULL,
#           min.bin = 2)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1", 
#              period = "weekday", 
#              main = "Weekday",key.header = "Mean pm0.1 Measurement Time in minutes",)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1",
#              key.header = "Mean pm0.1 Measurement Time in minutes",
#              key.footer = NULL,
#              period = "hour", 
#              main = "Hour")


mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm0.3 = round(wind_data$pm0.3,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

pollutionRose(mydata_sample, pollutant = "pm0.3",main = title,cols = rev_default_col,key.position = "right",
              key.header = TeX('$\\PM_0._3\\ Range(Minutes)$'),  
              key.footer =NULL,
              limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
# pollutionRose(mydata_sample,
#               pollutant = "pm0.3",
#               type = "Temperature",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._3\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# pollutionRose(mydata_sample,
#               pollutant = "pm0.3",
#               type = "Pressure",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._3\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))


# #pollution plots sorted by humidity
# pollutionRose(mydata_sample,
#               pollutant = "pm0.3",
#               type = "Humidity",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._3\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# #shows which wind dir. contributed the most
# pollutionRose(mydata_sample, pollutant = "pm0.3", statistic = "prop.mean",cols = rev_default_col)

# #width of each angle segment is given by seg
# pollutionRose(mydata_sample, pollutant = "pm0.3", seg = 1,cols = rev_default_col,
#               key.header = TeX('$\\PM_0._3\\ Range(Minutes)$'))

# # weighted mean pm2.5 time scale
# polarFreq(mydata_sample, pollutant = "pm0.3", 
#            statistic = "weighted.mean", 
#            key.header = "Weighted Mean of pm0.3 Measurement Time ", 
#            key.footer =NULL,
#           min.bin = 2)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.3", 
#              period = "weekday", 
#              main = "Weekday",key.header = "Mean pm0.3 Measurement Time in minutes",)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.3",
#              key.header = "Mean pm0.3 Measurement Time in minutes",
#              key.footer = NULL,
#              period = "hour", 
#              main = "Hour")

mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm0.5 = round(wind_data$pm0.5,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

pollutionRose(mydata_sample, pollutant = "pm0.5",main = title,cols = rev_default_col,key.position = "right",
              key.header = TeX('$\\PM_0._5\\ Range(Minutes)$'),  
              key.footer =NULL,
              limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
# pollutionRose(mydata_sample,
#               pollutant = "pm0.5",
#               type = "Temperature",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._5\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# pollutionRose(mydata_sample,
#               pollutant = "pm0.5",
#               type = "Pressure",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._5\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))


# #pollution plots sorted by humidity
# pollutionRose(mydata_sample,
#               pollutant = "pm0.5",
#               type = "Humidity",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._5\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# #shows which wind dir. contributed the most
# pollutionRose(mydata_sample, pollutant = "pm0.5", statistic = "prop.mean",cols = rev_default_col)

# #width of each angle segment is given by seg
# pollutionRose(mydata_sample, pollutant = "pm0.5", seg = 1,cols = rev_default_col,
#               key.header = TeX('$\\PM_0._5\\ Range(Minutes)$'))

# polarFreq(mydata_sample, pollutant = "pm0.5", 
#            statistic = "weighted.mean", 
#            key.header = "Weighted Mean of pm0.5 Measurement Time ", 
#            key.footer =NULL,
#           min.bin = 2)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.5", 
#              period = "weekday", 
#              main = "Weekday",key.header = "Mean pm0.1 Measurement Time in minutes",)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.5",
#              key.header = "Mean pm0.1 Measurement Time in minutes",
#              key.footer = NULL,
#              period = "hour", 
#              main = "Hour")


mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm1.0 = round(wind_data$pm1.0,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

pollutionRose(mydata_sample, pollutant = "pm1.0",main = title,cols = rev_default_col,key.position = "right",
              key.header = TeX('$\\PM_1._0\\ Range(Minutes)$'),  
              key.footer =NULL,
              limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
# pollutionRose(mydata_sample,
#               pollutant = "pm1.0",
#               type = "Temperature",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_1._0\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# pollutionRose(mydata_sample,
#               pollutant = "pm1.0",
#               type = "Pressure",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_1._0\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))


# #pollution plots sorted by humidity
# pollutionRose(mydata_sample,
#               pollutant = "pm1.0",
#               type = "Humidity",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_1._0\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# #shows which wind dir. contributed the most
# pollutionRose(mydata_sample, pollutant = "pm1.0", statistic = "prop.mean",cols = rev_default_col)

# #width of each angle segment is given by seg
# pollutionRose(mydata_sample, pollutant = "pm1.0", seg = 1,cols = rev_default_col,
#               key.header = TeX('$\\PM_1._0\\ Range(Minutes)$'))

# polarFreq(mydata_sample, pollutant = "pm1.0", 
#            statistic = "weighted.mean", 
#            key.header = "Weighted Mean of pm0.1 Measurement Time ", 
#            key.footer =NULL,
#           min.bin = 2)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1", 
#              period = "weekday", 
#              main = "Weekday",key.header = "Mean pm0.1 Measurement Time in minutes",)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1",
#              key.header = "Mean pm0.1 Measurement Time in minutes",
#              key.footer = NULL,
#              period = "hour", 
#              main = "Hour")


mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm2.5 = round(wind_data$pm2.5,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

pollutionRose(mydata_sample, pollutant = "pm2.5",main = title,cols = rev_default_col,key.position = "right",
              key.header = TeX('$\\PM_2._5\\ Range(Minutes)$'),  
              key.footer =NULL,
              limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Temperature",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Pressure",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))


# #pollution plots sorted by humidity
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Humidity",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# #shows which wind dir. contributed the most
# pollutionRose(mydata_sample, pollutant = "pm0.1", statistic = "prop.mean",cols = rev_default_col)

# #width of each angle segment is given by seg
# pollutionRose(mydata_sample, pollutant = "pm0.1", seg = 1,cols = rev_default_col,
#               key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'))

# # weighted mean pm2.5 time scale
# polarFreq(mydata_sample, pollutant = "pm0.1", 
#            statistic = "weighted.mean", 
#            key.header = "Weighted Mean of pm0.1 Measurement Time ", 
#            key.footer =NULL,
#           min.bin = 2)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1", 
#              period = "weekday", 
#              main = "Weekday",key.header = "Mean pm0.1 Measurement Time in minutes",)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1",
#              key.header = "Mean pm0.1 Measurement Time in minutes",
#              key.footer = NULL,
#              period = "hour", 
#              main = "Hour")


mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm5.0 = round(wind_data$pm5.0,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

pollutionRose(mydata_sample, pollutant = "pm5.0",main = title,cols = rev_default_col,key.position = "right",
              key.header = TeX('$\\PM_5._0\\ Range(Minutes)$'),  
              key.footer =NULL,
              limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Temperature",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Pressure",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))


# #pollution plots sorted by humidity
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Humidity",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# #shows which wind dir. contributed the most
# pollutionRose(mydata_sample, pollutant = "pm0.1", statistic = "prop.mean",cols = rev_default_col)

# #width of each angle segment is given by seg
# pollutionRose(mydata_sample, pollutant = "pm0.1", seg = 1,cols = rev_default_col,
#               key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'))

# # weighted mean pm2.5 time scale
# polarFreq(mydata_sample, pollutant = "pm0.1", 
#            statistic = "weighted.mean", 
#            key.header = "Weighted Mean of pm0.1 Measurement Time ", 
#            key.footer =NULL,
#           min.bin = 2)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1", 
#              period = "weekday", 
#              main = "Weekday",key.header = "Mean pm0.1 Measurement Time in minutes",)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1",
#              key.header = "Mean pm0.1 Measurement Time in minutes",
#              key.footer = NULL,
#              period = "hour", 
#              main = "Hour")


mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm10.0 = round(wind_data$pm10.0,digits = 2)
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

pollutionRose(mydata_sample, pollutant = "pm10.0",main = title,cols = rev_default_col,key.position = "right",
              key.header = TeX('$\\PM_1_0._0\\ Range(Minutes)$'),  
              key.footer =NULL,
              limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=10)))
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Temperature",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Pressure",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))


# #pollution plots sorted by humidity
# pollutionRose(mydata_sample,
#               pollutant = "pm0.1",
#               type = "Humidity",cols = rev_default_col,
#               layout = c(2, 2),key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'),
#               key.position = "right",par.settings=list(fontsize=list(text=7.5)))

# #shows which wind dir. contributed the most
# pollutionRose(mydata_sample, pollutant = "pm0.1", statistic = "prop.mean",cols = rev_default_col)

# #width of each angle segment is given by seg
# pollutionRose(mydata_sample, pollutant = "pm0.1", seg = 1,cols = rev_default_col,
#               key.header = TeX('$\\PM_0._1\\ Range(Minutes)$'))

# # weighted mean pm2.5 time scale
# polarFreq(mydata_sample, pollutant = "pm0.1", 
#            statistic = "weighted.mean", 
#            key.header = "Weighted Mean of pm0.1 Measurement Time ", 
#            key.footer =NULL,
#           min.bin = 2)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1", 
#              period = "weekday", 
#              main = "Weekday",key.header = "Mean pm0.1 Measurement Time in minutes",)

# polarAnnulus(mydata_sample, 
#              pollutant = "pm0.1",
#              key.header = "Mean pm0.1 Measurement Time in minutes",
#              key.footer = NULL,
#              period = "hour", 
#              main = "Hour")


#pollution plots sorted by temperature


#pollution plots sorted by pressure
