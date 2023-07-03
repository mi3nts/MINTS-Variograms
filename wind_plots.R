library(raster)
#library(ncdf4)

#download.file(url = 'ftp://ftp.hpc.ncep.noaa.gov/grib/20130815/p06m_2013081500f030.grb', destfile = 'test.grb')

#(r <- raster('D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\gdas1.apr23.w1.grb'))

#n <- writeRaster(r, filename = 'netcdf_in_youR_comp.nc', overwrite = TRUE)


#fname = "D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\gdas1.apr23.w1"
#gribdata = readGDAL(fname)



library("dplyr")
library("openair")
library("latex2exp")

wind_data = read.csv("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/monthly/monthlyWind_TPH_Range.csv")
#wind_data = subset(wind_data,date == '01-03-2023')

pm_range = c(wind_data$pm0.1,wind_data$pm0.3,wind_data$pm0.5,
             wind_data$pm1.0,wind_data$pm2.5,wind_data$pm5.0,
             wind_data$pm10.0)
pm_range = na.omit(pm_range)



lim = quantile(pm_range, c(0.05,.95))
#lim = c(min(pm_range),max(pm_range))
mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm0.1 = wind_data$pm0.1
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection
mydata_sample$lat = c(32.715)
mydata_sample$lon = c(-96.748)
mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")

#title = "2023-01-01 - 2023-01-07"
title = "January 2023"


polarPlot(mydata_sample,pollutant = "pm0.1",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$\\PM_0._1\\ Measurement\\ Time\\ (Minutes)$'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=50)))




#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")

mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm0.3 = wind_data$pm0.3
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0


polarPlot( mydata_sample, pollutant = "pm0.3",main = title,k =30,cols = rev_default_col,key.position = "bottom",
           key.header = TeX('$\\PM_0._3\\ Measurement\\ Time\\ (Minutes)$'),  key.footer =NULL,alpha=1,
           limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=50)))





#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")

mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm0.5 = wind_data$pm0.5
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot(mydata_sample, pollutant = "pm0.5",main = title,k =30,cols = rev_default_col,key.position = "bottom",
                     key.header = TeX('$\\PM_0._5\\ Measurement\\ Time\\ (Minutes)$'),  key.footer =NULL,
                     limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=50)))


#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")

mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm1.0 = wind_data$pm1.0
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot(mydata_sample, pollutant = "pm1.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$\\PM_1._0\\ Measurement\\ Time\\ (Minutes)$'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=50)))

#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")

mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm2.5 = wind_data$pm2.5
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot(mydata_sample, pollutant = "pm2.5",main = title,k =30,cols = rev_default_col,key.position = "bottom",
          key.header = TeX('$\\PM_2._5\\ Measurement\\ Time\\ (Minutes)$'),  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=50)))


#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")

mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm5.0 = wind_data$pm5.0
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm5.0",main = title,k =30,cols = rev_default_col,key.position = "bottom",
           key.header = TeX('$\\PM_5._0\\ Measurement\\ Time\\ (Minutes)$'),  key.footer =NULL,
           limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=50)))




#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")


mydata_sample = mydata[c(1:nrow(wind_data)),]
mydata_sample$pm10 = wind_data$pm10.0
mydata_sample$ws = wind_data$MeanWindSpeed
mydata_sample$wd = wind_data$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,co,pm25))


#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm10",main = title,k =30,cols = rev_default_col,key.position = "bottom",
           key.header = TeX('$\\PM_{10.0}\\ Measurement\\ Time\\ (Minutes) $') ,  key.footer =NULL,
          limits = c(lim[1],lim[2]),par.settings=list(fontsize=list(text=50)))
