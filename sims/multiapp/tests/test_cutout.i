# testing cutout
# testing

# test 1:
# 1. Create a 10x10 mesh
# 2. Cut out a 3x7 block from the mesh
# 3. Rename the block to 'host dike'
# 4. Create a new boundary between the host and dike blocks
# 5. Delete the dike block
# 6. create cutout in mulitapp
# 7. transfer a constant aux variable from child to parent
# results: T_child is 0 across the entire domain, T_child_aux in sub set to 500
# test 2:
# add bbox_factor to parent of 1.2
# results: T_child has a value of 500 around the cutout and 0 elsewhere

# transfers back and forth worked for FE kernals
# but the q tranfer from FE to FV doesn't seem to be working

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin= 0
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

[AuxVariables]
  [T_cutout]
  []
  [diffTx]
  []
  [GradTx]
  []
[]

[AuxKernels]
  [diffTx]
    type = ParsedAux
    variable = diffTx
    coupled_variables = 'GradTx'
    expression = '-5*GradTx'
    execute_on = 'initial timestep_end'
  []
  [GradTx]
    type = ConstantAux
    variable = GradTx
    value = 1000
    # type = VariableGradientComponent
    # variable = GradTx
    # gradient_variable = T_parent
    # component = x
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
  # [interface_bc]
  #   type = DirichletBC
  #   variable = T_parent
  #   boundary = interface
  #   value = 500.0
  # []
  [Matched]
    type = MatchedValueBC
    variable = T_parent
    boundary = interface
    v = T_cutout
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
  [q_diffusive]
    type = SideAverageValue
    variable = 'diffTx'
    boundary = 'interface'
  []
[]

[Outputs]
  csv = true
  exodus = true
[]

[MultiApps]
  [./child_app]
    type = TransientMultiApp
    app_type = dikesApp
    input_files = 'child.i'
    execute_on = 'timestep_begin'
  [../]
[]

[Transfers]
  [./transfer_to_child]
    type =  MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = child_app
    source_variable = T_child
    variable = T_cutout
    bbox_factor = 1.2
  [../]
  [push_qx]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = child_app
    source_variable = diffTx
    bbox_factor = 1.2
    variable = qx_from_parent

  []
[]