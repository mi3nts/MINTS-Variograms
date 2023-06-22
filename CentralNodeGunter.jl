using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions

include("File_Search_trial.jl")
include("CentralNodeGunter_Wind_TPH.jl")

#--------------------------------- Start here------------------------------#

path_to_params = "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/daily" #path for csv files

#code to aggregate the data for the month of january
#changed the column names to fix the pm 0.5 error, code should be working for all time scales (e.g. month, year)
pm_month_arr = []
for i in 1:1:31
    if i < 10
        string_itr = "0" * string(i)
    else
        string_itr = string(i)
    end
    path = "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/" * string_itr * "/MINTS_001e0636e547_IPS7100_2023_01_" * string_itr * ".csv"
    push!(pm_month_arr, path)
end
println(pm_month_arr)

# df_pm_list = []
# for i in 1:1:126
#     push!(df_pm_list, CSV.read(df_pm_csv.IPS7100[i], DataFrame))
# end
# # Combining all the dataframes into a single dataframe
# data_frame_pm_combined = vcat(df_pm_list...,cols=:union)
# data_frame_pm_combined = CSV.read("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/03/MINTS_001e0636e547_IPS7100_2023_01_03.csv", DataFrame)

function data_cleaning(data_frame)
    ms = []

    for x in data_frame[!,:dateTime]
        try
            push!(ms,parse(Float64,x[20:26]))
        catch s1
            push!(ms,parse(Float64,"0.000000"))
        end
    end
    data_frame.ms  = Second.(round.(Int,ms))
    
    data_frame.dateTime = [x[1:19] for x in data_frame[!,:dateTime]]
    
    data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS") # Converting the dateime columns[1:19] to DateTime format in Julia
    data_frame.dateTime = data_frame.dateTime + data_frame.ms # Adding the converted date time to the millisecond that was rounded to seconds
    data_frame = select!(data_frame, Not(:ms)) # Deleting the ms column
    #col_symbols = Symbol.(names(data_frame)) 
    col_symbols = [:pc0_1, :pc0_3, :pc0_5, :pc1_0, :pc2_5, :pc5_0, :pc10_0 ,:pm0_1, :pm0_3, :pm0_5, :pm1_0, :pm2_5, :pm5_0, :pm10_0]

    for i in 1:1:nrow(data_frame)

        if (typeof(data_frame[!,:pc1_0][i]) == String)
            try
            data_frame[!,:pc1_0][i] =  parse(Float64, data_frame[!,:pc1_0][i])
            catch e1
            data_frame[!,:pc1_0][i] = missing
            end 
        end
        if (typeof(data_frame[!,:pm0_5][i]) == String31) 
            try
            data_frame[!,:pm0_5][i] =  parse(Float64, data_frame[!,:pm0_5][i])
            catch e2
                data_frame[!,:pm10_0][i] = missing
            end
        end
        if (typeof(data_frame[!,:pm10_0][i]) == String)
            try
            data_frame[!,:pm10_0][i] =  parse(Float64, data_frame[!,:pm10_0][i])
            catch e3
                data_frame[!,:pm10_0][i] = missing
            end
        end
        
        if (typeof(data_frame[!,:pc1_0][i]) == Int64)
            data_frame[!,:pc1_0][i] =  Float64(data_frame[!,:pc1_0][i])
        end
        if (typeof(data_frame[!,:pm0_5][i])== Int64)
            data_frame[!,:pm0_5][i] =  Float64(data_frame[!,:pm0_5][i])
        end
        if (typeof(data_frame[!,:pm10_0][i]) == Int64)
            data_frame[!,:pm10_0][i] =   Float64(data_frame[!,:pm10_0][i])
        end
        

    end

    # wl = filter(x -> isa.(x, String31), data_frame[!,:pm0_5])
    # y = findall(x -> x .== wl[1], data_frame[!,:pm0_5])
    # data_frame[!,:pm0_5][y] == missing

    data_frame = DataFrames.combine(DataFrames.groupby(data_frame, :dateTime), [:pc0_1, :pc0_3, :pc0_5, :pc1_0, :pc2_5, :pc5_0, :pc10_0, :pm0_1,:pm0_3, :pm0_5, :pm1_0,:pm2_5,:pm5_0, :pm10_0] .=> mean) # what exactly does this do

    return data_frame, col_symbols # returns the dataframe and column symbols
