#units
# temperature: K
# density: kg/m^3
# thermal conductivity: W/mK
# specific heat: J/kg K

mu = 1
rho = 1
k = 1e-3
cp = 1
alpha = 1

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 10
    xmax = 10
    ymax = 10
    nz = 5
    zmax = 5
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '2 10 5'
    block_name = dike
    input = gen
  []
  [wallrock]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '2 0 0 '
    top_right = '10 10 5'
    block_name = wallrock
    input = dike
  []
  [contact_area]
    type = SideSetsBetweenSubdomainsGenerator
    input = wallrock
    primary_block = 'dike'
    paired_block = 'wallrock'
    new_boundary = 'dike_contact'
  []
[]

[Variables]
  [T]

  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T
  []
  [time_derivative]
    type = HeatConductionTimeDerivative
    variable = T
  []
[]



[Materials]
    #https://material-properties.org/granite-density-heat-capacity-thermal-conductivity/
  [thermal_granite]
    type = HeatConductionMaterial
    thermal_conductivity = 3.2 #W/mK
    specific_heat = 790 #J/kgK
    block = 'wallrock'
  []
  [density_granite]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 2750 # kg m^-3
    block = 'wallrock'
  []

  #Lesher & Spera
  [thermal_dike]
    type = HeatConductionMaterial
    thermal_conductivity = 1.48
    specific_heat = 1450
    block = 'dike'
  []
  [density_dik]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 3000
    block = 'dike'
  []
[]
[ICs]
  [t_wallrock]
    type = ConstantIC
    block = 'wallrock'
    variable = T
    value = 323

  []

  [t_dike]
    type = ConstantIC
    block = 'dike'
    variable = T
    value = 1337

  []
[]

[Modules]
    [NavierStokesFV]
    block= 'dike'
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
    initial_velocity = '1 0 0'
    initial_pressure = 0.0
    initial_temperature = 0.0

    # Inlet boundary conditions
    inlet_boundaries = 'bottom'
    momentum_inlet_types = 'fixed-velocity'
    momentum_inlet_function = '1 0 0'
    energy_inlet_types = 'fixed-temperature'
    energy_inlet_function = '1'

    # Wall boundary conditions
    wall_boundaries = 'right left'
    momentum_wall_types = 'noslip noslip'
    energy_wall_types = 'heatflux heatflux'
    energy_wall_function = '0 0'

    # Outlet boundary conditions
    outlet_boundaries = 'top'
    momentum_outlet_types = 'fixed-pressure'
    pressure_function = '0'

    # Ambient convection volumetric heat source
    ambient_convection_alpha = 'alpha'
    ambient_temperature = '800'

    mass_advection_interpolation = 'average'
    momentum_advection_interpolation = 'average'
    energy_advection_interpolation = 'average'
    []
[]


[BCs]
  [t_right]
    type = DirichletBC
    variable = T
    value = 323 #K geothermal gradient
    boundary = 'right'
  []

[]

[Executioner]
  type = Transient
  end_time = 5
  dt = 1
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
