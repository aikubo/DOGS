import CoolProp.CoolProp as cp
import pandas as pd
import numpy as np

# Range of pressure and temperature
minPressure = 1e4
maxPressure = 1.8e9
minTemperature = 275
maxTemperature = 1300

pressure = np.concatenate( (np.linspace(minPressure, 1e5, 5), np.linspace(1.1e5, 1e8, 100), np.linspace(1.1e8, 1e10, 5)))
temperature = np.concatenate( (np.linspace(minTemperature-100, minTemperature, 5), np.arange(minTemperature+5, maxTemperature, 100), np.linspace(maxTemperature+100, maxTemperature+500, 5)))

data = np.zeros((pressure.size * temperature.size, 6))

for i in np.arange(pressure.size):
    for j in np.arange(temperature.size):
        data[i * temperature.size + j, 0] = pressure[i]
        data[i * temperature.size + j, 1] = temperature[j]

        if pressure[i] < minPressure or temperature[j] < minTemperature:
            data[i * temperature.size + j, 0] = pressure[i]
            data[i * temperature.size + j, 1] = temperature[j]
            data[i * temperature.size + j, 2] = cp.PropsSI('D', 'P', minPressure, 'T', minTemperature, 'Water')
            data[i * temperature.size + j, 3] = cp.PropsSI('V', 'P', minPressure, 'T', minTemperature, 'Water')
            data[i * temperature.size + j, 4] = cp.PropsSI('H', 'P', minPressure, 'T', minTemperature, 'Water')
            data[i * temperature.size + j, 5] = cp.PropsSI('U', 'P', minPressure, 'T', minTemperature, 'Water')
            continue
        elif pressure[i] > maxPressure or temperature[j] > maxTemperature:
            data[i * temperature.size + j, 0] = pressure[i]
            data[i * temperature.size + j, 1] = temperature[j]
            data[i * temperature.size + j, 2] = cp.PropsSI('D', 'P', maxPressure, 'T', maxTemperature, 'Water')
            data[i * temperature.size + j, 3] = cp.PropsSI('V', 'P', maxPressure, 'T', maxTemperature, 'Water')
            data[i * temperature.size + j, 4] = cp.PropsSI('H', 'P', maxPressure, 'T', maxTemperature, 'Water')
            data[i * temperature.size + j, 5] = cp.PropsSI('U', 'P', maxPressure, 'T', maxTemperature, 'Water')
            continue
        elif pressure[i] > minPressure and pressure[i] < maxPressure and temperature[j] > minTemperature and temperature[j] < maxTemperature:
            data[i * temperature.size + j, 2] = cp.PropsSI('D', 'P', pressure[i], 'T', temperature[j], 'Water')
            data[i * temperature.size + j, 3] = cp.PropsSI('V', 'P', pressure[i], 'T', temperature[j], 'Water')
            data[i * temperature.size + j, 4] = cp.PropsSI('H', 'P', pressure[i], 'T', temperature[j], 'Water')
            data[i * temperature.size + j, 5] = cp.PropsSI('U', 'P', pressure[i], 'T', temperature[j], 'Water')

# Write out fluid_properties_extended.csv
df = pd.DataFrame(data, columns = ['pressure', 'temperature', 'density', 'viscosity', 'enthalpy', 'internal_energy'])
df.to_csv('water_extended.csv', index=False)
