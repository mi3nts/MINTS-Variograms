using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions
include("File_Search_trial.jl")

df_wind_list = []
df_tph_list = []
BME680_paths = ["C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/01/MINTS_001e0636e547_BME680_2023_01_01.csv", "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/02/MINTS_001e0636e547_BME680_2023_01_02.csv", "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/03/MINTS_001e0636e547_BME680_2023_01_03.csv", "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/04/MINTS_001e0636e547_BME680_2023_01_04.csv", "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/05/MINTS_001e0636e547_BME680_2023_01_05.csv", "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/06/MINTS_001e0636e547_BME680_2023_01_06.csv", "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/07/MINTS_001e0636e547_BME680_2023_01_07.csv"]
for i in 1:1:7
    push!(df_wind_list, CSV.read(df_wind_csv.WIMDA[i],DataFrame))
    push!(df_tph_list, CSV.read(BME680_paths[i],DataFrame))
end
data_frame_wind_combined = reduce(vcat,df_wind_list)
data_frame_tph_combined = reduce(vcat,df_tph_list)


function data_cleaning( data_frame,sensor_type) 

    if(sensor_type == "WIMDA")
    cols = [:dateTime,:windDirectionTrue,:windSpeedMetersPerSecond]

    elseif (sensor_type == "BME680")
        cols = [:dateTime,:temperature,:pressure,:humidity]
    elseif (sensor_type == "SCD30")
        cols = [:dateTime,:c02]
    end 

    # Code that may throw an exception.
    idx = []
    ms= zeros(length(data_frame[!,:dateTime]))
    for i in  1:length(data_frame[!,:dateTime])
        ms[i] = try 
            
            parse(Float64,data_frame[!,:dateTime][i][20:26])
        catch
            append!(idx,i)
            ms[i] = parse(Float64,data_frame[!,:dateTime][i-1][20:26]) 
        end    
    end
    data_frame = delete!(data_frame, idx)
    ms = ms[Not(idx)]



    data_frame.ms  = Second.(round.(Int,ms))
    data_frame.dateTime = [x[1:19] for x in data_frame[!,:dateTime]]
    data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS")
    data_frame.dateTime = data_frame.dateTime + data_frame.ms
    data_frame = select!(data_frame, Not(:ms))

    data_frame = data_frame[:,cols]
    col_symbols = Symbol.(names(data_frame))
    data_frame = DataFrames.combine(DataFrames.groupby(data_frame, :dateTime), col_symbols[2:end] .=> mean)
    return data_frame,col_symbols
end

data_frame_wind,cols_wind = data_cleaning(data_frame_wind_combined,"WIMDA")
data_frame_tph,cols_tph = data_cleaning(data_frame_tph_combined,"BME680")



function dataframe_updates(data_frame,cols,sensor_type)
    
    if (sensor_type == "WIMDA")
        time_to_round = 2
    elseif (sensor_type == "BME680")
        time_to_round = 10
    elseif (sensor_type == "SCD30")
        time_to_round = 10
    end
    data_frame.dateTime = round.(data_frame.dateTime, Dates.Second(time_to_round))

    ################### Some issue with imputation logic, need to fix it ###################### Believe its fixed
    df = DataFrame()
    df.dateTime = collect(DateTime(2023,01,01):Second(time_to_round):DateTime(2023,01,08)-Second(1))
    df = outerjoin( df,data_frame, on = :dateTime)
    sort!(df, (:dateTime))
    println(cols)
    df = DataFrames.rename!(df, cols)
    df_sensor = Impute.locf(df)|>Impute.nocb()
    
    df_sensor = DataFrames.combine(DataFrames.groupby(df_sensor, :dateTime), cols[2:end] .=> mean)
    df_sensor = DataFrames.rename!(df_sensor, cols)
    return df_sensor
end



#df_co2 = dataframe_updates(data_frame_c02,cols_c02,"SCD30")

df_wind = dataframe_updates(data_frame_wind, cols_wind,"WIMDA")
df_tph = dataframe_updates(data_frame_tph,cols_tph,"BME680")
df_wind[!,"date"] = Date.(df_wind[!,:dateTime])
df_wind = groupby(df_wind, :date)[3]

df_tph[!,"date"] = Date.(df_tph[!,:dateTime])
df_tph = groupby(df_tph, :date)[3]