end

data_frame_pm, col_symbols = data_cleaning(data_frame_pm_combined)# Obtained the cleaned dataframe and column names
df_range = DataFrame()
df_sill = DataFrame()
df_nugget = DataFrame()

println(col_symbols)
function missing_data(data_frame)
    df = DataFrame()
    df.dateTime = collect(data_frame.dateTime[1]:Second(1):data_frame.dateTime[end])
    df = outerjoin( df,data_frame, on = :dateTime)[1:length(df.dateTime),:] 
    sort!(df, (:dateTime))
    #df = DataFrames.rename!(df, col_symbols)
    df = Impute.locf(df)|>Impute.nocb()
    return df
end

data_frame_pm_updated = missing_data(data_frame_pm)
#CSV.write("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/yearly/dfUpdatedYearly.csv", data_frame_pm_updated)

#data_frame_pm_updated = CSV.read("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/daily/dfUpdatedDaily.csv", DataFrame)
ts = collect(data_frame_pm_updated.dateTime[1]+Minute(15):Second(1):data_frame_pm_updated.dateTime[end] + Second(1))
data_frame_pm_updated_rolling_mean = DataFrame()

data_frame_pm_updated_rolling_mean.RollingTime = ts
for i in names(data_frame_pm_updated)[2:end]
    data_frame_pm_updated_rolling_mean[!,i] = RollingFunctions.rolling(mean,data_frame_pm_updated[!,i],Int(900))
end


function rolling_variogram(df,num) 
    col = num + 1
    df_mat = df[:,1:end]
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
        push!(nugget_vec,Polynomials.fit(collect(1:1:300)./60,Float64.(x),2)(0))
        println(d)

        x=[]
    end




    #df_parameters = DataFrame("TimeStamp"=>ts,dict_pm[col]*"_"*"Range" => range_vec[1:length(ts)] ,dict_pm[col]*"_"*"Sill" => sill_vec[1:length(ts)], dict_pm[col]*"_"*"Nugget" => nugget_vec[1:length(ts)] )
    
    # insert!(df_parameters,1,ts,:TimeStamp) 
    
    return range_vec, sill_vec, nugget_vec
end
# Created dataframes for range , sill and nugget values with the 15 minute rolling date time window
df_range.RollingTime = ts
df_sill.RollingTime = ts
df_nugget.RollingTime = ts

dict_pm = Dict(#1=>"pc0.1",2=>"pc0.3",3=>"pc0.5",4=>"pc1.0",5=>"pc2.5",6=>"pc5.0",7=>"pc10.0",
               8=>"pm0.1",9=>"pm0.3",10=>"pm0.5",11=>"pm1.0",12=>"pm2.5",13=>"pm5.0",14=>"pm10.0")

# Appending Range, Sill and Nugget values for each PC, PM column 
for i in 8:1:14
    println("##################################  ",i,"  #######################################")
    df_range[!,dict_pm[i]] = rolling_variogram(data_frame_pm_updated,i)[1]
end
CSV.write("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/daily/dfRangeDaily.csv", df_range)


for i in 1:1:14
    println("##################################  ",i,"  #######################################")
    df_sill[!,dict_pm[i]] = rolling_variogram(data_frame_pm_updated,i)[2]
end

for i in 1:1:14
    println("##################################  ",i,"  #######################################")
    df_nugget[!,dict_pm[i]] = rolling_variogram(data_frame_pm_updated,i)[3]  
end

##########################RUN UNTIL HERE TO GENERATE RANGE FOR PM VALUES################################

#df_parameters = DataFrame("TimeStamp"=>ts,dict_pm[col]*"_"*"Range" => range_vec[1:length(ts)] ,dict_pm[col]*"_"*"Sill" => sill_vec[1:length(ts)], dict_pm[col]*"_"*"Nugget" => nugget_vec[1:length(ts)] )
# insert!(df_parameters,1,ts,:TimeStamp) 

df_nugget = filter(row -> all(x -> x >= 0, row[2:end]), df_nugget)


td= 900
ts_wind = 2
ts_tph = 10

wd_rolling_mean = RollingFunctions.rolling(mean,df_wind.windDirectionTrue,Int(td/ts_wind))
ws_rolling_mean = RollingFunctions.rolling(mean,df_wind.windSpeedMetersPerSecond,Int(td/ts_wind))
rolling_time_wind = collect(df_wind.dateTime[1]+Minute(15):Second(ts_wind):df_wind.dateTime[end]+Second(ts_wind))


