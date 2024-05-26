# testing

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin=0
    xmax = 10
    ymin = 0
    ymax = 10
  []
  [cutout]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '3 7 0'
  []
  [rename]
    type = RenameBlockGenerator
    input = cutout
    old_block = '0 1'
    new_block = 'host dike'
  []
  [between]
   type = SideSetsBetweenSubdomainsGenerator
   input = rename
   primary_block = 'host'
   paired_block = 'dike'
   new_boundary = interface
  []
  [delete]
    type = BlockDeletionGenerator
    input = between
    block = 'dike'
  []
[]

[Variables]
  [T_parent]
    initial_condition = 300
  []

[]

[Kernels]
  [heat_conduction]
    type = HeatConduction
    variable = T_parent
  []
  [time_derivative]
    type = HeatConductionTimeDerivative
    variable = T_parent
  []
[]

[BCs]
  [interface_bc]
    type = DirichletBC
    variable = T_parent
    boundary = interface
    value = 500.0
  []
  [right]
    type = DirichletBC
    variable = T_parent
    boundary = 'top right'
    value = 300.0
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

[VectorPostprocessors]
  [t_sampler]
    type = LineValueSampler
    variable = T_parent
    start_point = '5 0 0'
    end_point = '5 10 0'
    num_points = 5
    sort_by = x
  []
[]

[Postprocessors]
  [t_avg_interface]
    type = SideAverageValue
    variable = T_parent
    boundary = 'interface'
  []
  [t_avg]
    type = ElementAverageValue
    variable = T_parent
  []
[]

[Outputs]
  csv = true
  exodus = true
[]

