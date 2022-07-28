using CSV, DataFrames, Dates

raw_df = DataFrame()
sorted_df = DataFrame()

function checkLatLong(list)
    GPGGA = 1
    PM = 1
    for i in 1:length(list)
        if occursin("GPGGA", list[i])
            GPGGA = i
        elseif occursin("IPS7100", list[i])
            PM = i
        else
            continue
        end
    end

    if GPGGA == 0 && PM == 0
        return false
    else
        return true, GPGGA, PM
    end
end

function timeSeriesSort(df)

    ms = [parse(Float64, x[20:26]) for x in df[!,:dateTime]]
    ms = string.(round.(ms,digits = 3)*1000)
    ms = chop.(ms,tail= 2)
    df.dateTime =  chop.(df.dateTime,tail= 6)
    df.dateTime = df.dateTime.* ms
    df.dateTime = DateTime.(df.dateTime,"yyyy-mm-dd HH:MM:SS.sss")
    df.dateTime = sort(df.dateTime)

    return df
end

#only reads june data for now
#change mqtt dir path
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
                if "06" in year_dir
                    month_path = year_path * "06/"
                    month_dir = readdir(month_path)
                    for date in month_dir
                        date_path = month_path *  date * "/"
                        date_dir = readdir(date_path)
                        if length(date_dir) == 0
                            continue
                        else
                            if checkLatLong(date_dir)[1]
                                gps_df = CSV.read(date_path * date_dir[checkLatLong(date_dir)[2]], DataFrame)
                                if 30<gps_df[!, 2][1]<33 && -98<gps_df[!, 3][1]<-94
                                    pm_df = CSV.read(date_path * date_dir[checkLatLong(date_dir)[3]], DataFrame)
                                    if length(names(pm_df)) == 15
                                        append!(raw_df, pm_df)
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

raw_df = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/juneData.csv", DataFrame)

#print(raw_df)
#CSV.write("C:/Users/va648/VSCode/MINTS-Variograms/data/juneData.csv", raw_df)
sorted_df = timeSeriesSort(raw_df)
CSV.write("C:/Users/va648/VSCode/MINTS-Variograms/data/juneSortedData.csv", sorted_df)

