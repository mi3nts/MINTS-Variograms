using Pkg
Pkg.activate("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/LoRa")
#include("CentralNodeGunter.jl") # Run it only when needed
using Plots
function pdf_plots(vec_df,x_lab,path)
    for i in 1:1:7
        for j in names(vec_df[i])[9:15]
            h = StatsBase.fit(Histogram, Float64.(skipmissing(vec_df[i][!,j])))
            r = h.edges[1]
            x = first(r)+step(r)/2:step(r):last(r)
            plot(h,xlabel = dict_plot_pm[j] * x_lab, ylabel = "Density",label = false)
            plot!([0;x], [0;h.weights],linewidth = 2,label = false,title = Date(vec_df[i].RollingTime[1]))
            mkdir(path[i]*"/"*j)
            png(path[i]*"/"*j*"/"*"PDF")
        end
    end
end
pm_unit = "(μg/m"*latexstring("^3")*")"
function creating_plot_paths(path,df)
    date_vec =unique(Date.(df.date))[1:7]
    date_vec_string = replace.(string.(date_vec),"-" => "/")
    path_plots = string.(path,date_vec_string)
    return mkpath.(path_plots)
   
end

range_pdf_path = creating_plot_paths("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/RangePdf/",df_range)
sill_pdf_path = creating_plot_paths("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/data/Parameters/SillPdf/",df_sill)

sill_unit = pm_unit*latexstring("^2")
pdf_plots(vec_df_range," Range(in mins)",range_pdf_path)
pdf_plots(vec_df_sill," Sill "*sill_unit,sill_pdf_path)

function pdf_plots(vec_df,x_lab,path)
    for i in 1:1:7
        for j in names(vec_df[i])[9:15]
            h = StatsBase.fit(Histogram, Float64.(skipmissing(vec_df[i][!,j])))
            r = h.edges[1]
            x = first(r)+step(r)/2:step(r):last(r)
            plot(h,xlabel = dict_plot_pm[j] * x_lab, ylabel = "Density",label = false)
            plot!([0;x], [0;h.weights],linewidth = 2,label = false,title = Date(vec_df[i].RollingTime[1]))
            mkdir(path[i]*"/"*j)
            png(path[i]*"/"*j*"/"*"PDF")
        end
    end
end



