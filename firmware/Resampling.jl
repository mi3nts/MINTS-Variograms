
using CSV, DataFrames, Dates,Statistics, Dash, DashHtmlComponents, DashCoreComponents, PlotlyJS


#using TimeSeriesIO: TimeArray
data_frame = CSV.read("//mnt//3fbf694d-d8e0-46c0-903d-69d994241206//mintsData//raw//b827eb52fc29//47cb5580002e004a//47cb5580002e004a_2021-06-17.csv",DataFrame)
data_frame = select(data_frame,Not([:gpsTime,:id]))


data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS")

function resampling_time_series_data(w,tf,df)
########################### Every 30 seconds ####################################
    if (w == "s")
        date_time_rounded = map((x) -> round(x, Dates.Second(tf)), df.dateTime)

    elseif (w == "m")
        date_time_rounded = map((x) -> round(x, Dates.Minute(tf)), df.dateTime)

    elseif (w == "h")
        date_time_rounded = map((x) -> round(x, Dates.Hour(tf)), df.dateTime)
  
    elseif (w== "d")
        date_time_rounded = map((x) -> round(x, Dates.Day(tf)), df.dateTime)
    end
    df_agg = select(df,Not(:dateTime))
    df_agg.date_time_rounded  = date_time_rounded 
    gdf_date_time =  groupby(df_agg, :date_time_rounded)
    resampled_timeseries_data = combine(gdf_date_time, valuecols(gdf_date_time) .=> mean)
    return resampled_timeseries_data

end
r =resampling_time_series_data("m",1,data_frame)

app = dash()
trace1 = scatter(;x = r[!,"date_time_rounded"], y = r[!,"NH3_mean"],mode= "markers + lines", marker_size = 5, marker_color = :green)
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