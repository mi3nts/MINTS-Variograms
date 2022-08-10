using CSV, DataFrames, Dates, Plots, TimeSeries

sorted_df = DataFrame()

#IPS7100 = PM, BME280 = T,P,H
function checkLatLong(list, sensor_output)
    GPGGA = 1
    weather_sensor = 1
    for i in 1:length(list)
        if occursin("GPGGA", list[i])
            GPGGA = i
        elseif occursin(sensor_output, list[i])
            weather_sensor = i
        else
            continue
        end
    end
    if GPGGA == 0 && weather_sensor == 0
        return false
    else
        return true, GPGGA, weather_sensor
    end
end

function writeCSV(sensor, directory, searches_dict)
    if sensor == "IPS7100"
        num_cols = 15
    elseif sensor == "BME280"
        num_cols = 4
    end

    raw_df = DataFrame()
    mqtt_dir = readdir(directory)
    for elm in mqtt_dir
        elm_path = directory * "/" * elm
        elm_dir = readdir(elm_path)
        if length(elm_dir) == 0
            continue
        else
            for file in elm_dir
                if file == searches_dict["L1"] #2022
                    year_path = elm_path * "/" * searches_dict["L1"] * "/"
                    year_dir = readdir(year_path)
                    for i in 1:length(searches_dict["L2"]) #loops through months of april, may, june
                        if searches_dict["L2"][i] in year_dir
                            month_path = year_path * searches_dict["L2"][i] * "/"
                            month_dir = readdir(month_path)
                            for date in month_dir
                                date_path = month_path *  date * "/"
                                date_dir = readdir(date_path)
                                if length(date_dir) == 0
                                    continue
                                else
                                    if checkLatLong(date_dir, sensor)[1]
                                        gps_df = CSV.read(date_path * date_dir[checkLatLong(date_dir, sensor)[2]], DataFrame)
                                        if 30<gps_df[!, 2][1]<33 && -98<gps_df[!, 3][1]<-94
                                            sensor_df = CSV.read(date_path * date_dir[checkLatLong(date_dir, sensor)[3]], DataFrame)
                                            if length(names(sensor_df)) == num_cols
                                                append!(raw_df, sensor_df)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    sorted_df = sort(raw_df)
    if sensor == "IPS7100"
        CSV.write("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/sortedAprilJunePMData.csv", sorted_df)
    elseif sensor == "BME280"
        CSV.write("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/sortedAprilJuneTPHData.csv", sorted_df)
    end
end

searches_dict = Dict("L1" => "2022", "L2" => ["04", "05", "06"])
writeCSV("BME280", "C:/Users/va648/VSCode/MINTS-Variograms/data/rawMqttMFS/", searches_dict)
#writeCSV("IPS7100", "C:/Users/va648/VSCode/MINTS-Variograms/data/rawMqttMFS/", searches_dict)

#find amount of unique nodes
function nodeCount()
    node_count = 0
    mqtt_dir = readdir("D:/rawMqttMFS/")
    for elm in mqtt_dir
        elm_path = "D:/rawMqttMFS/" * elm
        elm_dir = readdir(elm_path)
        if length(elm_dir) == 0
            continue
        else
            for file in elm_dir
                if file == "2022"
                    year_path = elm_path * "/2022/" 
                    year_dir = readdir(year_path)
                    if "04" in year_dir || "05" in year_dir || "06" in year_dir
                        if isdir(year_path * "04/")
                            month_path = year_path * "04/"
                        elseif isdir(year_path* "05/")
                            month_path = year_path * "05/"
                        elseif isdir(year_path * "06/")
                            month_path = year_path * "06/"
                        end

                        month_dir = readdir(month_path)
                        if length(month_dir) != 0
                            date_path = month_path *  month_dir[1] * "/" ##
                            date_dir = readdir(date_path)
                            if checkLatLong(date_dir, "BME280")[1] || checkLatLong(date_dir, "IPS7100")[1]
                                #check if the directory has either a bme or ips file, if it does, find gps file
                                if checkLatLong(date_dir, "BME280")[1]
                                    gps_df = CSV.read(date_path * date_dir[checkLatLong(date_dir, "BME280")[2]], DataFrame)

                                elseif checkLatLong(date_dir, "IPS7100")[1]
                                    gps_df = CSV.read(date_path * date_dir[checkLatLong(date_dir, "IPS7100")[2]], DataFrame)
                                end

                                if 30<gps_df[!, 2][1]<33 && -98<gps_df[!, 3][1]<-94
                                    node_count = node_count + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    print(node_count)
end

#returns 57

