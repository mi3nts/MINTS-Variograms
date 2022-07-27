using CSV, DataFrames, Pandas

raw_df = DataFrame()

mqtt_dir = readdir("C:/Users/va648/VSCode/MINTS-Variograms/data/rawMqttMFS/")
for elm in mqtt_dir
    elm_path = "C:/Users/va648/VSCode/MINTS-Variograms/data/rawMqttMFS/" * elm
    elm_dir = readdir(elm_path)

    for file in elm_dir
        if file == "2022"
            month_path = elm_path * "2022/" 
            month_dir = readdir(month_path)
            if "6" in month_dir
                for date in month_dir
                    date_path = month_path * "6/" * date * "/"
                    date_dir = readdir(date_path)

                    for file in date_dir
                        df = CSV.read(date_path, DataFrame)
                        if "pc0_1" in names(df)
                            append!(raw_df, df)
                        else
                            continue
                        end
                    end
                end
            else
                continue
            end
        else
            continue
        end
        
        end
end

print(raw_df)
