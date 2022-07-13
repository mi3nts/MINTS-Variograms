using GeoStats, Plots, DataFrames, CSV, Dates

data_frame = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/MINTS_001e06373996_IPS7100_2022_01_02.csv", DataFrame) 
ms = [parse(Float64,x[20:26]) for x in data_frame[!,:dateTime]]
ms = string.(round.(ms,digits = 3)*1000)
ms = chop.(ms,tail= 2)
data_frame.dateTime =  chop.(data_frame.dateTime,tail= 6)
data_frame.dateTime = data_frame.dateTime.* ms
data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS.sss")
ls_index = findall(x-> Millisecond(500)<x<Millisecond(1500), diff(data_frame.dateTime))

pm25_init_vec = data_frame.pm2_5
pm25_vec = []
for i in 1:length(ls_index)
    append!(pm25_vec, pm25_init_vec[ls_index[i]])
end

print(pm25_vec)


#initialize georef data
𝒟 = georef((Z=[pm25_vec]))

#empirical variogram
g = EmpiricalVariogram(𝒟, :Z)

plot(g)
