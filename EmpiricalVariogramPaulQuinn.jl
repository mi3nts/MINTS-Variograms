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
path_to_ips7100 = "C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/001e0636e547/2023/01/03/MINTS_001e0636e547_IPS7100_2023_01_03.csv"
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

y_unit = "(μg/m"*latexstring("^3")*")"
ylab = "PM concentrations"
y_vals = names(df_hourly)[2:end]
xlab = "DateTime"
lab = [strpm0_1, strpm0_3, strpm0_5, strpm1_0, strpm2_5, strpm5_0, strpm10_0]


#changed title, EPA, EU standards here
plot()
p = 
plot(Time.(df_hourly.dateTime)[1:24],df_hourly[!,y_vals[5]][1:24], xlabel = "Time " ,
    title = "01-03-2023",ylabel = lab[5]*" Concentration "*y_unit,xticks = Time("00:00"):Hour(3):Time("23:59"), yticks = [0, 5, 10, 15, 20, 25, 30, 35, 40],
    linewidth=4, label = "",legendfontsize=6, xrotation = 45,size=(400,400), legend=:topright)
hline!([35], color=:darkred, label="EPA Standard",linestyle=:dash)
hline!([15], color=:darkgreen, label="WHO Standard",linestyle=:dash)
hline!([20], color=:darkblue, label="EU Standard",linestyle=:dash)
#png("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/plots/hourly.png")
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
i=5
#changed title, EPA, EU standards here
p = plot(Time.(df.dateTime)[1:end-1],df[!,"pm2_5"][1:end-1], xlabel = "Time " ,
    title = "01-03-2023",ylabel = lab[i]*" Concentration "*y_unit,xticks = Time("00:00"):Hour(3):Time("23:59"),
    linewidth=4, label = "",legendfontsize=12, xrotation = 45,)
hline!([35], color=:darkred, label="EPA Standard",linestyle=:dash,size=(400,400))
hline!([15], color=:darkgreen, label="WHO Standard",linestyle=:dash)
hline!([20], color=:darkblue, label="EU Standard",linestyle=:dash,size=(400,400))
display(p)

#png("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/plots/seconds.png")


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

#0.956
for i in 1:length(lab)
    #PM values
    #changed title here
    plot(γ.Δt,γ[!,y_vals[i]],xlabel ="Δt(minutes)" ,ylabel= "Variogram (γ(Δt))", title = "01-03-2023",legend=:outertopright,linewidth=4, legendfontsize=12,label=lab[i],xticks= 0:3:120, xrotation = 90)
    plot!([findmaxima(γ[!,y_vals[i]])[2][1]], seriestype="hline",label= "Sill",line=(:dot, 4))
    plot!([γ.Δt[findmaxima(γ[!,y_vals[i]])[1][1]]], seriestype="vline",label= "Range",line=(:dot, 4))
    x_intersect = 0
    y_intersect = round(Polynomials.fit(γ.Δt,γ[!,y_vals[i]],7)(0);digits=3)
    text_x = 0
    text_y = round(Polynomials.fit(γ.Δt,γ[!,y_vals[i]],7)(0);digits=3)
    #added nugget here
    annotate!(text_x, text_y, text("  Nugget: ($x_intersect, $y_intersect)", font(10), :left))
    scatter!([0], [0.956], markershape=:circle, markercolor=:black, markersize=10, markerstrokewidth=4, label="")
    scatter!([0], [0.956], markershape=:circle, markercolor=:white, markersize=8, markerstrokewidth=4, label="")
    x_intersect = round(γ.Δt[findmaxima(γ[!,y_vals[i]])[1][1]];digits=3)
    y_intersect = round(findmaxima(γ[!,y_vals[i]])[2][1];digits=3)
    x_min, x_max = extrema(γ.Δt)
    y_min, y_max = extrema(γ[!,y_vals[i]])
    text_x = x_min + 0.18 * (x_max - x_min)
    text_y = y_min + 0.75 * (y_max - y_min) # changed to 0.1 instead of 0.9
    annotate!(text_x, text_y, text("($x_intersect, $y_intersect)", font(10), :left))
    scatter!([x_intersect], [y_intersect], markershape=:xcross, markercolor=:black, markersize=4, markerstrokewidth=4,label = "")
    display(plot!(Polynomials.fit(γ.Δt,γ[!,y_vals[i]],7),γ.Δt[1],γ.Δt[end],label = "Fit"))
    png("C:/Users/va648/Downloads/VSCode/MINTS-LoRa-Variograms/firmware/data/plots"*string(i))

    println("(range,sill,nugget) = ",(round(γ.Δt[findmaxima(γ[!,y_vals[i]])[1][1]];digits=3),round(findmaxima(γ[!,y_vals[i]])[2][1];digits=3),round(Polynomials.fit(γ.Δt,γ[!,y_vals[i]],7)(0);digits=3)))
    
end
# df_mat.pm0_1
# StatsModels.lag(df_mat.pm0_1,2)
