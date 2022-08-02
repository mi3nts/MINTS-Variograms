using CSV,DataFrames, Dates, Statistics, GeoStats,Variography,DataStructures,Plots,Distances,Polynomials
#x = reshape([0.1, 0.3, -0.1], 3, 1);
Distances.euclidean([0.5], [1.0])
# function time_series(path)
#     data_frame = CSV.read(path,DataFrame)
#     μs = [parse(Float64,x[20:26]) for x in data_frame[!,:dateTime]]
#     data_frame.μs  = Second.(round.(Int,μs))
#     data_frame.dateTime = [x[1:19] for x in data_frame[!,:dateTime]]
#     data_frame.dateTime = DateTime.(data_frame.dateTime,"yyyy-mm-dd HH:MM:SS")
#     data_frame.dateTime = data_frame.dateTime + data_frame.μs
#     data_frame = select!(data_frame, Not(:μs))
#     df_agg = select(data_frame,Not(:dateTime))
#     function change_data(x)
#         x = convert(Vector{Float64}, x)
#         return x
#     end
#     mapcols!(change_data, df_agg)
#     df_agg.datetime = data_frame.dateTime
#     return df_agg
# end

# #df_agg_1 = time_series("D://UTD//UTDFall2021//LoRa//VariogramsLoRa//firmware//data//MINTS_001e06373996_IPS7100_2022_01_01.csv")
# df_agg_1 = time_series("D://UTD//UTDFall2021//LoRa//VariogramsLoRa//firmware//data//MINTS_001e06373996_IPS7100_2022_01_02.csv")

# timeTick = Dates.format.(df_agg_1.datetime, "HH:MM:SS")
# DateTick = Dates.format.(df_agg_1.datetime, "yyyy-mm-dd")
# unique_date = unique(DateTick)
# titleDateTick =  "PM 0.1 distribution for "*unique_date[1]
# plot(timeTick,df_agg_1.pm0_1,xrot=30,label = "", ylabel = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )
# #plot(timeTick,df_agg_2.pm0_1,xrot=30, label = "PM 0.1" ,title = titleDateTick, xlabel = "Time",dpi = 100 )


# df= df_agg_1
# #function Cgm(df)

# timeTick = Dates.format.(df.datetime, "HH:MM:SS")
# DateTick = Dates.format.(df.datetime, "yyyy-mm-dd")
# unique_date = unique(DateTick)


# plot_array = Any[]
# corr_vec = Any[]
# time_arr = Any[] 
# γh = Any[]
# n = names(df)[8:14]
# for k in n
#     for i=1:1:2000
#         # Lag statistics 
#         # Lag statistics for profile n
#         df_head = df[1:14400,k]
#         df_tail = df[i+1:14400+i,k]#Need to fix the limits,because of the limited length of the vector
#         time_head = df[1:14400,:datetime]
#         time_tail = df[i+1:14400+i,:datetime]
#         time_diff = time_tail - time_head
#         #println("time_diff",time_diff)
#         avg_lag = ((Dates.value(sum(time_diff))/14400)/1000)/60
#         head_tail_diff = df_head - df_tail
#         γ = sum(head_tail_diff.^2)/(2*14400)
#         #println("lag ", i," Statistics")
#         #println("Avg Lag",avg_lag)
#         # Head Statistics
#         head_mean = mean(df_head)
#         #println("head mean: ",head_mean)
#         head_variance = var(df_head)
#         #println("head variance: ",head_variance,)

#         # Tail Statistics
#         tail_mean = mean(df_tail)
#         #println("tail mean: ",tail_mean)
#         tail_variance = var(df_tail)
#         #println("tail variance: ",tail_variance)

#         #Correlation between Head and Tail
#         corr = cor(df_head,df_tail)
#         append!(corr_vec,corr)
#         append!(γh,γ)
#         append!(time_arr,avg_lag)
#         #println("lag ",i," correlation between head and tail: ", corr)
#         topic = "Lag " *string(i)
#         label_1 = "R: "*string(corr)[1:6]*", "
#         label_2 = "γ: "*string(γ)[1:6] 
#         lab = [label_1,label_2]
#         push!(plot_array,Plots.scatter(df_tail,df_head,xlabel = "tail", ylabel = "head",title = topic, label= label_1*label_2 ))
        
#     end
#     corr_vec = []
#     γh = []
#     time_arr = []
#     plot_title = "Lag Statistics for "*k 
#     display(plot(plot_array..., layout=(5,2),size = (1000,1000),plot_title))
#     #return corr_vec,γh,time_arr
# end
# #end
# Cgm(df_agg_1)
# #Cgm(df_agg_2)

# corr_vec_profile_1 = Cgm(df_agg_1)[1]
# #corr_vec_profile_2 = Cgm(df_agg_2)[1]

# γ_vec_profile_1 = Cgm(df_agg_1)[2]
# #γ_vec_profile_2 = Cgm(df_agg_2)[2]

# time_vec_profile_1 = Cgm(df_agg_1)[3]
# #time_vec_profile_2 = Cgm(df_agg_2)[3]


# #Plots.bar(time_vec_profile_1,corr_vec_profile_1,xlabel = "Lag", ylabel = "Correlation", label="", title = "Correlogram for Profile 1")
# #Plots.bar(time_vec_profile_2,corr_vec_profile_2,xlabel = "Lag", ylabel = "Correlation", label="", title = "Correlogram for Profile 2")

# #((Dates.value(sum(df_agg_1[2:36,:datetime] - df_agg_1[1:35,:datetime])))/1000/60/60)>5


# plot(time_vec_profile_1,γ_vec_profile_1,linewidth=5,xlabel = "Δt (in minutes)", ylabel = "γ(t)", label="", title = "Variogram for Central Node")
# Variography.WeightedLeastSquares()
# # Central Node reboots after 8 hrs or 24 hrs. It takes 10 mins to reboot. Consider that while coding  
# #plot!([93.3094], seriestype="vline",label= "",line=(:dot, 4))
# #plot!([0.00107], seriestype="hline",label= "",line=(:dot, 4))
# #plot(time_vec_profile_2,γ_vec_profile_2,xlabel = "Lag", ylabel = "γ(h)", label="", title = "Variogram for Profile 2")

# # Empirical Variograms

# # using GeoStats
# # using Plots

# # # attribute table
# # table = (Z=[1.,0.,1.],)

# # # coordinates for each row
# # coord = [(25.,25.), (50.,75.), (75.,50.)]

# # # georeference data
# # 𝒟 = georef(table, coord)

# # # estimation domain
# # 𝒢 = CartesianGrid(100, 100)

# # # estimation problem
# # problem = EstimationProblem(𝒟, 𝒢, :Z)

# # # choose a solver from the list of solvers
# # solver = Kriging(
# #   :Z => (variogram=GaussianVariogram(range=35.),)
# # )

# # # solve the problem
# # solution = solve(problem, solver)

# # # plot the solution
# # contourf(solution, clabels=true)

