# Activating the variogram enviornmment
using Pkg
Pkg.activate("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/LoRa")
using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions
#Including the wind data after analysis nad also the files search script 
#include("File_Search_trial.jl")
include("CentralNodeGunter_Wind_TPH.jl")

# Loading the packages
using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions,Parsers

# Write a function for this part taking in the start date and end date for which the files have to be combined or do aquery from the database
#--------------------------------- Start here------------------------------#
# Creating a list of PM dataframe by reading in filenames for each day
df_pm_list = []
for i in 1:1:7
    push!(df_pm_list, CSV.read(df_pm_csv.IPS7100[i],DataFrame))
end
# Combining all the dataframes into a single dataframe
data_frame_pm_combined = reduce(vcat,df_pm_list)
#--------------------------------- End here------------------------------#



# Function for cleaning the data
function data_cleaning( data_frame)
    ms = [parse(Float64,x[20:26]) for x in data_frame[!,:dateTime]] # Taking in string datetime's millisecond part
    data_frame.ms  = Second.(round.(Int,ms)) # Rounding it to the nearest millisecond and converting it to seconds
    data_frame.dateTime = [x[1:19] for x in data_frame[!,:dateTime]]
    data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS") # Converting the dateime columns[1:19] to DateTime format in Julia
    data_frame.dateTime = data_frame.dateTime + data_frame.ms # Adding the converted date time to the millisecond that was rounded to seconds
    data_frame = select!(data_frame, Not(:ms)) # Deleting the ms column
    col_symbols = Symbol.(names(data_frame)) # Column symbols are saved to a variable(Names and Symbols are similar both are for obtaining the column names)
    data_frame = DataFrames.combine(DataFrames.groupby(data_frame, :dateTime), col_symbols[2:end] .=> mean) # taking the mean of all columns as there may be 
    # columns with the same datetime.   
    return data_frame,col_symbols # returns the dataframe and column symbols
end

data_frame_pm,col_symbols = data_cleaning(data_frame_pm_combined)# Obtained the cleaned dataframe and column names

df_range = DataFrame()
df_sill = DataFrame()
df_nugget = DataFrame()


function missing_data(data_frame)
    df = DataFrame()
    df.dateTime = collect(data_frame.dateTime[1]:Second(1):data_frame.dateTime[end])
    df = outerjoin( df,data_frame, on = :dateTime)[1:length(df.dateTime),:]
    #=========================================================================================#   
    #df = outerjoin( df,data_frame, on = :dateTime)[1:2000,:] # repalce this with the above statement
    #=========================================================================================#   
    sort!(df, (:dateTime))
    df = DataFrames.rename!(df, col_symbols)
    df = Impute.locf(df)|>Impute.nocb()
    return df
end
data_frame_pm_updated = missing_data(data_frame_pm)
function rolling_variogram(df,col) 
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




    #df_parameters = DataFrame("TimeStamp"=>ts,dict_pm[col]*"_"*"Range" => range_vec[1:length(ts)] ,dict_pm[col]*"_"*"Sill" => sill_vec[1:length(ts)], dict_pm[col]*"_"*"Nugget" => nugget_vec[1:length(ts)] )
    
    # insert!(df_parameters,1,ts,:TimeStamp) 
    
    return range_vec,sill_vec,nugget_vec
end
# created the rolling time window
ts = collect(data_frame_pm.dateTime[1]+Minute(15):Second(1):data_frame_pm.dateTime[end] + Second(1))
# Created dataframes for range , sill and nugget values with the 15 minute rolling date time window
df_range.RollingTime = ts
df_sill.RollingTime = ts
df_nugget.RollingTime = ts

dict_pm = Dict(1=>"pc0.1",2=>"pc0.3",3=>"pc0.5",4=>"pc1.0",5=>"pc2.5",6=>"pc5.0",7=>"pc10.0",
               8=>"pm0.1",9=>"pm0.3",10=>"pm0.5",11=>"pm1.0",12=>"pm2.5",13=>"pm5.0",14=>"pm10.0")

# Appending Range, Sill and Nugget values for each PC, PM column 
for i in 1:1:14
    println("##################################  ",i,"  #######################################")
    df_range[!,dict_pm[i]] = rolling_variogram(data_frame_pm,i)[1]
    df_sill[!,dict_pm[i]] = rolling_variogram(data_frame_pm,i)[2]
    df_nugget[!,dict_pm[i]] = rolling_variogram(data_frame_pm,i)[3]
end



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


df_tph_avg = DataFrame(RollingTime = rolling_time_tph,
                       MeanTemperature = temp_rolling_mean,
                       MeanPressure = press_rolling_mean,
                       MeanHumidity = hum_rolling_mean)

