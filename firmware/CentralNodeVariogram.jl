using Pkg
Pkg.activate("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\LoRa")
using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions

# ----------------- Central Node Paul Quinn October 10th 2022 --------------------
# With Imputed Data and Rounding the data to the nearest second
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

path_to_ips7100 = "D://UTD//UTDFall2022//VariogramsLoRa//firmware//data//001e063739c7//MINTS_001e063739c7_IPS7100_2022_10_05.csv"
col_symbols = data_cleaning(path_to_ips7100)[2]
data_frame = data_cleaning(path_to_ips7100)[1]

# #Seasonality
# df = data_frame
# df = DataFrames.rename!(df, col_symbols)
# names(df)

# date_time_rounded = map((x) -> round(x, Dates.Hour(1)), df.dateTime)  
# df_agg = select(df,Not(:dateTime))
# df_agg.date_time_rounded  = date_time_rounded 
# gdf_date_time =  groupby(df_agg, :date_time_rounded)
# resampled_timeseries_data = combine(gdf_date_time, valuecols(gdf_date_time) .=> mean)
# resampled_timeseries_data = DataFrames.rename!(resampled_timeseries_data, col_symbols)
# cols = Symbol.([["dateTime"]; col_symbols[9:15]])

# df_hourly = hcat(resampled_timeseries_data.dateTime,resampled_timeseries_data[:,9:15])
# df_hourly = DataFrames.rename!(df_hourly, cols)

# strpm0_1 = "PM"*latexstring("_{0.1}")
# strpm0_3 = "PM"*latexstring(" _{0.3}")
# strpm0_5 = "PM"*latexstring("_{0.5}")
# strpm1_0 = "PM"*latexstring("_{1.0}")
# strpm2_5 = "PM"*latexstring("_{2.5}")
# strpm5_0 = "PM"*latexstring("_{5.0}")
# strpm10_0 = "PM"*latexstring("_{10.0}")

# y_unit = "(μg/cm3)"#*latexstring("_{0.1}")
# ylab = "PM concentrations"
# y_vals = names(df_hourly)[2:end]
# xlab = "DateTime"
# lab = [strpm0_1, strpm0_3, strpm0_5, strpm1_0, strpm2_5, strpm5_0, strpm10_0]

# p=0
# for i in 1:length(lab)
#     p = plot!(df_hourly.dateTime,df_hourly[!,y_vals[i]], xlabel = "DateTime " ,
#             ylabel = "PM concentrations "*y_unit, label = lab[i], 
#             legend = :right, linewidth=4, legendfontsize=12, xrotation = 45,size=(800,500))
# end
# display(p)

## Imputing the empty spaces with the Nearest Value

df = data_frame
###################Some issue with imputation logic, need to fix it
df = DataFrame()
df.dateTime = collect(data_frame.dateTime[1]:Second(1):data_frame.dateTime[length(data_frame.dateTime)])
df = outerjoin( df,data_frame, on = :dateTime)
sort!(df, (:dateTime))
df = DataFrames.rename!(df, col_symbols)
df = Impute.locf(df)

df_mat = select!(df, Not(col_symbols[1:8]))
mat_updated =  Matrix{Float64}(undef, 0, 7)

mat = Matrix(df_mat)
#mat_head = mat[1:43200,:]

#Calculating the last 900 shifts
diff_mat_updated =  Matrix{Float64}(undef, 900,1)
mat_head = mat[84000:84899,1]
for h in 1:1:900
    mat_tail = mat[(84000+h):(84899+h),1]
    #print(size(mat_tail))
    @inbounds diff_mat_updated = hcat(diff_mat_updated,(mat_head - mat_tail).^2)
end


diff_mat =  Matrix{Float64}(undef, 84000,1)
mat_head = mat[1:83999,1]

for h in 1:1:900
    mat_tail = mat[(h+1):(h+83999),1]
    @inbounds diff_mat = hcat(diff_mat,(mat_head - mat_tail).^2)
    #mat_updated =  vcat(mat_updated,diff_mat)
end

for i in 1:1:900:
    vcat(diff_mat[i],diff_mat_updated[i])
