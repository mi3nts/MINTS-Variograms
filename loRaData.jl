using CSV, DataFrames

raw_df = DataFrame()

function checkLatLong(list)
    GPGGA = 0
    PM = 0
    for i in 1:length(list)
        if occursin("GPGGA", list[i])
            GPGGA = i
        elseif occursin(IPS7100, list[i])
            PM = i
        else
            continue
        end
    end

    if GPGGA == 0
        return false
    else
        return true, GPGGA, PM
    end

end

mqtt_dir = readdir("C:/Users/va648/VSCode/MINTS-Variograms/data/rawMqttMFS/")
for elm in mqtt_dir
    elm_path = "C:/Users/va648/VSCode/MINTS-Variograms/data/rawMqttMFS/" * elm
    elm_dir = readdir(elm_path)

    if length(elm_dir) == 0
        continue
    else
        for file in elm_dir
            if file == "2022"
                month_path = elm_path * "2022/" 
                month_dir = readdir(month_path)
                if "6" in month_dir
                    for date in month_dir
                        date_path = month_path * "6/" * date * "/"
                        date_dir = readdir(date_path)

                        if checkLatLong(date_dir)[1]
                            gps_df = CSV.read(checkLatLong[1], DataFrame)
                            if 30<gps_df[!, 2][1]<33 && -98<gps_df[!, 3][1]<-94
                                pm_df = CSV.read(checkLatLong[2], DataFrame)
                                append!(raw_df, pm_df)
                            end
                        end
                    end
                end
            end
            
            end
    end
end
