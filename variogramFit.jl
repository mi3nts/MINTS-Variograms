using GeoStats, Plots, DataFrames, CSV, Dates

data_frame = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/MINTS_001e06373996_IPS7100_2022_01_02.csv", DataFrame) 
ms = [parse(Float64,x[20:26]) for x in data_frame[!,:dateTime]]
ms = string.(round.(ms,digits = 3)*1000)
ms = chop.(ms,tail= 2)
data_frame.dateTime =  chop.(data_frame.dateTime,tail= 6)
data_frame.dateTime = data_frame.dateTime.* ms
data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS.sss")
ls_index = findall(x-> Millisecond(500)<x<Millisecond(1500), diff(data_frame.dateTime))
df = data_frame[ls_index, :]


#initialize georef data
𝒟 = georef((Z=df.pm2_5, ))

#empirical variogram
g = EmpiricalVariogram(𝒟, :Z, maxlag=100.)

plot(g)
