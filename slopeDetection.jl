using Plots, GeoStats, Variography, DataFrames


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
            return timevector[i-1], yvector[i-1] #could possible be changed to yvector[i] - will have to see
        end
    end
end


variogram_df = DataFrame(variogram1 = [],
                         variogram2 = [],
                         variogram3 = [])
#pm25

time25 = [16.21238095238095, 30.804761904761904, 45.52285714285714, 61.338095238095235, 77.39238095238096, 93.51, 109.6, 125.69238095238096, 141.16333333333333, 156.69476190476192]
y25 = [13.843837129093371, 26.650074745396925, 46.153377198701165, 65.25384534850907, 76.23159420492385, 81.13751798702539, 83.22468029774765, 81.18355503679891, 82.60977161279929, 79.78946049500257]
time50 = [16.21238095238095, 30.804761904761904, 45.52285714285714, 61.338095238095235, 77.39238095238096, 93.51, 109.6, 125.69238095238096, 141.16333333333333, 156.69476190476192]
y50 = [19.467326438842676, 34.35451265982, 59.76460576686976, 82.74047943787092, 93.75473092223864, 96.31528841573186, 99.76159076035712, 94.60270795287425, 98.42236746274659, 97.93208124246149]
time100 = [16.21238095238095, 30.804761904761904, 45.52285714285714, 61.338095238095235, 77.39238095238096, 93.51, 109.6, 125.69238095238096, 141.16333333333333, 156.69476190476192]
y100 = [19.467326438842676, 34.35451265982, 59.76460576686976, 82.74047943787092, 93.75473092223864, 96.31528841573186, 99.76159076035712, 94.60270795287425, 98.42236746274659, 97.9692113052307]

push!(variogram_df.variogram1, plot(time25, y25, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM2.5 Variogram for Profile 1"))
push!(variogram_df.variogram2, plot(time50, y50, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM5.0 Variogram for Profile 1"))
push!(variogram_df.variogram3, plot(time100, y100, linewidth=5, xlabel = "Lag", ylabel = "γ(t)", label="", title = "PM10.0 Variogram for Profile 1"))


# plot([1, 2, 3, 4, 5], [1, 4, 9, 16, 25])
# vline!([2], label= "rand",line=(:dot, 7))
# hline!([4], label= "rand",line=(:dot, 7))

# plot([1, 2, 3, 4, 5], [1, 16, 12, 17, 25])
# vline!([3], label= "rand",line=(:dot, 7))
# hline!([12], label= "rand",line=(:dot, 7))

plt1 = plot(variogram_df.variogram1..., size = (1000,1000))
vline!([sillRange(time25, y25)[1]], label= "range",line=(:dot, 7))
hline!([sillRange(time25, y25)[2]], label= "sill",line=(:dot, 7))
display(plt1)
empty!(variogram_df.variogram1)
plt2 = plot(variogram_df.variogram2..., size = (1000,1000))
vline!([sillRange(time50, y50)[1]], label= "range",line=(:dot, 7))
hline!([sillRange(time50, y50)[2]], label= "sill",line=(:dot, 7))
display(plt2)
empty!(variogram_df.variogram2)
plt3 = plot(variogram_df.variogram3..., size = (1000,1000))
vline!([sillRange(time100, y100)[1]], label= "range",line=(:dot, 7))
hline!([sillRange(time100, y100)[2]], label= "sill",line=(:dot, 7))
display(plt3)
empty!(variogram_df.variogram3)


# print(dy_vec)
# print(dt_vec)
# print(slope_vec)
