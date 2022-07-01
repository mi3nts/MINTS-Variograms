using Plots, GeoStats, Variography, DataFrames



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

time_vec = [16.21238095238095, 30.804761904761904, 45.52285714285714, 61.338095238095235, 77.39238095238096, 93.51, 109.6, 125.69238095238096, 141.16333333333333, 156.69476190476192]
y_vec = [0.00023986569631751027, 0.00045795869785267165, 0.0006293987815538897, 0.0009169734187253521, 0.0010438143308727727, 0.0010719436827893926, 0.001029916425601532, 0.0010090187305730426, 0.0010173017960575165, 0.0009932155907799458]
#data from PM01

print(sillRange(y_vec, time_vec))

plot(time_vec, y_vec)
plot!([sillRange(y_vec, time_vec)[1]], seriestype="vline",label= "",line=(:dot, 4))
plot!([sillRange(y_vec, time_vec)[2]], seriestype="hline",label= "",line=(:dot, 4))
