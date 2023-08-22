# units
#
# 3153600 seconds in a year
#

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 1
    xmax = 10 # m
    ymax = 1
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
  []
  [f_time]
    type = HeatConductionTimeDerivative
    variable = T
  []
[]

[ICs]
  [t_wallrock]
    type = ConstantIC
    variable = T
    value = 100 #C
  []
[]

[Materials]
  [thermal]
    type = HeatConductionMaterial
    thermal_conductivity = 2.5 #W/mC
    specific_heat = 1100 #units: J/(kg*K)
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 2600 # units: kg/m^3
  []
[]

[BCs]
  [t_right]
    type = DirichletBC
    variable = T
    value = 373 # C
    boundary = 'right'
  []
  [t_left]
    type = FunctionDirichletBC
    variable = T
    boundary = 'left'
    function = bc_func1
  []
[]

[Functions]
  [bc_func1]
    type=ParsedFunction
    expression = 'if(t<tw, 0.5*(Tl-Tb)*(1-tanh(10*(t-tc)/tw))+Tb, Tb)'
    symbol_names = 'Tl Tb tc tw'
    symbol_values = '1413 373 5 1' #K K yr yr
  []

  [bc_func]
    type = ParsedFunction
    expression = '373' #C
  []
[]

[Executioner]
  type = Transient
  end_time = 15
  dt = .0001
  line_search = 'none'
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
    #iteration_window = 3
    optimal_iterations = 5 #should be 5 probably
    growth_factor = 1.4
    linear_iteration_ratio = 1000
    cutback_factor =  0.8
   [../]
  num_steps = 4000
  dtmax=10
  solve_type = 'PJFNK'       #"PJFNK, JFNK, NEWTON"
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  scheme = 'crank-nicolson'   #"implicit-euler, explicit-euler, crank-nicolson, bdf2, rk-2"
[]


[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
