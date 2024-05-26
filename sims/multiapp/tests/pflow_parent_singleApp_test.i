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
    nx = 10
    ny = 10
    xmin = 0
    xmax = 100
    ymax = 0
    ymin = -100
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = ' 0 -100 0'
    top_right = ' 10 -20 0'
  []
  [rename]
    type = RenameBlockGenerator
    input = dike
    old_block = '0 1'
    new_block = 'host dike'
  []
  [sidesets]
    type = SideSetsAroundSubdomainGenerator
    input = rename
    block = 'dike'
    new_boundary = 'dike_center'
    normal = '-1 0 0'
  []
  [sidesets2]
    type = SideSetsBetweenSubdomainsGenerator
    input = sidesets
    primary_block = 'host'
    paired_block = 'dike'
    new_boundary = 'dike_edge'
  []
  [sidesets4]
    type = ParsedGenerateSideset
    input = sidesets2
    combinatorial_geometry = 'x > 10 & y = -100'
    new_sideset_name = 'host_bottom'

  []
  [sidesets5]
    type = ParsedGenerateSideset
    input = sidesets4
    combinatorial_geometry = 'x = 0 & y > -20'
    new_sideset_name = 'host_left'

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
  [T_dike]
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
  [pflow_heatflux]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [hydrostat]
    type = FunctionAux
    function = ppfunc
    variable = hydrostat
    block = 'host'
  []
  [geotherm]
    type = FunctionAux
    variable = geotherm
    function = tfunc
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [porosity]
    type = PorousFlowPropertyAux
    variable = porosity
    property = porosity
    block = 'host'
  []
  [darcy_vel_x_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = x
    variable = darcy_vel_x
    fluid_phase = 0
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = darcy_vel_y
    fluid_phase = 0
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [enthalpy_water]
    type = PorousFlowPropertyAux
    variable = enthalpy
    property = enthalpy
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [perm]
    type = ParsedAux
    variable = perm
    coupled_variables = 'T_host'
    constant_names = 'k0 klow'
    constant_expressions = '10e-13 10e-19'
    expression = 'k0'
    block = 'host'
    execute_on = 'initial nonlinear timestep_end'
  []
  [boundary_normal]
    type = PorousFlowElementNormal
    variable = normal_dir_x
    boundary = 'dike_edge'
    component = x
    execute_on = 'initial'
    block = 'host'
  []
  [boundary_normal2]
    type = PorousFlowElementNormal
    variable = normal_dir_y
    boundary = 'dike_edge'
    component = y
    execute_on = 'initial'
    block = 'host'
  []
  [boundary_normal3]
    type = PorousFlowElementNormal
    variable = normal_dir_z
    boundary = 'dike_edge'
    component = z
    execute_on = 'initial'
    block = 'host'
  []
  [length_scale]
    type = PorousFlowElementLength
    variable = length_scale
    direction = '0 1 0'
    execute_on = 'initial'
    block = 'host'
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
  [pflow_heatflux]
    # type = PorousFlowHeatFluxAux
    # variable = pflow_heatflux
    # block = 'host'
    type = ConstantAux
    variable = pflow_heatflux
    value = 0
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
    block = 'host'
    variable = T_host
  []
  [PorousFlowUnsaturated_EnergyTimeDerivative]
    type = PorousFlowEnergyTimeDerivative
    block = 'host'
    variable = T_host
  []
  [PorousFlowFullySaturated_AdvectiveFlux0]
    type = PorousFlowFullySaturatedAdvectiveFlux
    block = 'host'
    variable = porepressure
  []
  [PorousFlowFullySaturated_MassTimeDerivative0]
    type = PorousFlowMassTimeDerivative
    block = 'host'
    variable = porepressure
  []
  [PorousFlowFullySaturatedUpwind_HeatAdvection]
    type = PorousFlowFullySaturatedUpwindHeatAdvection
    variable = T_host
    block = 'host'
  []

  [diff]
    type = HeatConduction
    variable = T_dike
    block = 'dike'
  []
  [td]
    type = HeatConductionTimeDerivative
    variable = T_dike
    block = 'dike'
  []

  [dummy]
    type = Diffusion
    variable = T_host
    block = 'dike'
  []
  [dummy2]
    type = Diffusion
    variable = T_dike
    block = 'host'
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
  [dike_mat]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity density specific_heat'
    prop_values = '4 3000 1100'

  []
[]

[BCs]
  [matched]
    type = MatchedValueBC
    variable = T_host
    boundary = 'dike_edge'
    v = 'T_dike'
  []
  # [flux]
  #   # type = PostprocessorNeumannBC
  #   # variable = T_dike
  #   # boundary = 'dike_edge'
  #   # postprocessor = pflow_bc
  #   type = NeumannBC
  #   variable = T_dike
  #   boundary = 'dike_edge'
  #   value = -10
  # []
  # [T_dike]
  #   type = DirichletBC
  #   variable = T_dike
  #   boundary = 'dike_center'
  #   value = 500
  # []
  [pp_dike]
    type = NeumannBC
    variable = porepressure
    boundary = 'dike_edge'
    value = 10
  []
  [pp_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = porepressure
    boundary = 'top host_bottom right'
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
    boundary = 'top host_bottom right'
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

# [MultiApps]
#   [dummyTBC]
#     # sub_cyling = true
#     type = TransientMultiApp
#     app_type = dikesApp # NavierStokesTestApp
#     input_files = 'dummyTBC_child.i'
#     execute_on = 'initial timestep_begin'
#     catch_up = true
#   []
# []

# [Transfers]
#   [pull_Tbc]
#     # Transfer from the sub-app to this app
#     # The name of the variable in the sub-app
#     type = MultiAppGeneralFieldShapeEvaluationTransfer
#     from_multi_app = dummyTBC
#     source_variable = 'T_dike'
#     variable = 'T_dike'
#     bbox_factor = 1.2
#     to_boundaries = 'dike_edge'
#     execute_on = 'initial timestep_begin'
#   []
#   [push_l_for_htc]
#     # Transfer from this app to the sub-app
#     # which variable from this app?
#     # which variable in the sub app?
#     type = MultiAppVariableValueSamplePostprocessorTransfer
#     to_multi_app = dummyTBC
#     source_variable = length_scale
#     postprocessor = length_scale_parent
#     execute_on = 'initial timestep_begin'
#     #to_boundaries = 'host_edge'
#   []
#   [push_k_for_htc]
#     type = MultiAppVariableValueSamplePostprocessorTransfer
#     to_multi_app = dummyTBC
#     source_variable = conductivity
#     postprocessor = conductivity_parent
#     execute_on = 'initial timestep_begin'
#     #to_boundaries = 'host_edge'
#   []
#   [push_T]
#     type = MultiAppPostprocessorTransfer
#     to_multi_app = dummyTBC
#     from_postprocessor = T_host_avg
#     to_postprocessor = Tout
#     execute_on = 'initial timestep_begin'
#   []
# []

[Postprocessors]
  [T_host_avg]
    type = ElementAverageValue
    variable = 'T_host'
  []
  [element_normal_length]
    type = ElementAverageValue
    variable = length_scale
  []
  [pflow_heatflux_avg]
    type = ElementAverageValue
    variable = pflow_heatflux
  []
  [pflow_heatflux_max]
    type = ElementExtremeValue
    variable = pflow_heatflux
  []
  [pflow_bc]
    type = SideAverageValue
    variable = pflow_heatflux
    boundary = bottom
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
  # [Adaptivity]
  # interval = 1
  # refine_fraction = 0.2
  # coarsen_fraction = 0.3
  # max_h_level = 4
  # []
  type = Transient
  solve_type = PJFNK
  end_time = 1e9
  line_search = none
  automatic_scaling = true
  dt = 5000
  dtmin = 100
  # fixed_point_max_its = 10
  # fixed_point_rel_tol = 1e-8

  # verbose = true
  # [TimeStepper]
  #   type = FixedPointIterationAdaptiveDT
  #   dt_initial = 1000
  #   target_iterations = 6
  #   target_window = 0
  #   increase_factor = 2.0
  #   decrease_factor = 0.5
  # []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  [out]
    type = Exodus
    file_base = ./visuals/pflowParent_test_single
    additional_execute_on = 'FAILED'
  []
  [csv]
    type = CSV
    file_base = ./visuals/pflowParent_test_single
  []
[]


