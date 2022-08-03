using CSV, DataFrames, Dates, PyCall

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

raw_df = sort(raw_df)
print(raw_df)



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
#returns 57