df_range_wind_tph_var = outerjoin(outerjoin(df_range,df_wind_avg,on = :RollingTime),df_tph_avg,on = :RollingTime)
df_sill_wind_tph_var = outerjoin(outerjoin(df_sill,df_wind_avg,on = :RollingTime),df_tph_avg,on = :RollingTime)
#df_nugget_wind_tph_var = outerjoin(outerjoin(df_nugget,df_wind_avg,on = :RollingTime),df_tph_avg,on = :RollingTime)




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



path_to_params = "D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/csv/"
mkpath(path_to_params)
CSV.write(path_to_params*"Range.csv",df_range)
CSV.write(path_to_params*"Sill.csv",df_sill)
CSV.write(path_to_params*"Wind_TPH_Range.csv",df_range_wind_tph_var)
CSV.write(path_to_params*"Wind_TPH_Sill.csv",df_sill_wind_tph_var)

# df_range = CSV.read(path_to_params*"Range.csv",DataFrame)
# df_sill = CSV.read(path_to_params*"Sill.csv",DataFrame)
# df_range_wind_tph_var = CSV.read(path_to_params*"Wind_TPH_Range.csv",DataFrame)
# df_sill_wind_tph_var = CSV.read(path_to_params*"Wind_TPH_Sill.csv",DataFrame)


df_range_wind_tph_var.date = Date.(df_range_wind_tph_var.RollingTime) 
df_range_groupedby_dates = groupby(df_range_wind_tph_var, :date)
vec_df_range = []
for i in unique(df_range_wind_tph_var.date)
    push!(vec_df_range,DataFrame(df_range_groupedby_dates[Dict(:date => i)]))
end


df_sill_wind_tph_var.date = Date.(df_sill_wind_tph_var.RollingTime) 
df_sill_groupedby_dates = groupby(df_sill_wind_tph_var, :date)
vec_df_sill= []
for i in unique(df_sill_wind_tph_var.date)
    push!(vec_df_sill,DataFrame(df_sill_groupedby_dates[Dict(:date => i)]))
end





function percentile_limits(df)
    lim_low = round(percentile(skipmissing(reduce(vcat,[df[:,i] for i in names(df)])),1 ); digits = 2)
    lim_high = round(percentile(skipmissing(reduce(vcat,[df[:,i] for i in names(df)])),99 ); digits = 2)
    return [lim_low,lim_high]
end
clim_vals_pc  = percentile_limits(df_range[:,2:8])
clim_vals_pm  = percentile_limits(df_range[:,9:15])


############################################################ Fixed Till here #######################################################################################






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
dict_plot_pc = OrderedDict("pc0.1"=>strpc0_1, "pc0.3"=>strpc0_3, "pc0.5"=>strpc0_5,"pc1.0"=>strpc1_0,"pc2.5"=>strpc2_5,"pc5.0"=>strpc5_0,"pc10.0"=>strpc10_0)
dict_plot_pm = OrderedDict("pm0.1"=>strpm0_1, "pm0.3"=>strpm0_3, "pm0.5"=>strpm0_5,"pm1.0"=>strpm1_0,"pm2.5"=>strpm2_5,"pm5.0"=>strpm5_0,"pm10.0"=>strpm10_0)

gr()
jet_r = reverse(cgrad(:jet))

function tph_plots(tph_path_list,vec_df,dict_plot,clim_vals,jet_r,degree)
    for i in 1:1:length(tph_path_list)
        for (key,value) in dict_plot
            if !(isdir(tph_path_list[i]*"/"*key))    
                mkdir(tph_path_list[i]*"/"*key)
            end    
            
            Plots.scatter(dropmissing(vec_df[i],key).MeanTemperature, dropmissing(vec_df[i],key).MeanHumidity, 
            zcolor =  dropmissing(vec_df[i],key)[!,key],markerstrokewidth=0,color = jet_r , xlabel ="Temperature("*degree*"C)",ylabel= "Humidity (% r.H)",
            legend = false, colorbar = true, colorbar_title = " \n"*dict_plot[key]*" Range (mins)",clims=(clim_vals[1],clim_vals[2]),right_margin = 5Plots.mm,
            title = Date(vec_df[i].RollingTime[1]))

            png(tph_path_list[i]*"/"*key*"/"*"TH")

            Plots.scatter(dropmissing(vec_df[i],key).MeanPressure, dropmissing(vec_df[i],key).MeanHumidity, 
            zcolor =  dropmissing(vec_df[i],key)[!,key],markerstrokewidth=0,color = jet_r ,xlabel ="Pressure(hPa)",ylabel= "Humidity (% r.H)",
            legend = false, colorbar = true, colorbar_title = " \n"*dict_plot[key]*" Range (mins)", clims=(clim_vals[1],clim_vals[2]),right_margin = 5Plots.mm,
            title = Date(vec_df[i].RollingTime[1]))

            png(tph_path_list[i]*"/"*key*"/"*"PH")

            Plots.scatter(dropmissing(vec_df[i],key).MeanPressure, dropmissing(vec_df[i],key).MeanTemperature, 
            zcolor = dropmissing(vec_df[i],key)[!,key], markerstrokewidth=0,color = jet_r , xlabel ="Pressure(hPa)",ylabel= "Temperature("*degree*"C)",
            legend = false, colorbar = true, colorbar_title = " \n"*dict_plot[key]*" Range (mins)", clims=(clim_vals[1],clim_vals[2]),right_margin = 5Plots.mm,
            title = Date(vec_df[i].RollingTime[1]))

            png(tph_path_list[i]*"/"*key*"/"*"PT")
        end
    end
