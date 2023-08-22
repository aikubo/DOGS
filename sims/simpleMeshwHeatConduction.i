#units 
# temperature: K 
# density: kg/m^3
# thermal conductivity: W/mK
# specific heat: J/kg K

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
[BCs]
  [t_right]
    type = DirichletBC
    variable = T
    value = 323 #K geothermal gradient
    boundary = 'right'
  []
  [t_left]
    type = DirichletBC
    variable = T
    value = 1337
    boundary = 'left'
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