end
# mat_pm0_1_var = Matrix{Any}(undef,7200,7200)
# mat_pm0_3_var = Matrix{Any}(undef,7200,7200)
# mat_pm0_5_var = Matrix{Any}(undef,7200,7200)
mat_pm_var_1 = Matrix{Any}(undef,900,900)
# mat_pm2_5_var = Matrix{Any}(undef,7200,7200)
# mat_pm5_0_var = Matrix{Any}(undef,7200,7200)
# mat_pm10_0_var = Matrix{Any}(undef,7200,7200)
# for i in 1:1:7200
#     mat_pm01_var =  hcat(mat_pm01_var,diff_mat_updated[i][:,1])
# end

Dict("pm0_1")
for i in 1:1:900
    for j in 1:1:7
    # mat_pm0_1_var[:,i] = diff_mat_updated[i][:,1]
    # mat_pm0_3_var[:,i] = diff_mat_updated[i][:,2]
    # mat_pm0_5_var[:,i] = diff_mat_updated[i][:,3]
        mat_pm_var_1[:,i] = diff_mat_updated[i][:,j]
    # mat_pm2_5_var[:,i] = diff_mat_updated[i][:,5]
    # mat_pm5_0_var[:,i] = diff_mat_updated[i][:,6]
    # mat_pm10_0_var[:,i] = diff_mat_updated[i][:,7]
    end
end
#fix the issue with concatenation try concatenting horizontally and save the data in hdf5
# v = cat(diff_mat_updated)
# println(size(v[1]))


# mat_pm0_1_var_new = Matrix{Any}(undef,21600,7200)
# mat_pm0_3_var_new = Matrix{Any}(undef,21600,7200)
# mat_pm0_5_var_new = Matrix{Any}(undef,21600,7200)
mat_pm1_0_var_new = Matrix{Any}(undef,84000,900)
# mat_pm2_5_var_new = Matrix{Any}(undef,21600,7200)
# mat_pm5_0_var_new = Matrix{Any}(undef,21600,7200)
# mat_pm10_0_var_new = Matrix{Any}(undef,21600,7200)

for i in 1:1:900
    # mat_pm0_1_var_new[:,i] = diff_mat[i][:,1]
    # mat_pm0_3_var_new[:,i] = diff_mat[i][:,2]
    # mat_pm0_5_var_new[:,i] = diff_mat[i][:,3]
    mat_pm1_0_var_new[:,i] = diff_mat[i][:,4]
    # mat_pm2_5_var_new[:,i] = diff_mat[i][:,5]
    # mat_pm5_0_var_new[:,i] = diff_mat[i][:,6]
    # mat_pm10_0_var_new[:,i] = diff_mat[i][:,7]
end

# mat_rolling_pm0_1  = vcat(mat_pm0_1_var_new,mat_pm0_1_var)
# mat_rolling_pm0_3  = vcat(mat_pm0_3_var_new,mat_pm0_3_var)
# mat_rolling_pm0_5  = vcat(mat_pm0_5_var_new,mat_pm0_5_var)
mat_rolling_pm1_0  = vcat(mat_pm1_0_var_new,mat_pm1_0_var)
# mat_rolling_pm2_5  = vcat(mat_pm2_5_var_new,mat_pm2_5_var)
# mat_rolling_pm5_0  = vcat(mat_pm5_0_var_new,mat_pm5_0_var)
# mat_rolling_pm10_0  = vcat(mat_pm10_0_var_new,mat_pm10_0_var)


#pm_0_1_rolling [21601:28000,:]
#DataFrame(pm0_1_rolling[21601:28800,:],:auto)

writedlm("pm0_1_moving_variogram.csv",mat_rolling_pm0_1)
writedlm("pm0_3_moving_variogram.csv",mat_rolling_pm0_3)
writedlm("pm0_5_moving_variogram.csv",mat_rolling_pm0_5)
writedlm("pm1_0_moving_variogram.csv",mat_rolling_pm1_0)
writedlm("pm2_5_moving_variogram.csv",mat_rolling_pm2_5)
writedlm("pm5_0_moving_variogram.csv",mat_rolling_pm5_0)
writedlm("pm10_0_moving_variogram.csv",mat_rolling_pm10_0)
# diff_mat_final = Vector{Any}(undef,43200)
# for i in 1:1:7200
#     diff_mat_final[i] = vcat(diff_mat[i],diff_mat_updated[i])
# end 


#@view diff_mat_updated[1:7200,:]
#sum_arr = cumsum.(diff_mat_final,dims = 1)
#save as ()