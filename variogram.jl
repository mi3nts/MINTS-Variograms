using CSV,DataFrames, Dates, Statistics, Variography, GeoStats, DataStructures, Plots

function time_series(path)
    data_frame = CSV.read(path,DataFrame)
    μs = [parse(Float64,x[20:26]) for x in data_frame[!,:dateTime]] #select datetime column, string[1-19]
    data_frame.μs  = Second.(round.(Int,μs))
    data_frame.dateTime = [x[1:19] for x in data_frame[!,:dateTime]] #same thing as above, except you select the float microseconds and convert it to seconds
    data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS") #reformat
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

df_agg_1 = time_series("C:/Users/va648/VSCode/MINTS-LoRa-Variograms-master/firmware/data/MINTS_47db5580001e0039_IPS7100_2021_12_12.csv")
df_agg_2 = time_series("C:/Users/va648/VSCode/MINTS-LoRa-Variograms-master/firmware/data/MINTS_47db558000390039_IPS7100_2021_12_12.csv")

timeTick = Dates.format.(df_agg_1.datetime, "HH:MM:SS")
DateTick = Dates.format.(df_agg_1.datetime, "yyyy-mm-dd")
unique_date = unique(DateTick)
titleDateTick =  "PM 0.1 distribution for "*unique_date[1]
plot(timeTick,df_agg_1.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )
#plot(timeTick,df_agg_2.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )

function sillRange(yvector::Vector{Float64}, timevector::Vector{Float64})
    vec_length = length(yvector)
    dy_vec = []
    dt_vec = []
    slope_vec = []

    for i in 1:vec_length
        dy = yvector[i+1] - yvector[i]
        append!(dy_vec, dy)
        dt = timevector[i+1]-timevector[i]
        append!(dt_vec, dt)
        slope = dy/dt
        append!(slope_vec, slope)        

        if i == (vec_length - 1)
            break
        end
    end

    for i in 1:length(slope_vec)
        if slope_vec[i] < 0
            return timevector[i-1], yvector[i-1] #could possible be changed to yvector[i] - will have to see
        end
    end
end


