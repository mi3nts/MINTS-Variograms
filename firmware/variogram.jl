using CSV,DataFrames, Dates, Statistics, Variography, GeoStats,DataStructures,Plots

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

df_agg_1 = time_series("D://UTD//UTDFall2021//LoRa//VariogramsLoRa//firmware//data//MINTS_47db5580001e0039_IPS7100_2021_12_12.csv")
df_agg_2 = time_series("D://UTD//UTDFall2021//LoRa//VariogramsLoRa//firmware//data//MINTS_47db558000390039_IPS7100_2021_12_12.csv")

timeTick = Dates.format.(df_agg_1.datetime, "HH:MM:SS")
DateTick = Dates.format.(df_agg_1.datetime, "yyyy-mm-dd")
unique_date = unique(DateTick)
titleDateTick =  "PM 0.1 distribution for "*unique_date[1]
plot(timeTick,df_agg_1.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )
#plot(timeTick,df_agg_2.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )



function Cgm(df)
    timeTick = Dates.format.(df.datetime, "HH:MM:SS")
    DateTick = Dates.format.(df.datetime, "yyyy-mm-dd")
    unique_date = unique(DateTick)
    titleDateTick =  "PM 0.1 distribution for "*unique_date[1]
    plot(timeTick,df.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )


    plot_array = Any[]
    corr_vec = Vector{Float64}()
    time_arr = Any[] 
    γh = Vector{Float64}()
    for i in 1:10
        # Lag statistics 
        # Lag statistics for profile n
        df_head = df[1:35,:pm0_1]
        df_tail = df[i+1:35+i,:pm0_1]#Need to fix the limits,because of the limited length of the vector
        time_head = df[1:35,:datetime]
        time_tail = df[i+1:35+i,:datetime]
        time_diff = time_tail - time_head
        avg_lag = ((Dates.value(sum(time_diff))/30)/1000)/60
        head_tail_diff = df_head - df_tail
        γ = sum(head_tail_diff.^2)/(2*30)
        println("lag ", i," Statistics")
        println("Avg Lag",avg_lag)
        # Head Statistics
        head_mean = mean(df_head)
        println("head mean: ",head_mean)
        head_variance = var(df_head)
        println("head variance: ",head_variance,)

        # Tail Statistics
        tail_mean = mean(df_tail)
        println("tail mean: ",tail_mean)
        tail_variance = var(df_tail)
        println("tail variance: ",tail_variance)

        #Correlation between Head and Tail
        corr = cor(df_head,df_tail)
        append!(corr_vec,corr)
        append!(γh,γ)
        append!(time_arr,avg_lag)
        println("lag ",i," correlation between head and tail: ", corr)
        topic = "Lag " *string(i)
        label_1 = "R: "*string(corr)[1:6]*", "
        label_2 = "γ: "*string(γ)[1:6] 
        lab = [label_1,label_2]
        push!(plot_array,Plots.scatter(df_tail,df_head,xlabel = "tail", ylabel = "head",title = topic, label= label_1*label_2 ))
        
    end
    
    display(plot(plot_array..., layout=(5,2),size = (1000,1000)))
    return corr_vec,γh,time_arr
end
Cgm(df_agg_1)
Cgm(df_agg_2)

corr_vec_profile_1 = Cgm(df_agg_1)[1]
corr_vec_profile_2 = Cgm(df_agg_2)[1]

γ_vec_profile_1 = Cgm(df_agg_1)[2]
γ_vec_profile_2 = Cgm(df_agg_2)[2]

time_vec_profile_1 = Cgm(df_agg_1)[3]
time_vec_profile_2 = Cgm(df_agg_2)[3]
step = vcat(1:10)

Plots.bar(time_vec_profile_1,corr_vec_profile_1,xlabel = "Lag", ylabel = "Correlation", label="", title = "Correlogram for Profile 1")
Plots.bar(time_vec_profile_2,corr_vec_profile_2,xlabel = "Lag", ylabel = "Correlation", label="", title = "Correlogram for Profile 2")

((Dates.value(sum(df_agg_1[2:36,:datetime] - df_agg_1[1:35,:datetime])))/1000/60/60)>5


plot(time_vec_profile_1,γ_vec_profile_1,linewidth=5,xlabel = "Δt (in minutes)", ylabel = "γ(t)", label="", title = "Variogram for Profile 1")
plot!([91.3094], seriestype="vline",label= "",line=(:dot, 4))
plot!([0.0012], seriestype="hline",label= "",line=(:dot, 4))
plot(time_vec_profile_2,γ_vec_profile_2,xlabel = "Lag", ylabel = "γ(h)", label="", title = "Variogram for Profile 2")
