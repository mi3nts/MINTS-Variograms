using Pkg
Pkg.activate("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\LoRa")
using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions

path_to_airmar_data = "D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\001e0642ff0f\\2022\\10\\05\\MINTS_001e0642ff0f_WIMDA_2022_10_05.csv"
path_to_bme_680_data = "D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\001e063739c7\\2022\\10\\05\\MINTS_001e063739c7_BME680_2022_10_05.csv"
path_to_scd_30_data = "D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\001e063739c7\\2022\\10\\05\\MINTS_001e063739c7_SCD30_2022_10_05.csv"


function data_cleaning( path_to_csv,sensor_type) 

    if(sensor_type == "WIMDA")
    data_frame = CSV.read(path_to_airmar_data,DataFrame)
    cols = [:dateTime,:windDirectionTrue,:windDirectionMagnetic,:windSpeedMetersPerSecond]

    elseif (sensor_type == "BME680")
        cols = [:dateTime,:temperature,:pressure,:humidity]
        data_frame = CSV.read(path_to_csv,DataFrame)
    elseif (sensor_type == "SCD30")
        data_frame = CSV.read(path_to_csv,DataFrame)
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

data_frame_wind = data_cleaning(path_to_airmar_data,"WIMDA")[1]
data_frame_tph = data_cleaning(path_to_bme_680_data,"BME680")[1]
data_frame_c02 = data_cleaning(path_to_scd_30_data,"SCD30")[1]

cols_wind = data_cleaning(path_to_airmar_data,"WIMDA")[2]
cols_tph = data_cleaning(path_to_bme_680_data,"BME680")[2]
cols_c02 = data_cleaning(path_to_scd_30_data,"SCD30")[2]

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
    df.dateTime = collect(DateTime(2022,10,05,00,00,00):Second(time_to_round):data_frame.dateTime[length(data_frame.dateTime)])
    df = outerjoin( df,data_frame, on = :dateTime)
    sort!(df, (:dateTime))
    df = DataFrames.rename!(df, cols)
    df_sensor = Impute.locf(df)|>Impute.nocb()
    
    df_sensor = DataFrames.combine(DataFrames.groupby(df_sensor, :dateTime), cols[2:end] .=> mean)
    df_sensor = DataFrames.rename!(df_sensor, cols)
    return df_sensor
end

df_wind = dataframe_updates(data_frame_wind, cols_wind,"WIMDA")
df_tph = dataframe_updates(data_frame_tph,cols_tph,"BME680")
df_co2 = dataframe_updates(data_frame_c02,cols_c02,"SCD30")

# row_num_6hr_wind = findfirst(==(DateTime(2022,10,05,06,00,00)), df_wind.dateTime)
# row_num_6hr_tph = findfirst(==(DateTime(2022,10,05,06,00,00)), df_tph.dateTime)
# row_num_6hr_c02 = findfirst(==(DateTime(2022,10,05,06,00,00)), df_c02.dateTime)
# date_time_rounded = map((x) -> round(x, Dates.Second(5)), data_frame_wind.dateTime)
# df_agg = select(data_frame_wind,Not(:dateTime))
# gdf_date_time =  groupby((data_frame_wind, :date_time_rounded))


