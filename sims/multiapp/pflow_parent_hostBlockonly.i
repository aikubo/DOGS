# temperatre transfer seems to be working
# but the heat flux is not being transferred?
# block doesn't seem to cool
# there was an issue with the temperature transfer because
# it wasn't being transferred to the top boundary in the parent app
# i increased the bbox_factor to 1.2 and the child app to be slightly wider
# and slightly taller than the deleted block in the parent app



[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 20
    xmin = 0
    xmax = 1000
    ymax = 0
    ymin = -1000
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = ' 0 -1000 0'
    top_right = ' 50 -200 0'
  []
  [rename]
    type = RenameBlockGenerator
    input = dike
    old_block = '0 1'
    new_block = 'host dike'
  []
  [delete]
    type = BlockDeletionGenerator
    input = rename
    block = 'dike'
  []
  [sidesets]
    type = SideSetsFromPointsGenerator
    input = delete
    points = '0 -10 0
              25 -200 0
              50 -500 0'
    new_boundary = 'host_100 host_010 host_100_1'
  []
  [rename2]
    type = RenameBoundaryGenerator
    input = sidesets
    old_boundary = 'host_100 host_010 host_100_1'
    new_boundary = 'host_left dike_edge dike_edge '
  []
[]

[GlobalParams]
  PorousFlowDictator = 'dictator'
  gravity = '0 -9.81 0'
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure T_host'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[Variables]
  [porepressure]
    scaling = '1e2'

  []
  [T_host]
    scaling = '1e-5'

  []
[]

[AuxVariables]
  [hydrostat]
  []
  [geotherm]
  []
  [darcy_vel_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [darcy_vel_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [enthalpy]
    family = MONOMIAL
    order = CONSTANT
  []
  [porosity]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
  [T_dike]
  []
  [length_scale]
    family = MONOMIAL
    order = CONSTANT
  []
  [heat_transfer_coefficient]
    family = MONOMIAL
    order = CONSTANT
  []
  [conductivity]
      family = MONOMIAL
      order = CONSTANT
  []
  [normal_dir_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [normal_dir_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [normal_dir_z]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [hydrostat]
    type = FunctionAux
    function = ppfunc
    variable = hydrostat

  []
  [geotherm]
    type = FunctionAux
    variable = geotherm
    function = tfunc
    execute_on = 'initial timestep_end'

  []
  [porosity]
    type = PorousFlowPropertyAux
    variable = porosity
    property = porosity

  []
  [darcy_vel_x_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = x
    variable = darcy_vel_x
    fluid_phase = 0
    execute_on = 'initial timestep_end'

  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = darcy_vel_y
    fluid_phase = 0
    execute_on = 'initial timestep_end'

  []
  [enthalpy_water]
    type = PorousFlowPropertyAux
    variable = enthalpy
    property = enthalpy
    execute_on = 'initial timestep_end'

  []
  [perm]
    type = ParsedAux
    variable = perm
    coupled_variables = 'T_host'
    constant_names = 'k0 klow'
    constant_expressions = '10e-11 10e-19'
    expression = 'k0'
    execute_on = 'initial nonlinear timestep_end'
  []
  [boundary_normal]
    type = PorousFlowElementNormal
    variable = normal_dir_x
    boundary = 'dike_edge'
    component = x
    execute_on = 'initial'
  []
  [boundary_normal2]
    type = PorousFlowElementNormal
    variable = normal_dir_y
    boundary = 'dike_edge'
    component = y
    execute_on = 'initial'
  []
  [boundary_normal3]
    type = PorousFlowElementNormal
    variable = normal_dir_z
    boundary = 'dike_edge'
    component = z
    execute_on = 'initial'
  []
  [length_scale]
    type = PorousFlowElementLength
    variable = length_scale
    direction = '0 1 0'
    execute_on = 'initial'
  []
  [heat_transfer_coefficient]
    type = ParsedAux
    variable = heat_transfer_coefficient
    coupled_variables = 'length_scale'
    constant_names = 'conductivity'
    constant_expressions = '4'
    expression = '2*conductivity/length_scale'
  []
  [conductivity]
    type = ParsedAux
    variable = conductivity
    coupled_variables = 'porosity'
    constant_names = 'kappaw kappar'
    constant_expressions = '0.6 4'
    expression = 'porosity*kappaw + (1-porosity)*(kappar)'
    execute_on = 'initial'
  []
[]

[ICs]
  [hydrostatic]
    type = FunctionIC
    variable = porepressure
    function = ppfunc

  []
  [geothermal]
    type = FunctionIC
    variable = T_host
    function = tfunc

  []
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.1
    max = 0.3

  []
[]

[FluidProperties]
  [water]
    # thermal_expansion= 0.001
    type = SimpleFluidProperties
  []
[]

[Functions]
  [dike_cooling]
    type = ParsedFunction
    expression = '515*(1-exp(-t/5000))+(285+(-y)*10/1000)'
  []
  [ppfunc]
    type = ParsedFunction
    expression = '1.0135e5-(y)*9.81*1000' # hydrostatic gradientose   + atmospheric pressure in Pa
  []
  [tfunc]
    type = ParsedFunction
    expression = '285+(-y)*10/1000' # geothermal 10 C per kilometer in kelvin
  []
[]

[Kernels]
  [PorousFlowUnsaturated_HeatConduction]
    type = PorousFlowHeatConduction

    variable = T_host
  []
  [PorousFlowUnsaturated_EnergyTimeDerivative]
    type = PorousFlowEnergyTimeDerivative

    variable = T_host
  []
  [PorousFlowFullySaturated_AdvectiveFlux0]
    type = PorousFlowFullySaturatedAdvectiveFlux

    variable = porepressure
  []
  [PorousFlowFullySaturated_MassTimeDerivative0]
    type = PorousFlowMassTimeDerivative

    variable = porepressure
  []
  [PorousFlowFullySaturatedUpwind_HeatAdvection]
    type = PorousFlowFullySaturatedUpwindHeatAdvection
    variable = T_host

  []

[]

[Materials]
  [PorousFlowActionBase_Temperature_qp]
    type = PorousFlowTemperature

    temperature = 'T_host'
  []
  [PorousFlowActionBase_Temperature]
    type = PorousFlowTemperature

    at_nodes = true
    temperature = 'T_host'
  []
  [PorousFlowActionBase_MassFraction_qp]
    type = PorousFlowMassFraction

  []
  [PorousFlowActionBase_MassFraction]
    type = PorousFlowMassFraction

    at_nodes = true
  []
  [PorousFlowActionBase_FluidProperties_qp]
    type = PorousFlowSingleComponentFluid

    compute_enthalpy = true
    compute_internal_energy = true
    fp = water
    phase = 0
  []
  [PorousFlowActionBase_FluidProperties]
    type = PorousFlowSingleComponentFluid

    at_nodes = true
    fp = water
    phase = 0
  []
  [PorousFlowUnsaturated_EffectiveFluidPressure_qp]
    type = PorousFlowEffectiveFluidPressure

  []
  [PorousFlowUnsaturated_EffectiveFluidPressure]
    type = PorousFlowEffectiveFluidPressure

    at_nodes = true
  []
  [PorousFlowFullySaturated_1PhaseP_qp]
    type = PorousFlow1PhaseFullySaturated

    porepressure = 'porepressure'
  []
  [PorousFlowFullySaturated_1PhaseP]
    type = PorousFlow1PhaseFullySaturated

    at_nodes = true
    porepressure = 'porepressure'
  []
  [PorousFlowActionBase_RelativePermeability_qp]
    type = PorousFlowRelativePermeabilityConst

    phase = 0
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 'porosity'

  []
  [permeability]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = 'perm'
    perm_yy = 'perm'
    perm_zz = 'perm'

  []
  [Matrix_internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2400
    specific_heat_capacity = 790

  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4'

  []
[]

[BCs]
  [matched]
    type = MatchedValueBC
    variable = T_host
    boundary = 'dike_edge'
    v = 'T_dike'
  []
  # [T_dike]
  #   type = DirichletBC
  #   variable = T_host
  #   boundary = 'dike_edge'
  #   value = 500
  # []
  [pp_dike]
    type = NeumannBC
    variable = porepressure
    boundary = 'dike_edge'
    value = 0
  []
  [pp_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = porepressure
    boundary = 'top bottom right'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = 'hydrostat'
    flux_function = 1e-4 # 1e-2 too high causes slow convergence
    use_mobility = true
    use_relperm = true
    fluid_phase = 0
  []
  [T_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = T_host
    boundary = 'top bottom right'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = 'geotherm'
    flux_function = 1e-4 # 1e-2 too high causes slow convergence
    fluid_phase = 0
    use_mobility = true
    use_relperm = true
    use_enthalpy = true
  []
  [pp_left]
    type = FunctionDirichletBC
    variable = porepressure
    boundary = 'host_left'
    function = ppfunc
  []
  [T_left]
    type = FunctionDirichletBC
    variable = T_host
    boundary = 'host_left'
    function = tfunc
  []

[]

[MultiApps]
  [dummyTBC]
    # sub_cyling = true
    type = TransientMultiApp
    app_type = dikesApp # NavierStokesTestApp
    input_files = 'dummyTBC_child.i'
    execute_on = 'initial timestep_begin'
    catch_up = true
  []
[]

[Transfers]
  [pull_Tbc]
    # Transfer from the sub-app to this app
    # The name of the variable in the sub-app
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = dummyTBC
    source_variable = 'T_dike'
    variable = 'T_dike'
    bbox_factor = 1.2
    to_boundaries = 'dike_edge'
    execute_on = 'initial timestep_begin'
  []
  [push_l_for_htc]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app = dummyTBC
    source_variable = length_scale
    postprocessor = length_scale_parent
    execute_on = 'initial timestep_begin'
    #to_boundaries = 'host_edge'
  []
  [push_k_for_htc]
    type = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app = dummyTBC
    source_variable = conductivity
    postprocessor = conductivity_parent
    execute_on = 'initial timestep_begin'
    #to_boundaries = 'host_edge'
  []
  [push_T]
    type = MultiAppPostprocessorTransfer
    to_multi_app = dummyTBC
    from_postprocessor = T_host_avg
    to_postprocessor = Tout
    execute_on = 'initial timestep_begin'
  []
[]

[Postprocessors]
  [T_host_avg]
    type = ElementAverageValue
    variable = 'T_host'
  []
[]

[Preconditioning]
  [mumps]
    # much better than superlu
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  [Adaptivity]
  interval = 1
  refine_fraction = 0.2
  coarsen_fraction = 0.3
  max_h_level = 4
  []
  type = Transient
  solve_type = PJFNK
  end_time = 1e9
  line_search = none
  automatic_scaling = true
  dt = 5000
  dtmin = 100
  fixed_point_max_its = 10
  fixed_point_rel_tol = 1e-8
  verbose = true
  [TimeStepper]
    type = FixedPointIterationAdaptiveDT
    dt_initial = 1000
    target_iterations = 6
    target_window = 0
    increase_factor = 2.0
    decrease_factor = 0.5
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  [out]
    type = Exodus
    file_base = ./visuals/pflowParent_test
    additional_execute_on = 'FAILED'

  []
[]


