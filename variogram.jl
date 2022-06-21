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

df_agg_1 = time_series("D://UTD//UTDFall2021//LoRa//VariogramsLoRa//data//MINTS_47db5580001e0039_IPS7100_2021_12_12.csv")
df_agg_2 = time_series("D://UTD//UTDFall2021//LoRa//VariogramsLoRa//data//MINTS_47db558000390039_IPS7100_2021_12_12.csv")
function Cgm(df)
    timeTick = Dates.format.(df.datetime, "HH:MM:SS")
    DateTick = Dates.format.(df.datetime, "yyyy-mm-dd")
    unique_date = unique(DateTick)
    titleDateTick =  "PM 0.1 distribution for "*unique_date[1]
    plot(timeTick,df.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )
    #Plots.scatter(df_agg_2.datetime,df_agg_2.pm0_1,dpi = 1000)

    plot_array = Any[]
    corr_vec = Vector{Float64}()
    for i in 1:10
        # Lag statistics 
        # Lag statistics for profile n
        df_head = df[1:30,:pm0_1]
        df_tail = df[i+1:30+i,:pm0_1]#Need to fix the limits,because of the limited length of the vector
        head_tail_diff = df_head - df_tail
        gamma_h = sum(head_tail_diff.^2)/(2*30)
        println("lag ", i," Statistics")
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
        
        println("lag ",i," correlation between head and tail: ", corr)
        topic = "Lag " *string(i)
        label_1 = "R: "*string(corr)[1:6]
        label_2 = " gamma: "*string(gamma_h)[1:6] 
        lab = [label_1,label_2]
        push!(plot_array,Plots.scatter(df_tail,df_head,xlabel = "tail", ylabel = "head",title = topic, label= label_1*label_2 ))
        
    end
    
    display(plot(plot_array..., layout=(5,2),size = (1000,1000)))
    return corr_vec
end
Cgm(df_agg_1)
Cgm(df_agg_2)

corr_vec_profile_1 = Cgm(df_agg_1)
corr_vec_profile_2 = Cgm(df_agg_2)
step = vcat(1:10)

Plots.bar(step,corr_vec_profile_1,xlabel = "Lag", ylabel = "Correlation", label="", title = "Correlogram for Profile 1")
Plots.bar(step,corr_vec_profile_2,xlabel = "Lag", ylabel = "Correlation", label="", title = "Correlogram for Profile 2")
