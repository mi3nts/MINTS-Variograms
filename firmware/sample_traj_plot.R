library(openairmaps)
library(leaflet)

leaflet() %>%
  addTiles() %>%
  addPolarMarkers(data = polar_data,
                  fun = openair::polarPlot,
                  pollutant = "nox") %>%
  addTrajPaths(data = traj_data)