temp_rolling_mean = rolling(mean,df_tph.temperature,Int(td/ts_tph))
press_rolling_mean = rolling(mean,df_tph.pressure,Int(td/ts_tph))
hum_rolling_mean = rolling(mean,df_tph.humidity,Int(td/ts_tph))
rolling_time_tph = collect(df_tph.dateTime[1]+Minute(15):Second(ts_tph):df_tph.dateTime[end]+Second(ts_tph))


df_wind_avg = DataFrame(RollingTime = rolling_time_wind,
                        MeanWindSpeed = ws_rolling_mean,
                        MeanWindDirection = wd_rolling_mean)
println(df_wind_avg)

df_tph_avg = DataFrame(RollingTime = rolling_time_tph,
                       MeanTemperature = temp_rolling_mean,
                       MeanPressure = press_rolling_mean,
                       MeanHumidity = hum_rolling_mean)

#df_range = CSV.read("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/daily/dfRangeDaily.csv", DataFrame)
df_range_wind_tph_var = sort!(outerjoin(outerjoin(df_range,df_wind_avg,on = :RollingTime),df_tph_avg,on = :RollingTime),[:RollingTime])

# df_sill_wind_tph_var = sort!(outerjoin(outerjoin(df_sill,df_wind_avg,on = :RollingTime),df_tph_avg,on = :RollingTime),[:RollingTime])
# df_nugget_wind_tph_var = sort!(outerjoin(outerjoin(df_nugget,df_wind_avg,on = :RollingTime),df_tph_avg,on = :RollingTime),[:RollingTime])




csv_path_list = []
wind_path_list = []
tph_path_list = []

# Creating path for the each plot and csv file based on the date
unique_date_values = unique(yearmonthday.(data_frame_pm.dateTime))[1:7]# Its for a week



for j in 1:1:length(unique_date_values)
    path_to_dir = "D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters"
    for i in 1:1:length(unique_date_values[j])
        print(j)
        
        if !(isdir(path_to_dir*"/"*string(unique_date_values[j][i])))
            path_to_dir = path_to_dir*"/"*string(unique_date_values[j][i])
            mkdir(path_to_dir) 
        else
            path_to_dir = path_to_dir*"/"*string(unique_date_values[j][i])
        end
        println(i)
        println(path_to_dir)
    end
    path_to_var_csv = path_to_dir*"/csv/"
    push!(csv_path_list,path_to_var_csv)
    if !(isdir(path_to_var_csv))    
        mkdir(path_to_var_csv)
    end 

    path_to_var_tph_plots = path_to_dir*"/tph_plots/"
    push!(tph_path_list,path_to_var_tph_plots)
    if !(isdir(path_to_var_tph_plots))    
        mkdir(path_to_var_tph_plots)
    end    

    path_to_var_wind_plots = path_to_dir*"/wind_plots/"
    push!(wind_path_list,path_to_var_wind_plots)
    if !(isdir(path_to_var_wind_plots))    
        mkdir(path_to_var_wind_plots)
    end  
end



# path_to_params = "D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/csv/"
# mkpath(path_to_params)
# CSV.write(path_to_params*"DailyRange.csv",df_range)
# CSV.write(path_to_params*"DailySill.csv",df_sill)
# CSV.write(path_to_params*"DailyNugget.csv",df_nugget)
CSV.write(path_to_params*"Wind_TPH_Range.csv",df_range_wind_tph_var)
# CSV.write(path_to_params*"Wind_TPH_Sill.csv",df_sill_wind_tph_var)
# CSV.write(path_to_params*"Wind_TPH_Nugget.csv",df_nugget_wind_tph_var)

# df_range = CSV.read(path_to_params*"DailyRange.csv",DataFrame)
# df_sill = CSV.read(path_to_params*"DailySill.csv",DataFrame)
# df_nugget = CSV.read(path_to_params*"DailyNugget.csv",DataFrame)
df_range_wind_tph_var = CSV.read("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/daily/dailyWind_TPH_Range.csv",DataFrame)
# df_sill_wind_tph_var = CSV.read(path_to_params*"Wind_TPH_Sill.csv",DataFrame)
# df_nugget_wind_tph_var = CSV.read(path_to_params*"Wind_TPH_Nugget.csv",DataFrame)


