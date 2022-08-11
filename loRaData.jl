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

function discrepancyDetection(path)
    pm_df = CSV.read(path, DataFrame)
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
    return date_discrepancy_arr, bar_arr
end

Plots.bar(discrepancyDetection("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/sortedAprilJunePMData.csv")[1], discrepancyDetection("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/sortedAprilJunePMData.csv")[2], xlabel = "Date", ylabel = "Amount of 1 minute Gaps in Data", label="", title = "")


#make the below automated

data_frame = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/sortedAprilJuneTPHData.csv", DataFrame)
data_frame.dateTime =  chop.(data_frame.dateTime,tail= 10)
data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM")
gd = groupby(data_frame, :dateTime)
minute_agg_df = DataFrame()
for group in gd
    row_df = DataFrame(dateTime = [],
                    Temperature = [],
                    Pressure = [],
                    Humidity = [])
    push!(row_df[!, :dateTime], group.dateTime[1])
    for i in [:Temperature, :Pressure, :Humidity]
        append!(row_df[!, i], sum(group[!, i])/length(group[!, i]))
    end
    append!(minute_agg_df, row_df)
end
minute_agg_df = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/sortedLoRaData/Compiled/MinuteAverage/minuteTPH.csv", DataFrame)

omit_arr = []
for i in 1:length(minute_agg_df.Temperature)
    if minute_agg_df.Temperature[i] < 0
        append!(omit_arr, i)
    end
end

minute_agg_df = delete!(minute_agg_df, omit_arr)

data_TPH = (datetime = [minute_agg_df.dateTime[i] for i in 1:length(minute_agg_df.dateTime)],
        col1 = [minute_agg_df.Temperature[i] for i in 1:length(minute_agg_df.dateTime)],
        col2 = [minute_agg_df.Pressure[i] for i in 1:length(minute_agg_df.dateTime)],
        col3 = [minute_agg_df.Humidity[i] for i in 1:length(minute_agg_df.dateTime)])
ta = TimeArray(data_TPH; timestamp = :datetime, meta = "Example")
plot(ta[:col1], xlabel = "Date", ylabel = "Temperature/Pressure Readings", label = "Temperature", title = "Temperature/Pressure/Humidity LoRa Node April - June TimeSeries", size = (1200, 1000), legend = :topleft, yticks = [0, 25, 50, 75, 100, 125, 150])
plot!(ta[:col3], xlabel = "Date", ylabel = "Temperature/Pressure Readings", label = "Humidity")
plot!(twinx(), ta[:col2], color = :red, xlabel = "Date", ylabel = "Humidity Readings", label= "Pressure", title = "Temperature/Pressure/Humidity LoRa Node April - June TimeSeries")
savefig("C:/Users/va648/VSCode/MINTS-Variograms/plots/TPH Compiled TimeSeries.png")
