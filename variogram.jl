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

        ########################### pm1_0 ####################################

        ########################### pm2_5 ####################################

        ########################### pm5_0 ####################################

        ########################### pm10_0 ####################################

        #println("lag ",i," correlation between head and tail: ", corr_pm01)
        topic = "Lag " *string(i)
        label_1_pm01 = "R: "*string(corr_pm01)[1:6]*", "
        label_2_pm01 = "γ: "*string(γ_pm01)[1:6] 
        label_1_pm03 = "R: "*string(corr_pm03)[1:6]*", "
        label_2_pm03 = "γ: "*string(γ_pm03)[1:6] 
        # lab = [label_1,label_2]

        push!(plot_array_pm01,Plots.scatter(df_tail_pm01,df_head_pm01,xlabel = "tail pm01", ylabel = "head pm01",title = topic, label= label_1_pm01*label_2_pm01 ))
        push!(plot_array_pm03,Plots.scatter(df_tail_pm03,df_head_pm03,xlabel = "tail pm03", ylabel = "head pm03",title = topic, label= label_1_pm03*label_2_pm03 ))
        
    end
    
    display(plot(plot_array_pm01..., layout=(5,2), size = (1000,1000)))
    display(plot(plot_array_pm03..., layout=(5,2), size = (1000,1000)))


    return corr_df.corr_pm0_1, corr_df.corr_pm0_3, γh_df.γ_pm0_1, γh_df.γ_pm0_3, time_df.time_pm0_1, time_df.time_pm0_3

end

Cgm(df_agg_1)
Cgm(df_agg_2)

corr_vec_profile_1_pm01 = Cgm(df_agg_1)[1] #1st return
corr_vec_profile_2_pm01 = Cgm(df_agg_2)[1]

γ_vec_profile_1_pm01 = Cgm(df_agg_1)[3] #3rd return
γ_vec_profile_2_pm01 = Cgm(df_agg_2)[3] #second return

time_vec_profile_1_pm01 = Cgm(df_agg_1)[5] #5th return
time_vec_profile_2_pm01 = Cgm(df_agg_2)[5] 

########################### pm0_3 ####################################

corr_vec_profile_1_pm03 = Cgm(df_agg_1)[2] #2nd return
corr_vec_profile_2_pm03 = Cgm(df_agg_2)[2]

γ_vec_profile_1_pm03 = Cgm(df_agg_1)[4] #4th return
γ_vec_profile_2_pm03 = Cgm(df_agg_2)[4] 

time_vec_profile_1_pm03 = Cgm(df_agg_1)[6] #6th return
time_vec_profile_2_pm03 = Cgm(df_agg_2)[6] 


Plots.bar(time_vec_profile_1_pm01,corr_vec_profile_1_pm01,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM01 Correlogram for Profile 1")
Plots.bar(time_vec_profile_2_pm01,corr_vec_profile_2_pm01,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM01 Correlogram for Profile 2")

Plots.bar(time_vec_profile_1_pm03,corr_vec_profile_1_pm03,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM03 Correlogram for Profile 1")
Plots.bar(time_vec_profile_2_pm03,corr_vec_profile_2_pm03,xlabel = "Lag", ylabel = "Correlation", label="", title = "PM03 Correlogram for Profile 2")

#((Dates.value(sum(df_agg_1[2:36,:datetime] - df_agg_1[1:35,:datetime])))/1000/60/60)>5 #what does this line do?


plot(time_vec_profile_1_pm01, γ_vec_profile_1_pm01, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM01 Variogram for Profile 1")
# plot!([91.3094], seriestype="vline",label= "",line=(:dot, 4))
# plot!([0.0012], seriestype="hline",label= "",line=(:dot, 4))
plot(time_vec_profile_2_pm01, γ_vec_profile_2_pm01 , linewidth=5, xlabel = "Lag", ylabel = "γ(h)", label="", title = "PM01 Variogram for Profile 2")

plot(time_vec_profile_1_pm03, γ_vec_profile_1_pm03, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM03 Variogram for Profile 1")
plot(time_vec_profile_2_pm03, γ_vec_profile_2_pm03, linewidth=5, xlabel = "Lag", ylabel = "γ(h)", label="", title = "PM03 Variogram for Profile 2")