data_frame_pm_updated = CSV.read("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/daily/dfUpdatedDaily.csv", DataFrame)
data_frame_pm_updated = DataFrames.rename!(data_frame_pm_updated,["dateTime"; ["pc0.1","pc0.3","pc0.5","pc1.0","pc2.5","pc5.0","pc10.0","pm0.1","pm0.3","pm0.5","pm1.0","pm2.5","pm5.0","pm10.0"]])
data_frame_pm_updated_rolling_mean = CSV.read("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/daily/PMRollingMeanDaily.csv", DataFrame)
data_frame_pm_updated_rolling_mean = DataFrames.rename!(data_frame_pm_updated_rolling_mean,names(df_range)[1:end-1])
function group_by_dates(df)
    df.date = Date.(df[!,names(df)[1]]) 
    df_groupedby_dates = groupby(df, :date)
    vec_df = [] 
    for i in unique(df.date)#[1:7]
        push!(vec_df,DataFrame(df_groupedby_dates[Dict(:date => i)]))
    end
    return vec_df
end
# vec_df_range = group_by_dates(df_range_wind_tph_var) # This will have the range, temperature, pressure,humidity and wind values
# vec_df_sill = group_by_dates(df_sill_wind_tph_var) # This will have the range, temperature, pressure,humidity and wind values
vec_df_pm = group_by_dates(data_frame_pm_updated)

vec_df_pm_mean = group_by_dates(data_frame_pm_updated_rolling_mean)


# function percentile_limits(df)
#     lim_low = round(percentile(skipmissing(reduce(vcat,[df[:,i] for i in names(df)])),1 ); digits = 2)
#     lim_high = round(percentile(skipmissing(reduce(vcat,[df[:,i] for i in names(df)])),99 ); digits = 2)
#     return [lim_low,lim_high]
# end
# clim_vals_pc  = percentile_limits(vec_df_range[3][:,2:8])
# clim_vals_pm  = percentile_limits(vec_df_range[3][:,9:15])
# clim_vals_ws  = percentile_limits(vec_df_range[3][:,17:17])
# clim_vals_wd  = percentile_limits(vec_df_range[3][:,18:18])


# ############################################################ Fixed Till here #######################################################################################


strpc0_1 = "Particle Count for "*"PM"*latexstring("_{0.1}")
strpc0_3 = "Particle Count for "*"PM"*latexstring(" _{0.3}")
strpc0_5 = "Particle Count for "*"PM"*latexstring("_{0.5}")
strpc1_0 = "Particle Count for "*"PM"*latexstring("_{1.0}")
strpc2_5 = "Particle Count for "*"PM"*latexstring("_{2.5}")
strpc5_0 = "Particle Count for "*"PM"*latexstring("_{5.0}")
strpc10_0 = "Particle Count for "*"PM"*latexstring("_{10.0}")
strpm0_1 = "PM"*latexstring("_{0.1}")
strpm0_3 = "PM"*latexstring(" _{0.3}")
strpm0_5 = "PM"*latexstring("_{0.5}")
strpm1_0 = "PM"*latexstring("_{1.0}")
strpm2_5 = "PM"*latexstring("_{2.5}")
strpm5_0 = "PM"*latexstring("_{5.0}")
strpm10_0 = "PM"*latexstring("_{10.0}")
degree = L"$^{\circ}$"
degree_wind_angle = L"${\circ}$"
dict_plot_pc = OrderedDict("pc0.1"=>strpc0_1, "pc0.3"=>strpc0_3, "pc0.5"=>strpc0_5,"pc1.0"=>strpc1_0,"pc2.5"=>strpc2_5,"pc5.0"=>strpc5_0,"pc10.0"=>strpc10_0)
dict_plot_pm = OrderedDict("pm0.1"=>strpm0_1, "pm0.3"=>strpm0_3, "pm0.5"=>strpm0_5,"pm1.0"=>strpm1_0,"pm2.5"=>strpm2_5,"pm5.0"=>strpm5_0,"pm10.0"=>strpm10_0)

gr()
jet_r = reverse(cgrad(:jet))

# function tph_plots(tph_path_list,vec_df,dict_plot,clim_vals,jet_r,degree)
#     for i in 1:1:length(tph_path_list)
#         for (key,value) in dict_plot
#             if !(isdir(tph_path_list[i]*"/"*key))    
#                 mkdir(tph_path_list[i]*"/"*key)
#             end    
            
