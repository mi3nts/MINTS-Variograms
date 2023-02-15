using Pkg
Pkg.activate("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\LoRa")
using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions,Parsers

function data_cleaning( path_to_csv)
    data_frame = CSV.read(path_to_csv,DataFrame)
    ms = [parse(Float64,x[20:26]) for x in data_frame[!,:dateTime]]
    data_frame.ms  = Second.(round.(Int,ms))
    data_frame.dateTime = [x[1:19] for x in data_frame[!,:dateTime]]
    data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS")
    data_frame.dateTime = data_frame.dateTime + data_frame.ms
    data_frame = select!(data_frame, Not(:ms))
    col_symbols = Symbol.(names(data_frame))
    data_frame = DataFrames.combine(DataFrames.groupby(data_frame, :dateTime), col_symbols[2:end] .=> mean)
    return data_frame,col_symbols
end

path_to_ips7100 = "D://UTD//UTDFall2022//VariogramsLoRa//firmware//data//001e063739c7//2022//10//05//MINTS_001e063739c7_IPS7100_2022_10_05.csv"
col_symbols = data_cleaning(path_to_ips7100)[2]
data_frame = data_cleaning(path_to_ips7100)[1]


function rolling_variogram(data_frame,col) 
    df = DataFrame()
    df.dateTime = collect(data_frame.dateTime[1]:Second(1):data_frame.dateTime[length(data_frame.dateTime)])
    df = outerjoin( df,data_frame, on = :dateTime)
    sort!(df, (:dateTime))
    df = DataFrames.rename!(df, col_symbols)
    df = Impute.locf(df)|>Impute.nocb()
    df = df[1:86400,:]
    df_mat = df[:,2:end]
    mat = Matrix(df_mat[1:nrow(df),:])[:,col]
    arr_mat = Array{Float64}[]

    td= 900
    for i in td:1:nrow(df_mat)
        append!(arr_mat, [mat[i+1-td:i]]) 

    end
    range_vec = []
    sill_vec = []
    nugget_vec = []
    x = []

    for d in 1:1:length(arr_mat)

        for h in 1:1:(300)

            mat_head = arr_mat[d][1:td-h]
            mat_tail = arr_mat[d][1+h:td]
            append!(x,sum((mat_head - mat_tail).^2,dims=1)/(2*(td-h)))    
        end
        try
            push!(range_vec,findmaxima(x)[1][1]/60)
        catch e1
            push!(range_vec,missing)
        end
        try
            push!(sill_vec,findmaxima(x)[2][1])
        catch e2
            push!(sill_vec,missing)
        end
        push!(nugget_vec,Polynomials.fit(collect(1:1:300)./60,Float64.(x),7)(0))
        println(d)
        x=[]
    end

    ts = collect(data_frame.dateTime[1]+Minute(15):Second(1):data_frame.dateTime[length(data_frame.dateTime)])
    dict_pm = Dict(1=>"pc0.1",2=>"pc0.3",3=>"pc0.5",4=>"pc1.0",5=>"pc2.5",6=>"pc5.0",7=>"pc10.0",
                   8=>"pm0.1",9=>"pm0.3",10=>"pm0.5",11=>"pm1.0",12=>"pm2.5",13=>"pm5.0",14=>"pm10.0")

    df_parameters = DataFrame("TimeStamp"=>ts,dict_pm[col]*"_"*"Range" => range_vec[1:length(ts)] ,dict_pm[col]*"_"*"Sill" => sill_vec[1:length(ts)], dict_pm[col]*"_"*"Nugget" => nugget_vec[1:length(ts)] )
    
    # insert!(df_parameters,1,ts,:TimeStamp) 
    
    return df_parameters
end   
pc0_1_rolling_variogram = rolling_variogram(data_frame,1)
pc0_3_rolling_variogram = rolling_variogram(data_frame,2)
pc0_5_rolling_variogram = rolling_variogram(data_frame,3)
pc1_0_rolling_variogram = rolling_variogram(data_frame,4)
pc2_5_rolling_variogram = rolling_variogram(data_frame,5)
pc5_0_rolling_variogram = rolling_variogram(data_frame,6)
pc10_0_rolling_variogram = rolling_variogram(data_frame,7)
pm0_1_rolling_variogram = rolling_variogram(data_frame,8)
pm0_3_rolling_variogram = rolling_variogram(data_frame,9)
pm0_5_rolling_variogram = rolling_variogram(data_frame,10)
pm1_0_rolling_variogram = rolling_variogram(data_frame,11)
pm2_5_rolling_variogram = rolling_variogram(data_frame,12)
pm5_0_rolling_variogram = rolling_variogram(data_frame,13)
pm10_0_rolling_variogram = rolling_variogram(data_frame,14)

