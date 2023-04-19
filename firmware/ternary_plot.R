# Load required libraries
library("ggplot2")
library("ggtern")
library("grDevices")
df = read.csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Wind_TPH_Range.csv")
col = c("MeanTemperature","MeanPressure","MeanHumidity")
rev_default_col = c("#9E0142","#FA8C4E","#FFFFBF","#88D1A4","#5E4FA2")
#df_tph = subset(df, RollingTime >= as.POSIXct("2023-01-03 00:00:00") & RollingTime <= as.POSIXct("2023-01-03 23:59:59"))
pm_sub  = c("0.1", "0.3", "0.5", "1.0", "2.5","5.0","10.0")
new_arrow_pos <- c(0.2, 0.6, 0.2)
new_arrow_labels <- c("New Pressure", "New Temperature", "New Humidity")
for (x in 9:15){
  #x = 15
  cols_filtered = append(col,colnames(df)[x])# replace pm0.1 with x
  print(cols_filtered)
  df_tph = df[cols_filtered]
  df_tph = na.omit(df_tph)
  mean_p = df_tph$MeanPressure
  mean_t = df_tph$MeanTemperature
  mean_rh = df_tph$MeanHumidity
  pm = df_tph[[cols_filtered[4]]]
  
  pressure_percentile_values <- round(quantile(unique(mean_p), probs = c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0), type = 1),digits = 1)
  temperature_percentile_values <- round(quantile(unique(mean_t), probs = c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0), type = 1),digits = 0)
  rel_humidity_percentile_values <- round(quantile(unique(mean_rh), probs = c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0), type = 1),digits = 0)
  
  
  p_pct = ((mean_p - min(mean_p)) / (max(mean_p) - min(mean_p))) * 100 
  t_pct = ((mean_t - min(mean_t)) / (max(mean_t) - min(mean_t))) * 100
  rh_pct = ((mean_rh - min(mean_rh)) / (max(mean_rh) - min(mean_rh))) * 100
  
  
  df_tph_filtered <- data.frame(p = p_pct, t = t_pct, rh = rh_pct,time_scale = pm )
 
  # Plot the ternary diagram
  p = ggtern(df_tph_filtered, aes(x = p, y = t, z = rh, fill = time_scale)) +
      geom_point(shape = 21, size = 1, stroke = NA) +
      scale_fill_gradientn(colors = rev_default_col, na.value = "transparent",name = "Time Scale") +
      theme_bw() +
      theme(legend.position = c(0.95, 0.65),
            legend.title = element_text(size = 5),
            legend.text = element_text(size = 5),
            axis.title = element_text(size = 4.5),
            axis.text = element_text(size = 4.5),
            plot.subtitle = element_text(size = 6, hjust = 0.5),
            #axis.ticks = element_line(linewidth = 2),
            plot.title = element_text(hjust = 0.5, size = 6))+

      ggtitle(bquote(paste("Characterizing PM"[.(pm_sub[x-8])], " Measurement Time w.r.t variation in Pressure,Temperature, and Humidity")))+
    labs( subtitle = "(2023-01-01 - 2023-01-07)",x       = "",
          xarrow  = "Pressure (hPa)",
          y       = "",
          yarrow  = "Temperature (°Celsius)",
          z       = "",
          zarrow  = "Humidity (%)") + 
    theme_showarrows()+
    scale_T_continuous(limits=c(0.,1.0),
                       breaks=seq(0,1,by=0.1),
                       labels=temperature_percentile_values) + 
    scale_L_continuous(limits=c(0.0,1),
                       breaks=seq(0,1,by=0.1),
                       labels=pressure_percentile_values) +
    scale_R_continuous(limits=c(0,1),
                       breaks=seq(0,1,by=0.1),
                       labels=rel_humidity_percentile_values)
  
  print(p)
  cols_filtered = c()
  
}

# Sample data for pressure, temperature, and humidity
#p <- log(df_tph$MeanPressure[!is.na(df_tph$MeanPressure)]-min(df_tph$MeanPressure[!is.na(df_tph$MeanPressure)]))*100  # in hPa
#t <- log(df_tph$MeanTemperature[!is.na(df_tph$MeanTemperature)]-min(df_tph$MeanTemperature[!is.na(df_tph$MeanTemperature)]))*100  # in degrees Celsius
#rh <- log(df_tph$MeanHumidity[!is.na(df_tph$MeanHumidity)]-min(df_tph$MeanHumidity[!is.na(df_tph$MeanHumidity)]))*100   # in %

# Convert the data into percentages
#p_pct <- p /max(p)
#t_pct <- t / max(t)
#rh_pct <- rh / 100



# Create a data frame with the percentages







# Create sample data
#data <- data.frame(P = runif(100, 0, 1), T = runif(100, 0, 1), H = runif(100, 0, 1), pm_conc = runif(100, 0, 1))
















