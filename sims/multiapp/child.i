
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin= 0
    xmax = 3
    ymin = 0
    ymax = 7
  []
[]



[Variables]
  [T_child]
    initial_condition = 550
  []

[]

[AuxVariables]
  [T_child_aux]
  []
  [qx_from_parent]
  []
[]

[AuxKernels]
  [T_child_test]
    type = ConstantAux
    variable = T_child_aux
    value = 500
  []
[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T_child
  []
  [time_derivative]
    type = HeatConductionTimeDerivative
    variable = T_child
  []
[]

[BCs]
  [right]
    type = DirichletBC
    variable = T_child
    boundary = 'left'
    value = 600.0
  []
  [from_parent]
    type = PostprocessorNeumannBC
    variable = T_child
    boundary = 'right top'
    postprocessor = q_x_side
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

[Executioner]
  type = Transient
  end_time = 5
  dt = 1
[]
[Postprocessors]
  [t_avg_interface]
    type = SideAverageValue
    variable = T_child
    boundary = 'right top'
  []
  [q_x_side]
    type = SideAverageValue
    variable = qx_from_parent
    boundary = 'right'
  []
  [t_avg]
    type = ElementAverageValue
    variable = T_child
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