#             Plots.scatter(dropmissing(vec_df[i],key).MeanTemperature, dropmissing(vec_df[i],key).MeanHumidity, 
#             zcolor =  dropmissing(vec_df[i],key)[!,key],markerstrokewidth=0,color = jet_r , xlabel ="Temperature("*degree*"C)",ylabel= "Humidity (% r.H)",
#             legend = false, colorbar = true, colorbar_title = " \n"*dict_plot[key]*" Range (mins)",clims=(clim_vals[1],clim_vals[2]),right_margin = 5Plots.mm,
#             title = Date(vec_df[i].RollingTime[1]))

#             png(tph_path_list[i]*"/"*key*"/"*"TH")

#             Plots.scatter(dropmissing(vec_df[i],key).MeanPressure, dropmissing(vec_df[i],key).MeanHumidity, 
#             zcolor =  dropmissing(vec_df[i],key)[!,key],markerstrokewidth=0,color = jet_r ,xlabel ="Pressure(hPa)",ylabel= "Humidity (% r.H)",
#             legend = false, colorbar = true, colorbar_title = " \n"*dict_plot[key]*" Range (mins)", clims=(clim_vals[1],clim_vals[2]),right_margin = 5Plots.mm,
#             title = Date(vec_df[i].RollingTime[1]))

#             png(tph_path_list[i]*"/"*key*"/"*"PH")

#             Plots.scatter(dropmissing(vec_df[i],key).MeanPressure, dropmissing(vec_df[i],key).MeanTemperature, 
#             zcolor = dropmissing(vec_df[i],key)[!,key], markerstrokewidth=0,color = jet_r , xlabel ="Pressure(hPa)",ylabel= "Temperature("*degree*"C)",
#             legend = false, colorbar = true, colorbar_title = " \n"*dict_plot[key]*" Range (mins)", clims=(clim_vals[1],clim_vals[2]),right_margin = 5Plots.mm,
#             title = Date(vec_df[i].RollingTime[1]))

#             png(tph_path_list[i]*"/"*key*"/"*"PT")
#         end
#     end
# end
# pc_tph_plots = tph_plots(tph_path_list,vec_df_range,dict_plot_pc,clim_vals_pc,jet_r,degree)
# pm_tph_plots = tph_plots(tph_path_list,vec_df_range,dict_plot_pm,clim_vals_pm,jet_r,degree)

# i = 3
# key = "MeanWindSpeed"
# Plots.scatter(dropmissing(vec_df_range[i],key).MeanTemperature, dropmissing(vec_df_range[i],key).MeanHumidity, 
# zcolor =  dropmissing(vec_df_range[i],key)[!,key],markerstrokewidth=0,color = jet_r , xlabel ="Temperature("*degree*"C)",ylabel= "Humidity (% r.H)",
# legend = false, colorbar = true, colorbar_title = "\n Mean Wind Speed(m/s)",clims=(clim_vals_ws[1],clim_vals_ws[2]),right_margin = 5Plots.mm,
# title = Date(vec_df_range[i].RollingTime[1]))

# png(tph_path_list[i]*"TH "*key)

# Plots.scatter(dropmissing(vec_df_range[i],key).MeanPressure, dropmissing(vec_df_range[i],key).MeanHumidity, 
# zcolor =  dropmissing(vec_df_range[i],key)[!,key],markerstrokewidth=0,color = jet_r ,xlabel ="Pressure(hPa)",ylabel= "Humidity (% r.H)",
# legend = false, colorbar = true, colorbar_title = "\n Mean Wind Speed(m/s)", clims=(clim_vals_ws[1],clim_vals_ws[2]),right_margin = 5Plots.mm,
# title = Date(vec_df_range[i].RollingTime[1]))

# png(tph_path_list[i]*"PH "*key)

# Plots.scatter(dropmissing(vec_df_range[i],key).MeanPressure, dropmissing(vec_df_range[i],key).MeanTemperature, 
# zcolor = dropmissing(vec_df_range[i],key)[!,key], markerstrokewidth=0,color = jet_r , xlabel ="Pressure(hPa)",ylabel= "Temperature("*degree*"C)",
# legend = false, colorbar = true, colorbar_title = "\n Mean Wind Speed(m/s)", clims=(clim_vals_ws[1],clim_vals_ws[2]),right_margin = 5Plots.mm,
# title = Date(vec_df_range[i].RollingTime[1]))