pm_df = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/sortedAprilJunePMData.csv", DataFrame)
pm_mins = [parse(Int64, x[15:16]) for x in pm_df[!,:dateTime]]
discrepancy_arr = []
date_discrepancy_arr = []
for i in 1:length(pm_df.dateTime)
    if i < length(pm_df.dateTime)
        if pm_mins[i+1] - pm_mins[i] > 1
            push!(discrepancy_arr, pm_df.dateTime[i])
            if pm_df.dateTime[i][6:10] in date_discrepancy_arr
                continue
            else
                push!(date_discrepancy_arr, pm_df.dateTime[i][6:10])
            end
        end
    end
end
print(discrepancy_arr)
println("##################")
print(date_discrepancy_arr)

bar_arr = Vector{Int64}(undef, length(date_discrepancy_arr))
for i in 1:length(date_discrepancy_arr)
    count = 0
    for j in 1:length(discrepancy_arr)
        if occursin(date_discrepancy_arr[i], discrepancy_arr[j])
            count = count + 1
        end
    end
    bar_arr[i] = count
end
print(bar_arr)
Plots.bar(date_discrepancy_arr, bar_arr, xlabel = "Date", ylabel = "Amount of 1 minute Gaps in Data", label="", title = "")
#println(length(discrepancy_arr))

data_frame = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/sortedAprilJunePMData.csv", DataFrame)
data_frame.dateTime =  chop.(data_frame.dateTime,tail= 10)
data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM")
gd = groupby(data_frame, :dateTime)
#minute_agg_df = DataFrame()
for group in gd
    row_df = DataFrame(dateTime = [],
                    pm0_1 = [],
                    pm0_3 = [],
                    pm0_5 = [],
                    pm1_0 = [],
                    pm2_5 = [],
                    pm5_0 = [],
                    pm10_0 = [])
    push!(row_df[!, :dateTime], group.dateTime[1])
    for i in [:pm0_1,:pm0_3,:pm0_5,:pm1_0,:pm2_5,:pm5_0,:pm10_0]
        append!(row_df[!, i], last(cumsum(group[!, i]))/length(group[!, i]))
    end
    append!(minute_agg_df, row_df)
end
#print(minute_agg_df)

#CSV.write("C:/Users/va648/VSCode/MINTS-Variograms/data/minute.csv", minute_agg_df)
minute_agg_df = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/minute.csv", DataFrame)

data = (datetime = [minute_agg_df.dateTime[i] for i in 1:length(minute_agg_df.dateTime)],
        col1 = [minute_agg_df.pm0_1[i] for i in 1:length(minute_agg_df.dateTime)],
        col2 = [minute_agg_df.pm0_3[i] for i in 1:length(minute_agg_df.dateTime)],
        col3 = [minute_agg_df.pm0_5[i] for i in 1:length(minute_agg_df.dateTime)],
        col4 = [minute_agg_df.pm1_0[i] for i in 1:length(minute_agg_df.dateTime)],
        col5 = [minute_agg_df.pm2_5[i] for i in 1:length(minute_agg_df.dateTime)],
        col6 = [minute_agg_df.pm5_0[i] for i in 1:length(minute_agg_df.dateTime)],
        col7 = [minute_agg_df.pm10_0[i] for i in 1:length(minute_agg_df.dateTime)], )
ta = TimeArray(data; timestamp = :datetime, meta = "Example")
plot(ta[:col1], xlabel = "Date", ylabel = "PM 0.1 Concentration", label="PM0.1", title = "PM0.1 LoRa Node April - June TimeSeries")
plot(ta[:col2], xlabel = "Date", ylabel = "PM 0.3 Concentrations", label="PM0.3", title = "PM 0.3 LoRa Node April - June TimeSeries")
plot(ta[:col3], xlabel = "Date", ylabel = "PM 0.5 Concentrations", label="PM0.5", title = "PM 0.5 LoRa Node April - June TimeSeries")
plot(ta[:col4], xlabel = "Date", ylabel = "PM 1.0 Concentrations", label="PM1.0", title = "PM 1.0 LoRa Node April - June TimeSeries")
plot(ta[:col5], xlabel = "Date", ylabel = "PM 2.5 Concentrations", label="PM2.5", title = "PM 2.5 LoRa Node April - June TimeSeries")
plot(ta[:col6], xlabel = "Date", ylabel = "PM 5.0 Concentrations", label="PM5.0", title = "PM 5.0 LoRa Node April - June TimeSeries")
plot(ta[:col7], xlabel = "Date", ylabel = "PM 10.0 Concentrations", label="PM10.0", title = "PM 10.0 LoRa Node April - June TimeSeries")
