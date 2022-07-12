using Plots, GeoStats, Variography, DataFrames, CSV


function checkNeg(slopevec)
    val = 0

    for i in 1:length(slopevec)
        if slopevec[i] > 0
            val = val
        elseif slopevec[i] < 0
            val = val - 1
        elseif slopevec[i] == 0
            val = val
        end
    end

    if val == 0
        return true
    elseif val != 0
        return false
end
end

function sillRange(timevector::Vector{Float64}, yvector::Vector{Float64})
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
            return timevector[i], yvector[i] #could possible be changed to yvector[i-1] - will have to see
            break
        end
    end

    if checkNeg(slope_vec)
        return last(timevector), last(yvector)
    end
end


variogram_df = DataFrame(variogram1pm01 = [], variogram2pm01 = [], 
                         variogram1pm03 = [], variogram2pm03 = [], 
                         variogram1pm05 = [], variogram2pm05 = [], 
                         variogram1pm10 = [], variogram2pm10 = [], 
                         variogram1pm25 = [], variogram2pm25 = [], 
                         variogram1pm50 = [], variogram2pm50 = [], 
                         variogram1pm100 =[],variogram2pm100 = [])

timepf1 = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/timepf1.csv", DataFrame)
timepf2 = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/timepf2.csv", DataFrame)
ypf1 = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/ypf1.csv", DataFrame)
ypf2 = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/ypf2.csv", DataFrame)

push!(variogram_df.variogram1pm01, plot(timepf1.time_pm0_1, ypf1.γ_pm0_1, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.1 Variogram for Profile 1"))
push!(variogram_df.variogram1pm03, plot(timepf1.time_pm0_3, ypf1.γ_pm0_3, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.3 Variogram for Profile 1"))
push!(variogram_df.variogram1pm05, plot(timepf1.time_pm0_5, ypf1.γ_pm0_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.5 Variogram for Profile 1"))
push!(variogram_df.variogram1pm10, plot(timepf1.time_pm1_0, ypf1.γ_pm1_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM1.0 Variogram for Profile 1"))
push!(variogram_df.variogram1pm25, plot(timepf1.time_pm2_5, ypf1.γ_pm2_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM2.5 Variogram for Profile 1"))
push!(variogram_df.variogram1pm50, plot(timepf1.time_pm5_0, ypf1.γ_pm5_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM5.0 Variogram for Profile 1"))
push!(variogram_df.variogram1pm100, plot(timepf1.time_pm10_0, ypf1.γ_pm10_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM10.0 Variogram for Profile 1"))

push!(variogram_df.variogram2pm01, plot(timepf2.time_pm0_1, ypf2.γ_pm0_1, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.1 Variogram for Profile 2"))
push!(variogram_df.variogram2pm03, plot(timepf2.time_pm0_3, ypf2.γ_pm0_3, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.3 Variogram for Profile 2"))
push!(variogram_df.variogram2pm05, plot(timepf2.time_pm0_5, ypf2.γ_pm0_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM0.5 Variogram for Profile 2"))
push!(variogram_df.variogram2pm10, plot(timepf2.time_pm1_0, ypf2.γ_pm1_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM1.0 Variogram for Profile 2"))
push!(variogram_df.variogram2pm25, plot(timepf2.time_pm2_5, ypf2.γ_pm2_5, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM2.5 Variogram for Profile 2"))
push!(variogram_df.variogram2pm50, plot(timepf2.time_pm5_0, ypf2.γ_pm5_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM5.0 Variogram for Profile 2"))
push!(variogram_df.variogram2pm100, plot(timepf2.time_pm10_0, ypf2.γ_pm10_0, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM10.0 Variogram for Profile 2"))

plt1pm01 = plot(variogram_df.variogram1pm01..., size=(1000,1000))
vline!([sillRange(timepf1.time_pm0_1, ypf1.γ_pm0_1)[1]],label= "", line=(:dot, 7)) #range then sill
hline!([sillRange(timepf1.time_pm0_1,ypf1.γ_pm0_1)[2]],label= "", line=(:dot, 7))
display(plt1pm01)
empty!(variogram_df.variogram1pm01)
plt2pm01 = plot(variogram_df.variogram2pm01..., size=(1000,1000))
vline!([sillRange(timepf2.time_pm0_1, ypf2.γ_pm0_1)[1]],label= "", line=(:dot, 7))
hline!([sillRange(timepf2.time_pm0_1,ypf2.γ_pm0_1)[2]],label= "", line=(:dot, 7))
display(plt2pm01)
empty!(variogram_df.variogram2pm01)

plt1pm03 = plot(variogram_df.variogram1pm03..., size=(1000,1000))
vline!([sillRange(timepf1.time_pm0_3, ypf1.γ_pm0_3)[1]],label= "", line=(:dot, 7))
hline!([sillRange(timepf1.time_pm0_3,ypf1.γ_pm0_3)[2]],label= "", line=(:dot, 7))
display(plt1pm03)
empty!(variogram_df.variogram1pm03)
plt2pm03 = plot(variogram_df.variogram2pm03..., size=(1000,1000))
vline!([sillRange(timepf2.time_pm0_3, ypf2.γ_pm0_3)[1]],label= "", line=(:dot, 7))
hline!([sillRange(timepf2.time_pm0_3,ypf2.γ_pm0_3)[2]],label= "", line=(:dot, 7))
display(plt2pm03)
empty!(variogram_df.variogram2pm03)
#no downward trend

plt1pm05 = plot(variogram_df.variogram1pm05..., size=(1000,1000))
vline!([sillRange(timepf1.time_pm0_5, ypf1.γ_pm0_5)[1]],label= "", line=(:dot, 7))
hline!([sillRange(timepf1.time_pm0_5,ypf1.γ_pm0_5)[2]],label= "", line=(:dot, 7))
display(plt1pm05)
empty!(variogram_df.variogram1pm01)
plt2pm05 = plot(variogram_df.variogram2pm05..., size=(1000,1000))
vline!([sillRange(timepf2.time_pm0_5, ypf2.γ_pm0_5)[1]],label= "", line=(:dot, 7))
hline!([sillRange(timepf2.time_pm0_5,ypf2.γ_pm0_5)[2]],label= "", line=(:dot, 7))
display(plt2pm05)
empty!(variogram_df.variogram2pm05)

plt1pm10 = plot(variogram_df.variogram1pm10..., size=(1000,1000))
vline!([sillRange(timepf1.time_pm1_0, ypf1.γ_pm1_0)[1]],label= "", line=(:dot, 7))
hline!([sillRange(timepf1.time_pm1_0, ypf1.γ_pm1_0)[2]],label= "", line=(:dot, 7))
display(plt1pm10)
empty!(variogram_df.variogram1pm10)
plt2pm10 = plot(variogram_df.variogram2pm10..., size=(1000,1000))
vline!([sillRange(timepf2.time_pm1_0, ypf2.γ_pm1_0)[1]],label= "", line=(:dot, 7))
hline!([sillRange(timepf2.time_pm1_0,ypf2.γ_pm1_0)[2]],label= "", line=(:dot, 7))
display(plt2pm10)
empty!(variogram_df.variogram2pm10)
