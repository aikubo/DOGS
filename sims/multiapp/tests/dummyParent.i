[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 5
    xmin = 0
    xmax = 100
    ymax = 0
    ymin = -10
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = ' 0 -1500 0'
    top_right = ' 50 -500 0'
  []
  [dike2]
    type = ParsedGenerateSideset
    input = dike
    combinatorial_geometry = 'x > 50 & x< 60'
    new_sideset_name = dike2
  []
  [rename]
    type = RenameBlockGenerator
    input = dike2
    old_block = '0 1'
    new_block = 'host dike'
  []
  [sidesets]
    type = SideSetsAroundSubdomainGenerator
    input = rename

    new_boundary = 'dike_center'
    normal = '-1 0 0'
  []
  [sidesets2]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets

    new_boundary = 'dike_edge_R'
    normal = '1 0 0'
  []
  [sidesets3]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets2

    new_boundary = 'dike_edge_top'
    normal = '0 1 0'
  []
  [sidesets4]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets3

    new_boundary = 'host_bottom'
    normal = '0 -1 0'
  []
  [sidesets5]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets4

    new_boundary = 'host_left'
    normal = '-1 0 0'
  []
  [sidesets6]
    type = RenameBoundaryGenerator
    input = sidesets5
    old_boundary = 'dike_edge_R dike_edge_top'
    new_boundary = 'dike_edge dike_edge'
  []
[]


[Variables]
  [T]
  []
[]


[Kernels]
  [diff]
    type = Diffusion
    variable = T
  []
  [td]
    type = TimeDerivative
    variable = T
  []
[]

[MultiApps]
  [./dummyTBC]
    type = TransientMultiApp
    app_type = dikesApp  #NavierStokesTestApp
    input_files = 'nsdike_child.i'
    positions = '0 -10 0'
  []
[]

[Transfers]
  [pull_Tbc]
    type = MultiAppGeneralFieldNearestLocationTransfer

    # Transfer from the sub-app to this app
    from_multi_app = nsdike_child

    # The name of the variable in the sub-app
    source_variable = T

    # The name of the auxiliary variable in this app
    variable = T_dike

    to_boundaries = 'dike_edge'

    from_boundaries = 'host_edge'
  []
  [push_h]
    type = MultiAppShapeEvaluationTransfer

    # Transfer from this app to the sub-app
    to_multi_app = nsdike_child

    # The name of the auxiliary variable in this app
    source_variable = h_calc

    # The name of the variable in the sub-app
    variable = h_parent
  []
[]

[BCs]
  [left]
    type = MatchedValueBC
    variable = T
    boundary = dike_edge
    v = T_bc_sub
  []
  [right]
    type = DirichletBC
    variable = T
    boundary = right
    value = 285
  []
[]

[AuxVariables]
  [h_calc]
  []
[]

[AuxKernels]
  [h_calc]
    type = ParsedAux
    variable = h_calc
    expression = 'x*100'
  []
[]


[Executioner]
  type = Transient
  end_time = 2
  dt = 0.2

  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Postprocessors]
  [h_avg]
    type = ElementAverageValue
    variable = h_calc
  []
[]



