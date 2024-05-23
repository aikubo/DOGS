[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 7
    ny = 20
    xmin = 0
    xmax = 50
    ymax = -200
    ymin = -1000
  []
  [rename]
    type = RenameBoundaryGenerator
    input = gen
    old_boundary = "top right"
    new_boundary = "host_edge host_edge"
  []
[]


[Variables]
  [T_dike]
    initial_condition = 500
  []
[]

[Kernels]
  [diff]
    type = HeatConduction
    variable = T_dike
  []
  [td]
    type = HeatConductionTimeDerivative
    variable = T_dike
  []
[]



[BCs]
  [bottom]
    type = FunctionDirichletBC
    variable = T_dike
    boundary = 'bottom'
    function = 'if(t<50000, 250*(1-t/50000)+285, 285)'
  []
  [right]
    type = ConvectiveHeatFluxBC
    variable = T_dike
    boundary = host_edge
    heat_transfer_coefficient = 'htc'
    T_infinity = 285
  []
  [left]
    type = NeumannBC
    variable = T_dike
    boundary = 'left'
    value = 0
  []

[]

[Materials]
  [thermal]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity density specific_heat'
    prop_values = '4 3000 1100'
  []
  [htc_mat]
    type = GenericFunctionMaterial
    prop_names = htc
    prop_values = htc_func

  []
[]

[Executioner]
  type = Transient
  end_time = 1e9
  solve_type = 'PJFNK'
  dt = 1000
[]

[Postprocessors]
  [T_sub_avg]
    type = ElementAverageValue
    variable = T_dike
  []
  [conductivity_parent]
    type = Receiver
    default = 4
  []
  [length_scale_parent]
    type = Receiver
    default = 10
  []
  [Tout]
    type = Receiver
    default = 285
  []
  [htc_out]
    type = FunctionValuePostprocessor
    function = htc_func
  []
  [heatout]
    type = SideDiffusiveFluxAverage
    variable = T_dike
    boundary = host_edge
    diffusivity = 4
  []
[]

[Outputs]
  [./out]
    type = Exodus
    file_base = './visuals/pflowChild_test'
  [../]
[]



