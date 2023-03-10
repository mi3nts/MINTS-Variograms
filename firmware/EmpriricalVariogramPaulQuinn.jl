using Pkg

Pkg.activate("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\LoRa")

using BenchmarkTools, CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings,FFTW,StatsBase,Statistics,Polynomials,Peaks,Roots,IJulia

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

df = data_frame
df = DataFrames.rename!(df, col_symbols)
names(df)

date_time_rounded = map((x) -> round(x, Dates.Hour(1)), df.dateTime)  
df_agg = select(df,Not(:dateTime))
df_agg.date_time_rounded  = date_time_rounded 
gdf_date_time =  groupby(df_agg, :date_time_rounded)
resampled_timeseries_data = combine(gdf_date_time, valuecols(gdf_date_time) .=> mean)
resampled_timeseries_data = DataFrames.rename!(resampled_timeseries_data, col_symbols)

cols = Symbol.([["dateTime"]; col_symbols[9:15]])

df_hourly = hcat(resampled_timeseries_data.dateTime,resampled_timeseries_data[:,9:15])
df_hourly = DataFrames.rename!(df_hourly, cols)

strpm0_1 = "PM"*latexstring("_{0.1}")
strpm0_3 = "PM"*latexstring(" _{0.3}")
strpm0_5 = "PM"*latexstring("_{0.5}")
strpm1_0 = "PM"*latexstring("_{1.0}")
strpm2_5 = "PM"*latexstring("_{2.5}")
strpm5_0 = "PM"*latexstring("_{5.0}")
strpm10_0 = "PM"*latexstring("_{10.0}")

y_unit = "(μg/m3)"#*latexstring("_{0.1}")
ylab = "PM concentrations"
y_vals = names(df_hourly)[2:end]
xlab = "DateTime"
lab = [strpm0_1, strpm0_3, strpm0_5, strpm1_0, strpm2_5, strpm5_0, strpm10_0]

p=0
for i in 1:length(lab)
    p = plot!(df_hourly.dateTime,df_hourly[!,y_vals[i]], xlabel = "DateTime " ,
            ylabel = "PM concentrations "*y_unit, label = lab[i], 
            legend = :right, linewidth=4, legendfontsize=12, xrotation = 45,size=(800,500))
end
display(p)

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
m = Matrix{Float64}(undef,300,0)
for n in 1:1:7
    x=[]
    for h in 1:1:300
        mat_head = mat[1:900-h,n]
        mat_tail = mat[1+h:900,n]
        println("head ",1,":",900-h)
        println("tail ",1+h,":",900)
        append!(x,sum((mat_head - mat_tail).^2,dims=1)/(2*(900-h)))    
    end

    m = hcat(m,x)#To match dimensions, vcat has to be used to append a column matrix with 900 columns
end


m  = hcat(collect(1:1:300)./60,m)

γ = DataFrame(m,:auto)
n = [["Δt"];names(df)]
DataFrames.rename!(γ,n)
γ = transform!(γ, names(γ) .=> ByRow(Float64), renamecols=false)

for i in 1:length(lab)
    #PM values
    plot(γ.Δt,γ[!,y_vals[i]],xlabel ="Δt(minutes)" ,ylabel= "γ(Δt)",legend=:right ,linewidth=4, legendfontsize=12,label=lab[i],xticks= 0:3:120, xrotation = 90)
    plot!([findmaxima(γ[!,y_vals[i]])[2][1]], seriestype="hline",label= "",line=(:dot, 4))
    plot!([γ.Δt[findmaxima(γ[!,y_vals[i]])[1][1]]], seriestype="vline",label= "",line=(:dot, 4))
    display(plot!(Polynomials.fit(γ.Δt,γ[!,y_vals[i]],7),γ.Δt[1],γ.Δt[end],label = "Fit"))
    println("(range,sill,nugget) = ",(round(γ.Δt[findmaxima(γ[!,y_vals[i]])[1][1]];digits=3),round(findmaxima(γ[!,y_vals[i]])[2][1];digits=3),round(Polynomials.fit(γ.Δt,γ[!,y_vals[i]],7)(0);digits=3)))
    
end
# df_mat.pm0_1
# StatsModels.lag(df_mat.pm0_1,2)