# png(tph_path_list[i]*"PT "*key)



# i = 3
# key = "MeanWindDirection"
# Plots.scatter(dropmissing(vec_df_range[i],key).MeanTemperature, dropmissing(vec_df_range[i],key).MeanHumidity, 
# zcolor =  dropmissing(vec_df_range[i],key)[!,key],markerstrokewidth=0,color = :jet , xlabel ="Temperature("*degree*"C)",ylabel= "Humidity (% r.H)",
# legend = false, colorbar = true, colorbar_title = "\n Mean Wind Direction",clims=(clim_vals_wd[1],clim_vals_wd[2]),right_margin = 5Plots.mm,
# title = Date(vec_df_range[i].RollingTime[1]))

# png(tph_path_list[i]*"TH "*key)

# Plots.scatter(dropmissing(vec_df_range[i],key).MeanPressure, dropmissing(vec_df_range[i],key).MeanHumidity, 
# zcolor =  dropmissing(vec_df_range[i],key)[!,key],markerstrokewidth=0,color = jet_r ,xlabel ="Pressure(hPa)",ylabel= "Humidity (% r.H)",
# legend = false, colorbar = true, colorbar_title = "\n Mean Wind Direction", clims=(clim_vals_wd[1],clim_vals_wd[2]),right_margin = 5Plots.mm,
# title = Date(vec_df_range[i].RollingTime[1]))

# png(tph_path_list[i]*"PH "*key)

# Plots.scatter(dropmissing(vec_df_range[i],key).MeanPressure, dropmissing(vec_df_range[i],key).MeanTemperature, 
# zcolor = dropmissing(vec_df_range[i],key)[!,key], markerstrokewidth=0,color = jet_r , xlabel ="Pressure(hPa)",ylabel= "Temperature("*degree*"C)",
# legend = false, colorbar = true, colorbar_title = "\n Mean Wind Direction", clims=(clim_vals_wd[1],clim_vals_wd[2]),right_margin = 5Plots.mm,
# title = Date(vec_df_range[i].RollingTime[1]))

# png(tph_path_list[i]*"PT "*key)











#Create a time series with pm and range
pm_unit = "(μg/m"*latexstring("^3")*")"
gr()
tm_ticks = range(Time(vec_df_pm[1].dateTime[1]),Time(vec_df_pm[1].dateTime[end]),step = Hour(3))
ticks = string.(collect(tm_ticks))
println(vec_df_pm)

Plots.scatter(Time.(vec_df_pm[1].dateTime),vec_df_pm[1][!,"pm0.1"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm0.1"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].dateTime),vec_df_pm[3][!,"pm0.3"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm0.3"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].dateTime),vec_df_pm[3][!,"pm0.5"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm0.5"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].dateTime),vec_df_pm[3][!,"pm1.0"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm1.0"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].dateTime),vec_df_pm[3][!,"pm2.5"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm2.5"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].dateTime),vec_df_pm[3][!,"pm5.0"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm5.0"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].dateTime),vec_df_pm[3][!,"pm10.0"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations "*pm_unit, label = dict_plot_pm["pm10.0"], 
     legend = :right, legendfontsize=10, xrotation = 30)

png("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/PMTimeSeries")




Plots.scatter(Time.(vec_df_pm_mean[3].RollingTime),vec_df_pm_mean[3][!,"pm0.1"], xlabel = "01-03-2023 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm0.1"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_mean[3].RollingTime),vec_df_pm_mean[3][!,"pm0.3"], xlabel = "01-03-2023 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm0.3"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_mean[3].RollingTime),vec_df_pm_mean[3][!,"pm0.5"], xlabel = "01-03-2023 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm0.5"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_mean[3].RollingTime),vec_df_pm_mean[3][!,"pm1.0"], xlabel = "01-03-2023 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm1.0"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_mean[3].RollingTime),vec_df_pm_mean[3][!,"pm2.5"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm2.5"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_mean[3].RollingTime),vec_df_pm_mean[3][!,"pm5.0"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm5.0"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_mean[3].RollingTime),vec_df_pm_mean[3][!,"pm10.0"], xlabel = "01-03-2023",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm10.0"], 
     legend = :right, legendfontsize=10, xrotation = 30)