function Cgm(df)
    timeTick = Dates.format.(df.datetime, "HH:MM:SS")
    DateTick = Dates.format.(df.datetime, "yyyy-mm-dd")
    unique_date = unique(DateTick)
    titleDateTick =  "PM 0.1 distribution for "*unique_date[1]
    plot(timeTick,df.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )

    #pm0_1,pm0_3,pm0_5,pm1_0,pm2_5,pm5_0,pm10_0
    plot_df = DataFrame(plot_pm0_1 = Vector{Float64}(undef, 10), 
                        plot_pm0_3 = Vector{Float64}(undef, 10),   
                        plot_pm0_5 = Vector{Float64}(undef, 10),
                        plot_pm1_0 = Vector{Float64}(undef, 10),
                        plot_pm2_5 = Vector{Float64}(undef, 10),
                        plot_pm5_0 = Vector{Float64}(undef, 10),
                        plot_pm10_0 = Vector{Float64}(undef, 10))

    corr_df = DataFrame(corr_pm0_1 = Vector{Float64}(undef, 10), 
                        corr_pm0_3 = Vector{Float64}(undef, 10),   
                        corr_pm0_5 = Vector{Float64}(undef, 10),
                        corr_pm1_0 = Vector{Float64}(undef, 10),
                        corr_pm2_5 = Vector{Float64}(undef, 10),
                        corr_pm5_0 = Vector{Float64}(undef, 10),
                        corr_pm10_0 = Vector{Float64}(undef, 10))

    time_df = DataFrame(time_pm0_1 = Vector{Float64}(undef, 10), 
                        time_pm0_3 = Vector{Float64}(undef, 10),   
                        time_pm0_5 = Vector{Float64}(undef, 10),
                        time_pm1_0 = Vector{Float64}(undef, 10),
                        time_pm2_5 = Vector{Float64}(undef, 10),
                        time_pm5_0 = Vector{Float64}(undef, 10),
                        time_pm10_0 = Vector{Float64}(undef, 10))

    #time_diff = Any[]
    γh_df = DataFrame(γ_pm0_1 = Vector{Float64}(undef, 10), 
                        γ_pm0_3 = Vector{Float64}(undef, 10),   
                        γ_pm0_5 = Vector{Float64}(undef, 10),
                        γ_pm1_0 = Vector{Float64}(undef, 10),
                        γ_pm2_5 = Vector{Float64}(undef, 10),
                        γ_pm5_0 = Vector{Float64}(undef, 10),
                        γ_pm10_0 = Vector{Float64}(undef, 10))

    plot_array_pm01 = Any[]
    plot_array_pm03 = Any[]
    plot_array_pm05 = Any[]
    plot_array_pm10 = Any[]
    plot_array_pm25 = Any[]
    plot_array_pm50 = Any[]
    plot_array_pm100 = Any[]

    #testing with 2 pm values for now
    for i in 1:10 #10 lags for each pm sensor
        # Lag statistics 
        # Lag statistics for profile n
        df_head_pm01 = df[1:35,:pm0_1] #df is the input dataframe
        df_tail_pm01 = df[i+1:35+i,:pm0_1] #Need to fix the limits,because of the limited length of the vector
        time_head_pm01 = df[1:35,:datetime]
        time_tail_pm01 = df[i+1:35+i,:datetime]
        time_diff_pm01 = time_tail_pm01 - time_head_pm01
        #append!(time_diff, time_diff_pm01)

        avg_lag_pm01 = ((Dates.value(sum(time_diff_pm01))/35)/1000)/60
        head_tail_diff_pm01 = df_head_pm01 - df_tail_pm01
        γ_pm01 = sum(head_tail_diff_pm01.^2)/(2*35)
        println("lag ", i," Statistics")
        println("Avg Lag", avg_lag_pm01)

        # Head Statistics
        head_mean_pm01 = mean(df_head_pm01)
        println("head mean: ",head_mean_pm01)
        head_variance_pm01 = var(df_head_pm01)
        println("head variance: ",head_variance_pm01,)

        # Tail Statistics
        tail_mean_pm01 = mean(df_tail_pm01)
        println("tail mean: ",tail_mean_pm01)
        tail_variance_pm01 = var(df_tail_pm01)
        println("tail variance: ",tail_variance_pm01)

        #Correlation between Head and Tail
        corr_pm01 = cor(df_head_pm01,df_tail_pm01)
        #append!(corr_vec,corr_pm01) 
        corr_df.corr_pm0_1[i] = corr_pm01
        # append!(γh,γ_pm01)
        γh_df.γ_pm0_1[i] = γ_pm01
        #append!(time_arr,avg_lag_pm01)
        time_df.time_pm0_1[i] = avg_lag_pm01

        ########################### pm0_3 ####################################

        df_head_pm03 = df[1:35,:pm0_3] #df is the input dataframe
        df_tail_pm03 = df[i+1:35+i,:pm0_3] #Need to fix the limits,because of the limited length of the vector
        time_head_pm03 = df[1:35,:datetime]
        time_tail_pm03 = df[i+1:35+i,:datetime]
        time_diff_pm03 = time_tail_pm03 - time_head_pm03

        avg_lag_pm03 = ((Dates.value(sum(time_diff_pm03))/35)/1000)/60
        head_tail_diff_pm03 = df_head_pm03 - df_tail_pm03
        γ_pm03 = sum(head_tail_diff_pm03.^2)/(2*35)
        println("lag ", i," Statistics")
        println("Avg Lag",avg_lag_pm03)

        # Head Statistics
        head_mean_pm03 = mean(df_head_pm03)
        println("head mean: ",head_mean_pm03)
        head_variance_pm03 = var(df_head_pm03)
        println("head variance: ",head_variance_pm03,)

        # Tail Statistics
        tail_mean_pm03 = mean(df_tail_pm03)
        println("tail mean: ",tail_mean_pm03)
        tail_variance_pm03 = var(df_tail_pm03)
        println("tail variance: ",tail_variance_pm03)

        #Correlation between Head and Tail
        corr_pm03 = cor(df_head_pm03,df_tail_pm03) #same as original
        #append!(corr_vec,corr_pm01) 
        corr_df.corr_pm0_3[i] = corr_pm03
        # append!(γh,γ_pm01)
        γh_df.γ_pm0_3[i] = γ_pm03
        #append!(time_arr,avg_lag_pm01)
        time_df.time_pm0_3[i] = avg_lag_pm03

        ########################### pm0_5 ####################################

        df_head_pm05 = df[1:35,:pm0_5] #df is the input dataframe
        df_tail_pm05 = df[i+1:35+i,:pm0_5] #Need to fix the limits,because of the limited length of the vector
        time_head_pm05 = df[1:35,:datetime]
        time_tail_pm05 = df[i+1:35+i,:datetime]
        time_diff_pm05 = time_tail_pm05 - time_head_pm05

        avg_lag_pm05 = ((Dates.value(sum(time_diff_pm05))/35)/1000)/60
        head_tail_diff_pm05 = df_head_pm05 - df_tail_pm05
        γ_pm05 = sum(head_tail_diff_pm05.^2)/(2*35)
        println("lag ", i," Statistics")
        println("Avg Lag",avg_lag_pm05)

        # Head Statistics
        head_mean_pm05 = mean(df_head_pm05)
        println("head mean: ", head_mean_pm05)
        head_variance_pm05 = var(df_head_pm05)
        println("head variance: ", head_variance_pm05,)

        # Tail Statistics
        tail_mean_pm05 = mean(df_tail_pm05)
        println("tail mean: ", tail_mean_pm05)
        tail_variance_pm05 = var(df_tail_pm05)
        println("tail variance: ", tail_variance_pm05)

        #Correlation between Head and Tail
        corr_pm05 = cor(df_head_pm05, df_tail_pm05) #same as original
        #append!(corr_vec,corr_pm01) 
        corr_df.corr_pm0_5[i] = corr_pm05
        # append!(γh,γ_pm01)
        γh_df.γ_pm0_5[i] = γ_pm05
        #append!(time_arr,avg_lag_pm01)
        time_df.time_pm0_5[i] = avg_lag_pm05

        ########################### pm1_0 ####################################

        df_head_pm10 = df[1:35,:pm1_0] #df is the input dataframe
        df_tail_pm10 = df[i+1:35+i,:pm1_0] #Need to fix the limits,because of the limited length of the vector
        time_head_pm10 = df[1:35,:datetime]
        time_tail_pm10 = df[i+1:35+i,:datetime]
        time_diff_pm10 = time_tail_pm10 - time_head_pm10

        avg_lag_pm10 = ((Dates.value(sum(time_diff_pm10))/35)/1000)/60
        head_tail_diff_pm10 = df_head_pm10 - df_tail_pm10
        γ_pm10 = sum(head_tail_diff_pm10.^2)/(2*35)
        println("lag ", i," Statistics")
        println("Avg Lag",avg_lag_pm03)

        # Head Statistics
        head_mean_pm10 = mean(df_head_pm10)
        println("head mean: ",head_mean_pm10)
        head_variance_pm10 = var(df_head_pm10)
        println("head variance: ",head_variance_pm10,)

        # Tail Statistics
        tail_mean_pm10 = mean(df_tail_pm10)
        println("tail mean: ",tail_mean_pm10)
        tail_variance_pm10 = var(df_tail_pm10)
        println("tail variance: ",tail_variance_pm10)

        #Correlation between Head and Tail
        corr_pm10 = cor(df_head_pm10,df_tail_pm10) #same as original
        #append!(corr_vec,corr_pm01) 
        corr_df.corr_pm1_0[i] = corr_pm10
        # append!(γh,γ_pm01)
        γh_df.γ_pm1_0[i] = γ_pm10
        #append!(time_arr,avg_lag_pm01)
        time_df.time_pm1_0[i] = avg_lag_pm10

        ########################### pm2_5 ####################################

        df_head_pm25 = df[1:35,:pm2_5] #df is the input dataframe
        df_tail_pm25 = df[i+1:35+i,:pm2_5] #Need to fix the limits,because of the limited length of the vector
        time_head_pm25 = df[1:35,:datetime]
        time_tail_pm25 = df[i+1:35+i,:datetime]
        time_diff_pm25 = time_tail_pm25 - time_head_pm25

        avg_lag_pm25 = ((Dates.value(sum(time_diff_pm25))/35)/1000)/60
        head_tail_diff_pm25 = df_head_pm25 - df_tail_pm25
        γ_pm25 = sum(head_tail_diff_pm25.^2)/(2*35)
        println("lag ", i," Statistics")
        println("Avg Lag", avg_lag_pm25)

        # Head Statistics
        head_mean_pm25 = mean(df_head_pm25)
        println("head mean: ",head_mean_pm25)
        head_variance_pm25 = var(df_head_pm25)
        println("head variance: ",head_variance_pm03,)

        # Tail Statistics
        tail_mean_pm25 = mean(df_tail_pm25)
        println("tail mean: ",tail_mean_pm03)
        tail_variance_pm25 = var(df_tail_pm25)
        println("tail variance: ",tail_variance_pm25)

        #Correlation between Head and Tail
        corr_pm25 = cor(df_head_pm25,df_tail_pm25) #same as original
        #append!(corr_vec,corr_pm01) 
        corr_df.corr_pm2_5[i] = corr_pm25
        # append!(γh,γ_pm01)
        γh_df.γ_pm2_5[i] = γ_pm25
        #append!(time_arr,avg_lag_pm01)
        time_df.time_pm2_5[i] = avg_lag_pm25

        ########################### pm5_0 ####################################

        df_head_pm50 = df[1:35,:pm5_0] #df is the input dataframe
        df_tail_pm50 = df[i+1:35+i,:pm5_0] #Need to fix the limits,because of the limited length of the vector
        time_head_pm50 = df[1:35,:datetime]
        time_tail_pm50 = df[i+1:35+i,:datetime]
        time_diff_pm50 = time_tail_pm50 - time_head_pm50

        avg_lag_pm50 = ((Dates.value(sum(time_diff_pm50))/35)/1000)/60
        head_tail_diff_pm50 = df_head_pm50 - df_tail_pm50
        γ_pm50 = sum(head_tail_diff_pm50.^2)/(2*35)
        println("lag ", i," Statistics")
        println("Avg Lag", avg_lag_pm50)

        # Head Statistics
        head_mean_pm50 = mean(df_head_pm50)
        println("head mean: ", head_mean_pm50)
        head_variance_pm50 = var(df_head_pm50)
        println("head variance: ", head_variance_pm50,)

        # Tail Statistics
        tail_mean_pm50 = mean(df_tail_pm50)
        println("tail mean: ", tail_mean_pm50)
        tail_variance_pm50 = var(df_tail_pm50)
        println("tail variance: ", tail_variance_pm50)

        #Correlation between Head and Tail
        corr_pm50 = cor(df_head_pm50, df_tail_pm50) #same as original
        #append!(corr_vec,corr_pm01) 
        corr_df.corr_pm5_0[i] = corr_pm50
        # append!(γh,γ_pm01)
        γh_df.γ_pm5_0[i] = γ_pm50
        #append!(time_arr,avg_lag_pm01)
        time_df.time_pm5_0[i] = avg_lag_pm50

        ########################### pm10_0 ####################################

        df_head_pm100 = df[1:35,:pm10_0] #df is the input dataframe
        df_tail_pm100 = df[i+1:35+i,:pm10_0] #Need to fix the limits,because of the limited length of the vector
        time_head_pm100 = df[1:35,:datetime]
        time_tail_pm100 = df[i+1:35+i,:datetime]
        time_diff_pm100 = time_tail_pm100 - time_head_pm100

        avg_lag_pm100 = ((Dates.value(sum(time_diff_pm100))/35)/1000)/60
        head_tail_diff_pm100 = df_head_pm100 - df_tail_pm100
        γ_pm100 = sum(head_tail_diff_pm100.^2)/(2*35)
        println("lag ", i," Statistics")
        println("Avg Lag", avg_lag_pm100)

        # Head Statistics
        head_mean_pm100 = mean(df_head_pm100)
        println("head mean: ", head_mean_pm100)
        head_variance_pm100 = var(df_head_pm100)
        println("head variance: ", head_variance_pm100,)

        # Tail Statistics
        tail_mean_pm100 = mean(df_tail_pm100)
        println("tail mean: ",tail_mean_pm100)
        tail_variance_pm100 = var(df_tail_pm100)
        println("tail variance: ",tail_variance_pm100)

        #Correlation between Head and Tail
        corr_pm100 = cor(df_head_pm100,df_tail_pm100) #same as original
        #append!(corr_vec,corr_pm01) 
        corr_df.corr_pm10_0[i] = corr_pm100
        # append!(γh,γ_pm01)
        γh_df.γ_pm10_0[i] = γ_pm100
        #append!(time_arr,avg_lag_pm01)
        time_df.time_pm10_0[i] = avg_lag_pm100

        ######################################################################

        #println("lag ",i," correlation between head and tail: ", corr_pm01)
        topic = "Lag " *string(i)
        label_1_pm01 = "R: "*string(corr_pm01)[1:6]*", "
        label_2_pm01 = "γ: "*string(γ_pm01)[1:6] 
        label_1_pm03 = "R: "*string(corr_pm03)[1:6]*", "
        label_2_pm03 = "γ: "*string(γ_pm03)[1:6] 
        label_1_pm05 = "R: "*string(corr_pm05)[1:6]*", "
        label_2_pm05 = "γ: "*string(γ_pm05)[1:6]
        label_1_pm10 = "R: "*string(corr_pm10)[1:6]*", "
        label_2_pm10 = "γ: "*string(γ_pm10)[1:6]      
        label_1_pm25 = "R: "*string(corr_pm25)[1:6]*", "
        label_2_pm25 = "γ: "*string(γ_pm25)[1:6]
        label_1_pm50 = "R: "*string(corr_pm50)[1:6]*", "
        label_2_pm50 = "γ: "*string(γ_pm50)[1:6] 
        label_1_pm100 = "R: "*string(corr_pm100)[1:6]*", "
        label_2_pm100 = "γ: "*string(γ_pm100)[1:6] 

        # lab = [label_1,label_2]

        push!(plot_array_pm01,Plots.scatter(df_tail_pm01,df_head_pm01,xlabel = "tail pm0.1", ylabel = "head pm0.1",title = topic, label= label_1_pm01*label_2_pm01 ))
        push!(plot_array_pm03,Plots.scatter(df_tail_pm03,df_head_pm03,xlabel = "tail pm0.3", ylabel = "head pm0.3",title = topic, label= label_1_pm03*label_2_pm03 ))
        push!(plot_array_pm05,Plots.scatter(df_tail_pm05,df_head_pm05,xlabel = "tail pm0.5", ylabel = "head pm0.5",title = topic, label= label_1_pm05*label_2_pm05 ))
        push!(plot_array_pm10,Plots.scatter(df_tail_pm10,df_head_pm10,xlabel = "tail pm1.0", ylabel = "head pm1.0",title = topic, label= label_1_pm10*label_2_pm10 ))
        push!(plot_array_pm25,Plots.scatter(df_tail_pm25,df_head_pm25,xlabel = "tail pm2.5", ylabel = "head pm2.5",title = topic, label= label_1_pm25*label_2_pm25 ))
        push!(plot_array_pm50,Plots.scatter(df_tail_pm50,df_head_pm50,xlabel = "tail pm5.0", ylabel = "head pm5.0",title = topic, label= label_1_pm50*label_2_pm50 ))
        push!(plot_array_pm100,Plots.scatter(df_tail_pm100,df_head_pm100,xlabel = "tail pm10.0", ylabel = "head pm10.0",title = topic, label= label_1_pm100*label_2_pm100 ))       
    end
    
    display(plot(plot_array_pm01..., layout=(5,2), size = (1000,1000)))
    display(plot(plot_array_pm03..., layout=(5,2), size = (1000,1000)))
    display(plot(plot_array_pm05..., layout=(5,2), size = (1000,1000)))
    display(plot(plot_array_pm10..., layout=(5,2), size = (1000,1000)))
    display(plot(plot_array_pm25..., layout=(5,2), size = (1000,1000)))
    display(plot(plot_array_pm50..., layout=(5,2), size = (1000,1000)))
    display(plot(plot_array_pm100..., layout=(5,2), size = (1000,1000)))

    return corr_df, γh_df, time_df
