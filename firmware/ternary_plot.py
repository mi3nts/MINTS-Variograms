import matplotlib.pyplot as plt
import numpy as np

# Sample data for pressure, temperature, and humidity
p = [1013.25, 1000.00, 950.00]  # in hPa
t = [25, 30, 20]  # in degrees Celsius
rh = [50, 60, 70]  # in %

# Convert the data into percentages
p_pct = np.array(p) / 1013.25
t_pct = np.array(t) / 50
rh_pct = np.array(rh) / 100

# Calculate the remaining percentage for plotting on the ternary plot
remaining_pct = 1 - p_pct - t_pct - rh_pct

# Create a ternary plot
fig, ax = plt.subplots(figsize=(5,5))
ax.axis('off')
ax.triplot([0, 0.5, 1], [0, np.sqrt(3)/2, 0], linewidth=1.0, color='black')
ax.plot(remaining_pct/2 + t_pct/2, np.sqrt(3)/2 * t_pct, 'o', markersize=10, alpha=0.8)
ax.plot(1 - rh_pct - remaining_pct/2, np.sqrt(3)/2 * rh_pct, 'o', markersize=10, alpha=0.8)
ax.plot(p_pct, np.zeros_like(p_pct), 'o', markersize=10, alpha=0.8)

# Label the corners of the ternary plot
ax.text(-0.05, -0.05, 'Pressure', fontsize=12, ha='right', va='top')
ax.text(1.05, -0.05, 'Humidity', fontsize=12, ha='left', va='top')
ax.text(0.5, np.sqrt(3)/2+0.05, 'Temperature', fontsize=12, ha='center', va='bottom')

# Add a title
ax.set_title('Air Quality Ternary Plot')

# Show the plot
plt.show()
