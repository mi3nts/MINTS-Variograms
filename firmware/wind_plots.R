library("openair")
library("latex2exp")
pm_range = c(wind_data_pm0.1$pm0.1_Range,wind_data_pm0.3$pm0.3_Range,wind_data_pm0.5$pm0.5_Range,
  wind_data_pm1.0$pm1.0_Range,wind_data_pm2.5$pm2.5_Range,wind_data_pm5.0$pm5.0_Range,
  wind_data_pm10.0$pm10.0_Range)
lim = quantile(pm_range, c(0.001,.99))
#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")
wind_data_pm0.1 = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\2022\\10\\5\\csv\\pm0.1_Variogram_Wind_Plots.csv")

mydata_sample = mydata[c(1:nrow(wind_data_pm0.1)),]
mydata_sample$pm0.1 = wind_data_pm0.1$pm0.1_Range
mydata_sample$ws = wind_data_pm0.1$MeanWindSpeed
mydata_sample$wd = wind_data_pm0.1$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")

polarPlot( mydata_sample, pollutant = "pm0.1",main = "2022-10-05",k =30,cols = rev_default_col,
           limits = c(lim[1],lim[2]))



#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")
wind_data_pm0.3 = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\2022\\10\\5\\csv\\pm0.3_Variogram_Wind_Plots.csv")

mydata_sample = mydata[c(1:nrow(wind_data_pm0.3)),]
mydata_sample$pm0.3 = wind_data_pm0.3$pm0.3_Range
mydata_sample$ws = wind_data_pm0.3$MeanWindSpeed
mydata_sample$wd = wind_data_pm0.3$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm0.3",main = "2022-10-05",k =30,,cols = rev_default_col,
           limits = c(lim[1],lim[2]))


#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")
wind_data_pm0.5 = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\2022\\10\\5\\csv\\pm0.5_Variogram_Wind_Plots.csv")

mydata_sample = mydata[c(1:nrow(wind_data_pm0.5)),]
mydata_sample$pm0.5 = wind_data_pm0.5$pm0.5_Range
mydata_sample$ws = wind_data_pm0.5$MeanWindSpeed
mydata_sample$wd = wind_data_pm0.5$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm0.5",main = "2022-10-05",k =30,,cols = rev_default_col,
           limits = c(lim[1],lim[2]))


#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")
wind_data_pm1.0 = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\2022\\10\\5\\csv\\pm1.0_Variogram_Wind_Plots.csv")

mydata_sample = mydata[c(1:nrow(wind_data_pm1.0)),]
mydata_sample$pm1.0 = wind_data_pm1.0$pm1.0_Range
mydata_sample$ws = wind_data_pm1.0$MeanWindSpeed
mydata_sample$wd = wind_data_pm1.0$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm1.0",main = "2022-10-05",k =30,cols = rev_default_col,
           limits = c(lim[1],lim[2]))


#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")
wind_data_pm2.5= read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\2022\\10\\5\\csv\\pm2.5_Variogram_Wind_Plots.csv")

mydata_sample = mydata[c(1:nrow(wind_data_pm2.5)),]
mydata_sample$pm2.5 = wind_data_pm2.5$pm2.5_Range
mydata_sample$ws = wind_data_pm2.5$MeanWindSpeed
mydata_sample$wd = wind_data_pm2.5$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,pm10,co,pm25))
#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm2.5",main = "2022-10-05",k =30,cols = rev_default_col,
           limits = c(lim[1],lim[2]))


#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")
wind_data_pm5.0 = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\2022\\10\\5\\csv\\pm5.0_Variogram_Wind_Plots.csv")

mydata_sample = mydata[c(1:nrow(wind_data_pm5.0)),]
mydata_sample$pm5.0 = wind_data_pm5.0$pm5.0_Range
mydata_sample$ws = wind_data_pm5.0$MeanWindSpeed
mydata_sample$wd = wind_data_pm5.0$MeanWindDirection

#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm5.0",main = "2022-10-05",k =30,cols = rev_default_col,key.position = "bottom",
           key.header = TeX('$\\PM_5. _0 $'),  key.footer =NULL,
           limits = c(lim[1],lim[2]))




#polarCluster( mydata, pollutant = "no2", x = "ws",  wd = "wd")
wind_data_pm10.0 = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\2022\\10\\5\\csv\\pm10.0_Variogram_Wind_Plots.csv")


mydata_sample = mydata[c(1:nrow(wind_data_pm10)),]
mydata_sample$pm10 = wind_data_pm10$pm10.0_Range
mydata_sample$ws = wind_data_pm10.0$MeanWindSpeed
mydata_sample$wd = wind_data_pm10.0$MeanWindDirection

mydata_sample = subset(mydata_sample, select = -c(so2,no2,o3,nox,co,pm25))


#mydata_samp$pm0_3 = wind_data$pm0_3
#mydata_samp$pm0_5 = wind_data$pm0_5
#mydata_samp$pm1_0 = wind_data$pm1_0
#mydata_samp$pm2_5 = wind_data$pm2_5
#mydata_samp$pm5_0 = wind_data$pm5_0
#mydata_samp$pm10_0 = wind_data$pm10_0

polarPlot( mydata_sample, pollutant = "pm10",main = "2022-10-05",k =30,cols = rev_default_col,key.position = "bottom",
           key.header = TeX('$\\PM  _1_0. _0 \\  Range$') ,  key.footer =NULL,
          limits = c(lim[1],lim[2]))