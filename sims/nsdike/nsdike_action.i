mu = 100
rho = 3000
k = 4
cp = 1100
alpha = 1

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 50
    ymin = 0
    ymax = 200
    nx = 50
    ny = 50
  []
[]

[Modules]
  [NavierStokesFV]
    # General parameters
    compressibility = 'incompressible'
    porous_medium_treatment = false
    add_energy_equation = true

    # Material properties
    density = 'rho'
    dynamic_viscosity = 'mu'
    thermal_conductivity = 'k'
    specific_heat = 'cp'

    # Initial conditions
    initial_velocity = '0 5 0'
    initial_pressure = 0.0
    initial_temperature = 500 #K

    # Inlet boundary conditions
    inlet_boundaries = 'bottom'
    momentum_inlet_types = 'fixed-velocity'
    momentum_inlet_function = '0 1'
    energy_inlet_types = 'fixed-temperature'
    energy_inlet_function = '1'

    # Wall boundary conditions
    wall_boundaries = 'left right'
    momentum_wall_types = 'freeslip noslip'
    energy_wall_types = 'heatflux heatflux'
    energy_wall_function = '0 0'

    # Outlet boundary conditions
    outlet_boundaries = 'top'
    momentum_outlet_types = 'fixed-pressure'
    pressure_function = '0'

    mass_advection_interpolation = 'average'
    momentum_advection_interpolation = 'average'
    energy_advection_interpolation = 'average'
  []
[]

[FunctorMaterials]
  [const_functor]
    type = ADGenericFunctorMaterial
    prop_names = 'cp k rho mu alpha'
    prop_values = '${cp} ${k} ${rho} ${mu} ${alpha}'
  []
[]

[Postprocessors]
  [temp]
    type = ElementAverageValue
    variable = T_fluid
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'
  nl_rel_tol = 1e-12
[]

[Outputs]
  exodus = true
  csv = true
[]
