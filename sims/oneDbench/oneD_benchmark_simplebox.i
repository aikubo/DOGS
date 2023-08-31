
[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 1
    xmax = 100 # m
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
    value = 373 #C
  []
[]

[Materials]
  [thermal]
    type = HeatConductionMaterial
    thermal_conductivity = 2.5 #W/mK
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
    expression = 'if(t<tw, Tl, Tb)'
    symbol_names = 'tw Tl Tb'
    symbol_values = '1825 1413 373' #K K yr yr
  []

[]

[Executioner]
  type = Transient
  end_time = 5475

  line_search = 'none'
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 10
    #iteration_window = 3
    optimal_iterations = 5 #should be 5 probably

   [../]
  num_steps = 4000
  dtmax=10
  solve_type = 'PJFNK'       #"PJFNK, JFNK, NEWTON"
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
  scheme = 'crank-nicolson'   #"implicit-euler, explicit-euler, crank-nicolson, bdf2, rk-2"
[]

[VectorPostprocessors]
  [t_sampler]
    type = LineValueSampler
    variable = T
    start_point = '0 00 0'
    end_point = '25 0 0'
    num_points = 10
    sort_by = x
#
  []
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