end
pc_tph_plots = tph_plots(tph_path_list,vec_df_range,dict_plot_pc,clim_vals_pc,jet_r,degree)
pm_tph_plots = tph_plots(tph_path_list,vec_df_range,dict_plot_pm,clim_vals_pm,jet_r,degree)

data_frame_pm_updated.date = Date.(data_frame_pm_updated.dateTime)
df_pm_updated_groupedby_dates = groupby(data_frame_pm_updated, :date)
vec_df_pm_updated = []
for i in unique(data_frame_pm_updated.date)
    push!(vec_df_pm_updated,DataFrame(df_pm_updated_groupedby_dates[Dict(:date => i)]))
end




data_frame_pm_updated_rolling_mean = DataFrame()
data_frame_pm_updated_rolling_mean.RollingTime = ts
for i in names(data_frame_pm_updated)[2:end]
    data_frame_pm_updated_rolling_mean[!,i] = RollingFunctions.rolling(mean,data_frame_pm_updated[!,i],Int(900))
end

data_frame_pm_updated = DataFrames.rename!(data_frame_pm_updated, ["dateTime";names(df_range)[2:end-1]]) 


data_frame_pm_updated_rolling_mean = DataFrames.rename!(data_frame_pm_updated_rolling_mean, ["RollingTime";names(df_range)[2:end-1]]) 
data_frame_pm_updated_rolling_mean.date = Date.(data_frame_pm_updated_rolling_mean.RollingTime)
df_pm_groupedby_dates = groupby(data_frame_pm_updated_rolling_mean, :date)
vec_df_pm = []
for i in unique(data_frame_pm_updated_rolling_mean.date)
    push!(vec_df_pm,DataFrame(df_pm_groupedby_dates[Dict(:date => i)]))
end







#Create a time series with pm and range
pm_unit = "(μg/m"*latexstring("^3")*")"
gr()
tm_ticks = range(Time(vec_df_pm[3].RollingTime[1]),Time(vec_df_pm[3].RollingTime[end]),step =Hour(3))
tm = string.(collect(tm_ticks))


Plots.scatter(Time.(vec_df_pm_updated[3].dateTime),vec_df_pm_updated[3][!,"pm0.1"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm0.1"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_updated[3].dateTime),vec_df_pm_updated[3][!,"pm0.3"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm0.3"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_updated[3].dateTime),vec_df_pm_updated[3][!,"pm0.5"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm0.5"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_updated[3].dateTime),vec_df_pm_updated[3][!,"pm1.0"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm1.0"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_updated[3].dateTime),vec_df_pm_updated[3][!,"pm2.5"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm1.0"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_updated[3].dateTime),vec_df_pm_updated[3][!,"pm5.0"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations"*pm_unit, label = dict_plot_pm["pm5.0"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm_updated[3].dateTime),vec_df_pm_updated[3][!,"pm10.0"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations "*pm_unit, label = dict_plot_pm["pm10.0"], 
     legend = :right, legendfontsize=10, xrotation = 30)

png("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/PMTimeSeries")




Plots.scatter(Time.(vec_df_pm[3].RollingTime),vec_df_pm[3][!,"pm0.1"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm0.1"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].RollingTime),vec_df_pm[3][!,"pm0.3"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm0.3"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].RollingTime),vec_df_pm[3][!,"pm0.5"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm0.5"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].RollingTime),vec_df_pm[3][!,"pm1.0"], xlabel = "2023-01-03 ",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm1.0"], 
     legend = :right, legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].RollingTime),vec_df_pm[3][!,"pm2.5"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm1.0"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].RollingTime),vec_df_pm[3][!,"pm5.0"], xlabel = "2023-01-03",
     xticks = (tm_ticks,ticks),markerstrokewidth=0,markersize=3,
     ylabel = "PM concentrations Rolling Mean"*pm_unit, label = dict_plot_pm["pm5.0"], 
     legend = :right,  legendfontsize=10, xrotation = 30)
Plots.scatter!(Time.(vec_df_pm[3].RollingTime),vec_df_pm[3][!,"pm10.0"], xlabel = "2023-01-03",
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





