using Pkg
Pkg.activate("D:/UTD/UTDFall2022/VariogramsLoRa/firmware/LoRa")
using DelimitedFiles,CSV,DataFrames,Dates,Statistics,DataStructures,Plots,TimeSeries,Impute,LaTeXStrings
using StatsBase, Statistics,Polynomials,Peaks,RollingFunctions,DecisionTree,Shuffle,Metrics
using ScikitLearn: @sk_import, fit!, predict
@sk_import ensemble: RandomForestRegressor
using ScikitLearn.GridSearch: RandomizedSearchCV



x = CSV.read("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Wind_TPH_Range.csv", DataFrame)
x_subset = select(x, ["MeanWindSpeed","MeanWindDirection","MeanPressure","MeanTemperature","MeanHumidity","pm2.5"])
x_final = disallowmissing(x_subset[completecases(x_subset), :])
mat_x = Matrix(x_final)[:,1:5]
y = x_final[:,6]
n = size(x_final, 1)
train_size = Int(round(0.8*n))
indices = shuffle(1:n)
train_indices = indices[1:train_size]
test_indices = indices[train_size+1:end]

x_train, y_train = mat_x[train_indices, :], y[train_indices]
x_test, y_test = mat_x[test_indices, :], y[test_indices]

n_estimators = 100
max_depth = 5
model = RandomForestRegressor(n_estimators=n_estimators, max_depth=max_depth, random_state=0)
fit!(model, x_train, y_train)

# Make predictions on test data
y_pred = predict(model, x_test)

# Evaluate the performance of the random forest model
mean_squared_error = sum((y_test.- y_pred).^2)/length(y_test)

importances = model.feature_importances_
r2 = r2_score(y_test, y_pred)
println("R-squared value: ", r2)
# Create horizontal bar chart of feature importances
barh(1:length(importances), sort(importances, rev=true), xlabel="Importance", ylabel="Feature", 
    label=["Feature " * string(i) for i=1:length(importances)])

@show mean_squared_error