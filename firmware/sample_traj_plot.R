library(splitr)

# Set the HYSPLIT configuration options
lat <- 32.71568
lon <- -96.74800
height <- 50
duration <- 24
days <- "2023-01-29"
daily_hours <- c(0, 6, 12, 18)
direction <- "backward"
met_type <- "gdas1"
extended_met <- TRUE
met_dir <- here::here("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\")
exec_dir <- here::here("C:\\Users\\balag\\AppData\\Local\\R\\win-library\\4.2\\splitr\\win\\")

# Generate the HYSPLIT trajectory
trajectory <- hysplit_trajectory(
  lat = lat,
  lon = lon,
  height = height,
  duration = duration,
  days = days,
  daily_hours = daily_hours,
  direction = direction,
  met_type = met_type,
  extended_met = extended_met,
  met_dir = met_dir,
  exec_dir = exec_dir
)

data
# Write out csv file
write.csv(data, file = "D:\\trial.csv", row.names = FALSE)



# Plot the trajectory on a map
plot_trajectory_map(trajectory)
