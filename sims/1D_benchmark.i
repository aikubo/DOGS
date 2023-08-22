[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 1
    nx = 500
  []
[]


[Variables]
  [T]

  []
[]

[Kernels]
  [heatC]
    type = HeatConduction
    variable = T
    thermal_conductivity = 'k'
  []
  [f_time]
    type=HeatConductionTimeDerivative
    variable=T
  []
[]

[Materials]
  [thermal]
    type = HeatConductionMaterial
    thermal_conductivity = 45.0
    specific_heat = 0.5
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 8000.0
  []
[]

[BCs]
  [t_right]
    type = DirichletBC
    variable = T
    value = 300

  []
  [t_left]
    type = FunctionDirichletBC
    variable = T
    boundary= 'left'
    function = bc_func
  []
[]

[Functions]
  [thermalBoundary]
    type = ParsedFunction
    expression = (Tl - Tb)/2*(1-tanh(10*((t-tc)/tw)))+Tb
    symbol_names = 'Tl Tb tc tw'
    symbol_values = '1 1 1 1'
  []
  [constantBoundary]
    type=ConstantFunction
    value = 300 #Tbackground
  [bc_func]
    type =PiecewiseFunction
    axis = t
    axis_coordinates = '1' #tf
    functions = 'thermalBoundary constantBoundary'
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