png("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/PMRollingTimeSeries")



Plots.scatter(Time.(vec_df_range[3].RollingTime),vec_df_range[3][!,"pm0.1"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM Range/Time Duration(mins)", label = dict_plot_pm["pm0.1"], 
     legend = :outertopright, legendfontsize=10, xrotation = 30,)
Plots.scatter!(Time.(vec_df_range[3].RollingTime),vec_df_range[3][!,"pm0.3"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM Range/Time Duration(mins)", label = dict_plot_pm["pm0.3"], 
     legend = :outertopright, legendfontsize=10, xrotation = 30,)
Plots.scatter!(Time.(vec_df_range[3].RollingTime),vec_df_range[3][!,"pm0.5"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM Range/Time Duration(mins)", label = dict_plot_pm["pm0.5"], 
     legend = :outertopright, legendfontsize=10, xrotation = 30,)
Plots.scatter!(Time.(vec_df_range[3].RollingTime),vec_df_range[3][!,"pm1.0"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM Range/Time Duration(mins)", label = dict_plot_pm["pm1.0"], 
     legend = :outertopright, legendfontsize=10, xrotation = 30,)
Plots.scatter!(Time.(vec_df_range[3].RollingTime),vec_df_range[3][!,"pm2.5"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM Range/Time Duration(mins)", label = dict_plot_pm["pm2.5"], 
     legend = :outertopright, legendfontsize=10, xrotation = 30,)
Plots.scatter!(Time.(vec_df_range[3].RollingTime),vec_df_range[3][!,"pm5.0"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM Range/Time Duration(mins)", label = dict_plot_pm["pm5.0"], 
     legend = :outertopright, legendfontsize=10, xrotation = 30,)
Plots.scatter!(Time.(vec_df_range[3].RollingTime),vec_df_range[3][!,"pm10.0"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM Range/Time Duration(mins)", label = dict_plot_pm["pm10.0"], 
     legend = :outertopright, legendfontsize=10, xrotation = 30,)
png("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/PMRangeTimeSeries")



#Creating a vector of distributions for each minute 

function group_by_minute(df)
    df.minute = floor.(df[!,names(df)[1]], Dates.Minute) 
    df_groupedby_minutes= groupby(df, :minute)

    vec_df = [] 
    for i in unique(df.minute)
        push!(vec_df,DataFrame(df_groupedby_minutes[Dict(:minute => i)]))
    end
    return vec_df
end
df_pm_minutue_wise = group_by_minute(vec_df_pm[3])
df_pm_mean_minutue_wise = group_by_minute(vec_df_pm_mean[3])
df_pm_range_minutue_wise = group_by_minute(vec_df_range[3])


function  Df_percentiles(df,col_str)
    df_percentile = DataFrame([name => [] for name in ["percentile_5","percentile_25","percentile_75","percentile_95"]])

    for i in df
        push!(df_percentile.percentile_5,percentile(skipmissing(i[!,col_str]),0.05))
        push!(df_percentile.percentile_25, percentile(skipmissing(i[!,col_str]),0.25))
        push!(df_percentile.percentile_75, percentile(skipmissing(i[!,col_str]),0.75))
        push!(df_percentile.percentile_95, percentile(skipmissing(i[!,col_str]),0.95))
    end
    return df_percentile
end  
df_pm_percentiles = Df_percentiles(df_pm_minutue_wise,"pm2.5")
df_pm_mean_percentiles =  Df_percentiles(df_pm_mean_minutue_wise,"pm2.5")
df_pm_range_percentiles =  Df_percentiles(df_pm_range_minutue_wise,"pm2.5")
df_wind_speed_percentiles =  Df_percentiles(df_pm_range_minutue_wise,"MeanWindSpeed")
df_wind_direction_percentiles =  Df_percentiles(df_pm_range_minutue_wise,"MeanWindDirection")

plot()
p1 = plot(Time.(dropmissing(vec_df_pm[3],"pm2.5").dateTime), dropmissing(vec_df_pm[3],"pm2.5")[!,"pm2.5"],
          xticks = Time("00:00"):Hour(3):Time("23:59"),ylims=(0,maximum(dropmissing(vec_df_pm[3],"pm2.5")[!,"pm2.5"])),
           ribbon = (df_pm_percentiles.percentile_25,df_pm_percentiles.percentile_75),title = "PM Concenteration "*pm_unit)

p2 = plot(Time.(dropmissing(vec_df_pm_mean[3],"pm2.5").RollingTime), dropmissing(vec_df_pm_mean[3],"pm2.5")[!,"pm2.5"],
          xticks = Time("00:00"):Hour(3):Time("23:59"), ylims=(0,maximum(dropmissing(vec_df_pm_mean[3],"pm2.5")[!,"pm2.5"])+5),
          ribbon = (df_pm_mean_percentiles.percentile_25,df_pm_mean_percentiles.percentile_75),title = "Rolling Mean of PM Concenteration "*pm_unit)


p3 = plot(Time.(dropmissing(vec_df_range[3],"pm2.5").RollingTime), dropmissing(vec_df_range[3],"pm2.5")[!,"pm2.5"],
          xticks = Time("00:00"):Hour(3):Time("23:59"), ylims=(0,maximum(dropmissing(vec_df_range[3],"pm2.5")[!,"pm2.5"])),
          ribbon = (df_pm_range_percentiles.percentile_25,df_pm_range_percentiles.percentile_75),title = "PM Range in minutes")


p4 = plot(Time.(dropmissing(vec_df_range[3],"MeanWindSpeed").RollingTime),dropmissing(vec_df_range[3],"MeanWindSpeed")[!,"MeanWindSpeed"],
                xticks = Time("00:00"):Hour(3):Time("23:59"),ylims=(0,maximum(dropmissing(vec_df_range[3],"MeanWindSpeed")[!,"MeanWindSpeed"])+5),
                ribbon = (df_wind_speed_percentiles.percentile_25,df_wind_speed_percentiles.percentile_75),title = "Rolling Mean of Wind Speed(m/s)")

p5 = plot(Time.(dropmissing(vec_df_range[3],"MeanWindDirection").RollingTime),dropmissing(vec_df_range[3],"MeanWindDirection")[!,"MeanWindDirection"],
          xticks = Time("00:00"):Hour(3):Time("23:59"),ylims=(0,360),
          ribbon = (df_wind_direction_percentiles.percentile_25,df_wind_direction_percentiles.percentile_75)
          ,title = "Rolling Mean of Wind Direction in ("*degree_wind_angle*")")

plot(p1,p2,p3,p4,p5,layout=(5,1), xrotation = 30,size = (800,800),legend = false,ylabel="")

png("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/PM2.5")



# gr()
# plot()
# p1 = Plots.plot(Time.(dropmissing(vec_df_pm[3],"pm2.5").dateTime),dropmissing(vec_df_pm[3],"pm2.5")[!,"pm2.5"]*u"m";ribbon = 50u"m",title = dict_plot_pm["pm2.5"]*" Concentration"*pm_unit )
# p2 = Plots.plot(Time.(dropmissing(vec_df_pm_mean[3],"pm2.5").RollingTime),dropmissing(vec_df_pm_mean[3],"pm2.5")[!,"pm2.5"]*u"m";ribbon = 5u"m",title = "Rolling Mean of "*dict_plot_pm["pm2.5"]*" Concentration"*pm_unit)
# p3 = Plots.plot(Time.(dropmissing(vec_df_range[3],"pm2.5").RollingTime),dropmissing(vec_df_range[3],"pm2.5")[!,"pm2.5"]*u"m";ribbon = 1u"m",title = dict_plot_pm["pm2.5"]*" Range/TimeScale(mins)")
# p4 = Plots.plot(Time.(dropmissing(vec_df_range[3],"MeanWindSpeed").RollingTime),dropmissing(vec_df_range[3],"MeanWindSpeed")[!,"MeanWindSpeed"]*u"m";ribbon = 1u"m",title = "Rolling Mean of Wind Speed(m/s)")
# p5 = Plots.plot(Time.(dropmissing(vec_df_range[3],"MeanWindDirection").RollingTime),dropmissing(vec_df_range[3],"MeanWindDirection")[!,"MeanWindDirection"]*u"m";ribbon = 25u"m",title = "Rolling Mean of Wind Direction("*degree*")")

# plot(p1,p2,p3,p4,p5,layout=(5,1), xrotation = 30,size=(1500,1500),legend = false,ylabel="")

# png("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/PM2.5")