include("cn_wind_tph.jl")

td= 900
ts_wind = 2
ts_tph = 10
wd_rolling_mean = RollingFunctions.rolling(mean,df_wind.windDirectionTrue,Int(td/ts_wind))
ws_rolling_mean = RollingFunctions.rolling(mean,df_wind.windSpeedMetersPerSecond,Int(td/ts_wind))
ts_wind = collect(data_frame.dateTime[1]+Minute(15):Second(ts_wind):data_frame.dateTime[length(data_frame.dateTime)])

temp_rolling_mean = rolling(mean,df_tph.temperature,Int(td/ts_tph))
press_rolling_mean = rolling(mean,df_tph.pressure,Int(td/ts_tph))
hum_rolling_mean = rolling(mean,df_tph.humidity,Int(td/ts_tph))
ts_tph = collect(data_frame.dateTime[1]+Minute(15):Second(ts_tph):data_frame.dateTime[length(data_frame.dateTime)])


df_wind_avg = DataFrame(TimeStamp = ts_wind,
                        MeanWindSpeed = ws_rolling_mean[1:length(ws_rolling_mean)-1],
                        MeanWindDirection = wd_rolling_mean[1:length(ws_rolling_mean)-1])


df_tph_avg = DataFrame(TimeStamp = ts_tph,
                       MeanTemperature = temp_rolling_mean[1:length(temp_rolling_mean)-1],
                       MeanPressure = press_rolling_mean[1:length(press_rolling_mean)-1],
                       MeanHumidity = hum_rolling_mean[1:length(hum_rolling_mean)-1])

