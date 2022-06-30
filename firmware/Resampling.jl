
using CSV, DataFrames, Dates,Statistics, Dash, PlotlyJS


#data_frame = select(data_frame,Not([:gpsTime,:id]))
function time_series(path)
    data_frame = CSV.read(path,DataFrame)
    μs = [parse(Float64,x[20:26]) for x in data_frame[!,:dateTime]]
    data_frame.μs  = Second.(round.(Int,μs))
    data_frame.dateTime = [x[1:19] for x in data_frame[!,:dateTime]]
    data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS")
    data_frame.dateTime = data_frame.dateTime + data_frame.μs
    data_frame = select!(data_frame, Not(:μs))
    df_agg = select(data_frame,Not(:dateTime))
    function change_data(x)
        x = convert(Vector{Float64}, x)
        return x
    end
    mapcols!(change_data, df_agg)
    df_agg.datetime = data_frame.dateTime
    return df_agg
end
data_frame = time_series("D://UTD//UTDFall2021//LoRa//VariogramsLoRa//firmware//data//MINTS_47db5580001e0039_IPS7100_2021_12_12.csv")

#data_frame.datetime = DateTime.(data_frame.datetime,"yyyy-mm-dd HH:MM:SS")

function resampling_time_series_data(w,tf,df)

    if (w == "s")
        date_time_rounded = map((x) -> round(x, Dates.Second(tf)), df.datetime)

    elseif (w == "m")
        date_time_rounded = map((x) -> round(x, Dates.Minute(tf)), df.datetime)

    elseif (w == "h")
        date_time_rounded = map((x) -> round(x, Dates.Hour(tf)), df.datetime)
  
    elseif (w== "d")
        date_time_rounded = map((x) -> round(x, Dates.Day(tf)), df.datetime)
        
    elseif (w == "mon")
        date_time_rounded = map((x) -> round(x, Dates.Month(tf)), df.datetime)

    elseif (w == "y")
        date_time_rounded - map((x) -> round(x, Dates.Year(tf)), df.datetime)
    end
    df_agg = select(df,Not(:datetime))
    df_agg.date_time_rounded  = date_time_rounded 
    gdf_date_time =  groupby(df_agg, :date_time_rounded)
    resampled_timeseries_data = combine(gdf_date_time, valuecols(gdf_date_time) .=> mean)
    return resampled_timeseries_data

end
########################### Every minute ####################################
r =resampling_time_series_data("m",1,data_frame)

#should be working for month and year

app = dash()
trace1 = scatter(;x = r[!,"date_time_rounded"], y = r[!,"pc0_1_mean"],mode= "markers + lines", marker_size = 5, marker_color = :green)
p1 = plot([trace1])
app.layout = html_div() do
    html_h1("Finally"),
    html_div("Its working"),
    dcc_graph(
        id="figure",
        figure=p1,
    )
end

run_server(app, "0.0.0.0", debug=true)
