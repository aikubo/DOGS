import CoolProp.CoolProp as cp
import pandas as pd
import numpy as np

# Range of pressure and temperature
minPressure = 1e7
maxPressure = 1.8e8
minTemperature = 273
maxTemperature = 1300

pressure = np.concatenate( (np.linspace(-1e8, 1e6, 5), np.arange(1e7, 1.8e8+1, 5e6), np.linspace(1.5e8, 1e10, 5)))
temperature = np.concatenate( (np.linspace(-1000, 273, 5), np.arange(273, 1300+1, 500), np.linspace(1350, 10000, 5)))

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
df.to_csv('fluid_properties_extended.csv', index=False)