df_var_pc0_1 = outerjoin(pc0_1_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pc0_3 = outerjoin(pc0_3_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pc0_5 = outerjoin(pc0_5_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pc1_0 = outerjoin(pc1_0_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pc2_5 = outerjoin(pc2_5_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pc5_0 = outerjoin(pc5_0_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pc10_0 = outerjoin(pc10_0_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)

df_var_pm0_1 = outerjoin(pm0_1_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pm0_3 = outerjoin(pm0_3_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pm0_5 = outerjoin(pm0_5_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pm1_0 = outerjoin(pm1_0_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pm2_5 = outerjoin(pm2_5_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pm5_0 = outerjoin(pm5_0_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)
df_var_pm10_0 = outerjoin(pm10_0_rolling_variogram,df_wind_avg,df_tph_avg,on = :TimeStamp)

dict_pm_variogram = Dict("pc0.1"=>df_var_pc0_1,"pc0.3"=>df_var_pc0_3,"pc0.5"=>df_var_pc0_5,
                         "pc1.0"=>df_var_pc1_0,"pc2.5"=>df_var_pc2_5,"pc5.0"=>df_var_pc5_0,
                         "pc10.0"=>df_var_pc10_0,
                         "pm0.1"=>df_var_pm0_1,"pm0.3"=>df_var_pm0_3,"pm0.5"=>df_var_pm0_5,
                         "pm1.0"=>df_var_pm1_0,"pm2.5"=>df_var_pm2_5,"pm5.0"=>df_var_pm5_0,
                         "pm10.0"=>df_var_pm10_0)



dict_var_updated = Dict()
dict_plot_wind = Dict()
dict_plot_tph = Dict()

clim_vals = []
for (key,value) in dict_pm_variogram
    dict_var_updated[key] = dropmissing(dict_pm_variogram[key], [Symbol.(key*"_Range")])    
    dict_plot_wind[key] = dropmissing(dict_var_updated[key], [:MeanWindSpeed,:MeanWindDirection])
    dict_plot_wind[key] = select!(dict_plot_wind[key], Not([:MeanTemperature, :MeanPressure, :MeanHumidity]))
    dict_plot_tph[key] = dropmissing(dict_var_updated[key], [:MeanTemperature,:MeanPressure,:MeanHumidity])
    append!(clim_vals,dict_plot_tph[key][!,key*"_Range"])


    # mapcols(dict_plot_wind[key]) do col
    #     eltype(col) === Any ? Float64.(col) : col
    # end
        # mapcols(dict_plot_tph[key]) do col
    #     eltype(col) === Any ? Float64.(col) : col
    # end
end
path_to_dir = "D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\"
for i in 1:1:length(yearmonthday(df_var_pm0_1.TimeStamp[1]))
    if !(isdir(path_to_dir*"\\"*string(yearmonthday(df_var_pm0_1.TimeStamp[1])[i])))
        path_to_dir = path_to_dir*"\\"*string(yearmonthday(df_var_pm0_1.TimeStamp[1])[i])
        mkdir(path_to_dir) 
    else
        path_to_dir = path_to_dir*"\\"*string(yearmonthday(df_var_pm0_1.TimeStamp[1])[i])
    end
    println(i)
    println(path_to_dir)
end

path_to_var_csv = path_to_dir*"\\csv\\"
if !(isdir(path_to_var_csv))    
    mkdir(path_to_var_csv)
end 

path_to_var_tph_plots = path_to_dir*"\\tph_plots\\"
if !(isdir(path_to_var_tph_plots))    
    mkdir(path_to_var_tph_plots)
end    

path_to_var_wind_plots = path_to_dir*"\\wind_plots\\"
if !(isdir(path_to_var_wind_plots))    
    mkdir(path_to_var_wind_plots)
end    

#Try this up there before deleting missing values

dateTime = dict_var_updated["pm0.1"][:,1]
for (key,value) in dict_var_updated
    Range[key] = dict_var_updated[key][:,2]
    Sill[key] = dict_var_updated[key][:,3]
    Nugget[key] = dict_var_updated[key][:,4]
    CSV.write(path_to_var_csv*key*"_"*"Variogram_Parameters.csv",string.(dict_var_updated[key]))
    CSV.write(path_to_var_csv*key*"_"*"Variogram_Wind_Plots.csv",string.(dict_plot_wind[key]))
    CSV.write(path_to_var_csv*key*"_"*"Variogram_TPH_Plots.csv",string.(dict_plot_tph[key]))
end


findall( x -> occursin("Range", x),names(dict_pm_variogram["pm0.1"]))


clim_low = round(percentile(clim_vals,1 ); digits = 2)
clim_high = round(percentile(clim_vals,99 ); digits = 2)

strpm0_1 = "PM"*latexstring("_{0.1}")
strpm0_3 = "PM"*latexstring(" _{0.3}")
strpm0_5 = "PM"*latexstring("_{0.5}")
strpm1_0 = "PM"*latexstring("_{1.0}")
strpm2_5 = "PM"*latexstring("_{2.5}")
strpm5_0 = "PM"*latexstring("_{5.0}")
strpm10_0 = "PM"*latexstring("_{10.0}")
degree = L"$^{\circ}$"
dict = Dict("pm0.1"=>strpm0_1, "pm0.3"=>strpm0_3, "pm0.5"=>strpm0_5,"pm1.0"=>strpm1_0,"pm2.5"=>strpm2_5,"pm5.0"=>strpm5_0,"pm10.0"=>strpm10_0,)

gr()
for (key,value) in dict
    if !(isdir(path_to_var_tph_plots*"//"*key))    
        mkdir(path_to_var_tph_plots*"//"*key)
    end    
    
    Plots.scatter(Array(dict_plot_tph[key].MeanTemperature), Array(dict_plot_tph[key].MeanHumidity), zcolor=  Array(dict_plot_tph[key][!,key*"_Range"]),
    color=palette(:jet,length(unique(dict_plot_tph[key][!,key*"_Range"])),rev = true),xlabel ="Temperature("*degree*"C)" 
    ,ylabel= "Humidity (% r.H)",label = dict[key]*" Range",legend=:topright,markerstrokewidth=0,clims=(clim_low,clim_high),title=Date(df_var_pm0_1.TimeStamp[1]))
    

    png(path_to_var_tph_plots*"//"*key*"//"*"TH")

    Plots.scatter(Array(dict_plot_tph[key].MeanPressure), Array(dict_plot_tph[key].MeanHumidity), zcolor= Array(dict_plot_tph[key][!,key*"_Range"]),
    color=palette(:jet,length(unique(Array(dict_plot_tph[key][!,key*"_Range"]))),rev = true),xlabel ="Pressure(hPa)" 
    ,ylabel= "Humidity (% r.H)",label = dict[key]*" Range",legend=:topleft,markerstrokewidth=0,clims=(clim_low,clim_high),title=Date(df_var_pm0_1.TimeStamp[1]))

    png(path_to_var_tph_plots*"//"*key*"//"*"PH")

    Plots.scatter(Array(dict_plot_tph[key].MeanPressure), Array(dict_plot_tph[key].MeanTemperature), zcolor= Array(dict_plot_tph[key][!,key*"_Range"]),
    color=palette(:jet,length(unique(Array(dict_plot_tph[key][!,key*"_Range"]))),rev = true),xlabel ="Pressure(hPa)" 
    ,ylabel= "Temperature("*degree*"C)",label = dict[key]*" Range",legend=:bottomleft,markerstrokewidth=0,clims=(clim_low,clim_high),title=Date(df_var_pm0_1.TimeStamp[1]))

    png(path_to_var_tph_plots*"//"*key*"//"*"PT")
end


