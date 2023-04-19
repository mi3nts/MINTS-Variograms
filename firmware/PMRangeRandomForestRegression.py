# -*- coding: utf-8 -*-
"""
Created on Mon Apr 27 14:12:17 2020

@author: balag
"""
# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score
from sklearn.model_selection import train_test_split

#import statsmodels.api as sm

df1 = pd.read_csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\Wind_TPH_Range.csv")
df2 = pd.read_csv("D:\\UTD\\UTDFall2022\\VariogramsLoRa\\firmware\\data\\Parameters\\csv\\PMRollingMean.csv")

merged_df = pd.merge(df1, df2, on='RollingTime')

col_ls = ["RollingTime","Range pc0.1","Range pc0.3","Range pc0.5","Range pc1.0","Range pc2.5","Range pc5.0","Range pc10.0",
          "Range pm0.1","Range pm0.3","Range pm0.5","Range pm1.0","Range pm2.5","Range pm5.0","Range pm10.0",
          "Wind Speed", "Wind Direction", "Temperature", "Pressure", "Humidity",
          "pc0.1","pc0.3","pc0.5","pc1.0","pc2.5","pc5.0","pc10.0",
          "pm0.1","pm0.3","pm0.5","pm1.0","pm2.5","pm5.0","pm10.0",]

df_updated =  merged_df.dropna()

df_updated.columns = col_ls 

x = df_updated.iloc[:, 15:34].values
y = df_updated.iloc[:, 1:15].values
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=0)
n_estimators = 100
max_depth = 5
models = []
for i in range(y.shape[1]):
    model = RandomForestRegressor(n_estimators=n_estimators, max_depth=max_depth, random_state=0)
    model.fit(x_train, y_train[:, i])
    models.append(model)

# Make predictions on test set for each target variable
y_preds = np.zeros(y_test.shape)
for i, model in enumerate(models):
    y_preds[:, i] = model.predict(x_test)

r2s = []
for i in range(y.shape[1]):
    r2 = r2_score(y_test[:, i], y_preds[:, i])
    r2s.append(r2)

print("R-squared values:", r2s)

# Get feature importances and their names
importances = []
feature_names = df_updated.columns[15:34]
for model in models:
    importances.append(model.feature_importances_)

# Rename feature importances
named_importances = []
for importance in importances:
    named_importances.append(dict(zip(feature_names, importance)))

# Sort feature importances in increasing order
sorted_importances = []
for named_importance in named_importances:
    sorted_importance = {k: v for k, v in sorted(named_importance.items(), key=lambda item: item[1])}
    sorted_importances.append(sorted_importance)

# Create horizontal bar plot of feature importances for each target variable
for i in range(y.shape[1]):
    plt.barh(range(len(sorted_importances[i])), list(sorted_importances[i].values()), align='center')
    plt.yticks(range(len(sorted_importances[i])), list(sorted_importances[i].keys()))
    plt.xlabel("Importance")
    plt.ylabel("Features")
    plt.title("Feature Importances for Measurement of {}".format(df_updated.columns[i+1]))
    plt.show()
