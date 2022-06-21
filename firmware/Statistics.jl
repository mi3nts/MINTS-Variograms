using PlotlyJS, DataFrames

df = DataFrame(
    x=[1, 3, 2, 4],
    y=[1, 2, 3, 4],
)
p1 = PlotlyJS.plot(df, x=:x, y=:y, Layout(title="Unsorted Input"))

p2 = PlotlyJS.plot(sort(df, :x), x=:x, y=:y, Layout(title="Sorted Input"))

[p1; p2]