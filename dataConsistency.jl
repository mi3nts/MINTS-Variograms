using CSV, DataFrames, Dates

#22
compiled_df = DataFrame()
date_compiled_df = DataFrame()
first_raw_data_frame = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/profiles/2022/01/27/MINTS_001e06305a61_IPS7100_2022_01_27.csv", DataFrame)
second_raw_data_frame = CSV.read("C:/Users/va648/VSCode/MINTS-Variograms/data/profiles/2022/01/28/MINTS_001e06305a61_IPS7100_2022_01_28.csv", DataFrame)
append!(compiled_df, first_raw_data_frame)
append!(compiled_df, second_raw_data_frame) 
ms = [parse(Float64, x[20:26]) for x in first_raw_data_frame[!,:dateTime]]
ms = string.(round.(ms,digits = 3)*1000)
ms = chop.(ms,tail= 2)
first_raw_data_frame.dateTime =  chop.(first_raw_data_frame.dateTime,tail= 6)
first_raw_data_frame.dateTime = first_raw_data_frame.dateTime.* ms
first_raw_data_frame.dateTime = DateTime.(first_raw_data_frame.dateTime,"yyyy-mm-dd HH:MM:SS.sss")
append!(date_compiled_df, first_raw_data_frame)
ms = [parse(Float64, x[20:26]) for x in second_raw_data_frame[!,:dateTime]]
ms = string.(round.(ms,digits = 3)*1000)
ms = chop.(ms,tail= 2)
second_raw_data_frame.dateTime =  chop.(second_raw_data_frame.dateTime,tail= 6)
second_raw_data_frame.dateTime = second_raw_data_frame.dateTime.* ms
second_raw_data_frame.dateTime = DateTime.(second_raw_data_frame.dateTime,"yyyy-mm-dd HH:MM:SS.sss")
append!(date_compiled_df, second_raw_data_frame)


raw_duplicate_arr = []
for i in 1:length(compiled_df.dateTime)
    if i != length(compiled_df.dateTime)
        if parse(Int64, compiled_df.dateTime[i][18:19]) != parse(Int64, compiled_df.dateTime[i+1][18:19]) - 1 && parse(Int64, compiled_df.dateTime[i][18:19]) != parse(Int64, compiled_df.dateTime[i+1][18:19])
            if compiled_df.dateTime[i][18:19] != "59" && compiled_df.dateTime[i][18:19] != "00"
                append!(raw_duplicate_arr, i)
            end
        end
    end
end
print(raw_duplicate_arr)

difference_arr = []
for i in 1:(length(raw_duplicate_arr)-1)
    push!(difference_arr, date_compiled_df.dateTime[raw_duplicate_arr[i] + 1] - date_compiled_df.dateTime[raw_duplicate_arr[i]])
end

println(difference_arr)
println(findmax(difference_arr))
println(last(date_compiled_df.dateTime) - date_compiled_df.dateTime[last(raw_duplicate_arr)])
println(date_compiled_df.dateTime[first(raw_duplicate_arr)] - first(date_compiled_df.dateTime))

# result_df = DataFrame()

# append!(result_df, data_frame[1:first(raw_duplicate_arr), [:dateTime, :pm0_1, :pm0_3, :pm0_5, :pm1_0, :pm2_5, :pm5_0, :pm10_0]])
# CSV.write("C:/Users/va648/VSCode/MINTS-Variograms/data/profiles/consistentPM.csv", result_df)
