using CSV, DataFrames

raw_df = DataFrame()

#works
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

#only reads june data for now
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

#testing
print(raw_df)
CSV.write("C:/Users/va648/VSCode/MINTS-Variograms/data/juneData.csv", raw_df)