end

Cgm(df_agg_1)
Cgm(df_agg_2)



Plots.bar(Cgm(df_agg_1)[3].time_pm0_1,Cgm(df_agg_1)[1].corr_pm0_1,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM0.1 Correlogram for Profile 1")
Plots.bar(Cgm(df_agg_2)[3].time_pm0_1,Cgm(df_agg_2)[1].corr_pm0_1,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM0.1 Correlogram for Profile 2")

Plots.bar(Cgm(df_agg_1)[3].time_pm0_3,Cgm(df_agg_1)[1].corr_pm0_3,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM0.3 Correlogram for Profile 1")
Plots.bar(Cgm(df_agg_2)[3].time_pm0_3,Cgm(df_agg_2)[1].corr_pm0_3,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM0.3 Correlogram for Profile 2")

Plots.bar(Cgm(df_agg_1)[3].time_pm0_5,Cgm(df_agg_1)[1].corr_pm0_5,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM0.5 Correlogram for Profile 1")
Plots.bar(Cgm(df_agg_2)[3].time_pm0_5,Cgm(df_agg_2)[1].corr_pm0_5,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM0.5 Correlogram for Profile 2")

Plots.bar(Cgm(df_agg_1)[3].time_pm1_0,Cgm(df_agg_1)[1].corr_pm1_0,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM1.0 Correlogram for Profile 1")
Plots.bar(Cgm(df_agg_2)[3].time_pm1_0,Cgm(df_agg_2)[1].corr_pm1_0,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM1.0 Correlogram for Profile 2")

Plots.bar(Cgm(df_agg_1)[3].time_pm2_5,Cgm(df_agg_1)[1].corr_pm2_5,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM2.5 Correlogram for Profile 1")
Plots.bar(Cgm(df_agg_2)[3].time_pm2_5,Cgm(df_agg_2)[1].corr_pm2_5,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM2.5 Correlogram for Profile 2")

Plots.bar(Cgm(df_agg_1)[3].time_pm5_0,Cgm(df_agg_1)[1].corr_pm5_0,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM5.0 Correlogram for Profile 1")
Plots.bar(Cgm(df_agg_2)[3].time_pm5_0,Cgm(df_agg_2)[1].corr_pm5_0,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM5.0 Correlogram for Profile 2")

Plots.bar(Cgm(df_agg_1)[3].time_pm10_0,Cgm(df_agg_1)[1].corr_pm10_0,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM10.0 Correlogram for Profile 1")
Plots.bar(Cgm(df_agg_2)[3].time_pm10_0,Cgm(df_agg_2)[1].corr_pm10_0,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM10.0 Correlogram for Profile 2")

#((Dates.value(sum(df_agg_1[2:36,:datetime] - df_agg_1[1:35,:datetime])))/1000/60/60)>5 #what does this line do?


plot(Cgm(df_agg_1)[3].time_pm0_1, Cgm(df_agg_1)[2].γ_pm0_1, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.1 Variogram for Profile 1")
plot(Cgm(df_agg_2)[3].time_pm0_1, Cgm(df_agg_2)[2].γ_pm0_1, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.1 Variogram for Profile 2")

plot(Cgm(df_agg_1)[3].time_pm0_3, Cgm(df_agg_1)[2].γ_pm0_3, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.3 Variogram for Profile 1")
plot(Cgm(df_agg_2)[3].time_pm0_3, Cgm(df_agg_2)[2].γ_pm0_3, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.3 Variogram for Profile 2")

plot(Cgm(df_agg_1)[3].time_pm0_5, Cgm(df_agg_1)[2].γ_pm0_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.5 Variogram for Profile 1")
plot(Cgm(df_agg_2)[3].time_pm0_5, Cgm(df_agg_2)[2].γ_pm0_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.5 Variogram for Profile 2")

plot(Cgm(df_agg_1)[3].time_pm1_0, Cgm(df_agg_1)[2].γ_pm1_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM1.0 Variogram for Profile 1")
plot(Cgm(df_agg_2)[3].time_pm1_0, Cgm(df_agg_2)[2].γ_pm1_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM1.0 Variogram for Profile 2")

plot(Cgm(df_agg_1)[3].time_pm2_5, Cgm(df_agg_1)[2].γ_pm2_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM2.5 Variogram for Profile 1")
plot(Cgm(df_agg_2)[3].time_pm2_5, Cgm(df_agg_2)[2].γ_pm2_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM2.5 Variogram for Profile 2")

plot(Cgm(df_agg_1)[3].time_pm5_0, Cgm(df_agg_1)[2].γ_pm5_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM5.0 Variogram for Profile 1")
plot(Cgm(df_agg_2)[3].time_pm5_0, Cgm(df_agg_2)[2].γ_pm5_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM5.0 Variogram for Profile 2")

plot(Cgm(df_agg_1)[3].time_pm10_0, Cgm(df_agg_1)[2].γ_pm10_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM10.0 Variogram for Profile 1")
plot(Cgm(df_agg_2)[3].time_pm10_0, Cgm(df_agg_2)[2].γ_pm10_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM10.0 Variogram for Profile 2")
