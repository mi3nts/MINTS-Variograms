using Pkg
Pkg.activate("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\LoRa")
using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures


path = "D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/001e063739c7/"

fulldirpaths=filter(isdir,readdir(path,join=true))
fulldirpaths_month = []
fulldirpaths_days = []
date_str = []
append!(fulldirpaths_month,filter(isdir,readdir(fulldirpaths[1],join=true)))
for i in 1:1:length(fulldirpaths_month)
    append!(fulldirpaths_days, (filter(isdir,readdir(fulldirpaths_month[i],join=true))))
end
append!(date_str,last.(fulldirpaths_days,10))

fulldirpaths_days
date_str = replace.(date_str, "\\" => "-",count=3)
csv_date = Date.(date_str, "yyyy-mm-dd")

# This is how the files name should end ======> IPS7100_2022_10_05.csv
data = ["abc","bcd","def","GHF"]
findall( x -> occursin("b", x), data) # ====> use this code for finding IPS sensor path