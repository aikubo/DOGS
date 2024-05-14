[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin = 0
    xmax = 50
    ymax = 0
    ymin = -100
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = ' 0 -100 0'
    top_right = ' 5 -20 0'
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
    type = SideSetsAroundSubdomainGenerator
    input = sidesets
    block = 'dike'
    new_boundary = 'dike_edge_R'
    normal = '1 0 0'
  []
  [sidesets3]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets2
    block = 'dike'
    new_boundary = 'dike_edge_top'
    normal = '0 1 0'
  []
  [sidesets4]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets3
    block = 'host'
    new_boundary = 'host_bottom'
    normal = '0 -1 0'
  []
  [sidesets5]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets4
    block = 'host'
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
    block = 'host'
  []
  [T_host]
    scaling = '1e-5'
    block = 'host'
  []
  [dummyVar]
    initial_condition = '1'
    block = 'dike'
  []
[]

[AuxVariables]
  # [TotalTemperature]
  # []
  [hydrostat]
  []
  [geotherm]
  []
  [water_darcy_vel_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [water_darcy_vel_y]
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
  [porousHeatFlux]
    family = MONOMIAL
    order = CONSTANT
  []
  [T_dike]
    block = 'dike'
  []
[]

[AuxKernels]
  # [TotalTemperature]
  # type = ParsedAux
  # variable = TotalTemperature
  # coupled_variables = 'T_host T_dike'
  # use_xyzt = true
  # expression = 'if(x>5,T_host,T_dike)'
  # []
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
    variable = water_darcy_vel_x
    fluid_phase = 0
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = water_darcy_vel_y
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
    expression = 'if(T_host>573,klow,k0)'
    block = 'host'
    execute_on = 'initial nonlinear timestep_end'
  []
  [porousHeatFlux]
    type = PorousFlowHeatFluxAux
    variable = porousHeatFlux
    block = 'host'
  []
[]

[ICs]
  [hydrostatic]
    type = FunctionIC
    variable = porepressure
    function = ppfunc
    block = 'host'
  []
  [geothermal]
    type = FunctionIC
    variable = T_host
    function = tfunc
    block = 'host'
  []
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.1
    max = 0.3
    block = 'host'
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
  [dummykernal]
    type = Diffusion
    variable = dummyVar
    block = 'dike'
  []
[]

[Materials]
  [PorousFlowActionBase_Temperature_qp]
    type = PorousFlowTemperature
    block = 'host'
    temperature = 'T_host'
  []
  [PorousFlowActionBase_Temperature]
    type = PorousFlowTemperature
    block = 'host'
    at_nodes = true
    temperature = 'T_host'
  []
  [PorousFlowActionBase_MassFraction_qp]
    type = PorousFlowMassFraction
    block = 'host'
  []
  [PorousFlowActionBase_MassFraction]
    type = PorousFlowMassFraction
    block = 'host'
    at_nodes = true
  []
  [PorousFlowActionBase_FluidProperties_qp]
    type = PorousFlowSingleComponentFluid
    block = 'host'
    compute_enthalpy = true
    compute_internal_energy = true
    fp = water
    phase = 0
  []
  [PorousFlowActionBase_FluidProperties]
    type = PorousFlowSingleComponentFluid
    block = 'host'
    at_nodes = true
    fp = water
    phase = 0
  []
  [PorousFlowUnsaturated_EffectiveFluidPressure_qp]
    type = PorousFlowEffectiveFluidPressure
    block = 'host'
  []
  [PorousFlowUnsaturated_EffectiveFluidPressure]
    type = PorousFlowEffectiveFluidPressure
    block = 'host'
    at_nodes = true
  []
  [PorousFlowFullySaturated_1PhaseP_qp]
    type = PorousFlow1PhaseFullySaturated
    block = 'host'
    porepressure = 'porepressure'
  []
  [PorousFlowFullySaturated_1PhaseP]
    type = PorousFlow1PhaseFullySaturated
    block = 'host'
    at_nodes = true
    porepressure = 'porepressure'
  []
  [PorousFlowActionBase_RelativePermeability_qp]
    type = PorousFlowRelativePermeabilityConst
    block = 'host'
    phase = 0
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 'porosity'
    block = 'host'
  []
  [permeability]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = 'perm'
    perm_yy = 'perm'
    perm_zz = 'perm'
    block = 'host'
  []
  [Matrix_internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2400
    specific_heat_capacity = 790
    block = 'host'
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4'
    block = 'host'
  []
  [dummyMat]
    type = GenericConstantMaterial
    prop_names = 'k'
    prop_values = '1'
    block = 'dike'
  []
[]

[BCs]
  [matched]
    type = MatchedValueBC
    variable = T_host
    boundary = 'dike_edge'
    v = 'T_dike'
  []
  [pp_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = porepressure
    boundary = 'top host_bottom right host_left'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = 'hydrostat'
    flux_function = 1e-5 # 1e-2 too high causes slow convergence
    use_mobility = true
    use_relperm = true
    fluid_phase = 0
  []
  [T_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = T_host
    boundary = 'host_bottom right host_left'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = 'geotherm'
    flux_function = 1e-5 # 1e-2 too high causes slow convergence
  []
[]

[MultiApps]
  [dummyTBC]
    # sub_cyling = true
    type = TransientMultiApp
    app_type = dikesApp # NavierStokesTestApp
    input_files = 'dummyTBC_child.i'
    positions = '0 -10 0'
    execute_on = 'initial'
  []
[]

[Transfers]
  [pull_Tbc]
    # Transfer from the sub-app to this app
    # The name of the variable in the sub-app
    type = MultiAppShapeEvaluationTransfer
    from_multi_app = dummyTBC
    source_variable = 'T_dike'
    variable = 'T_dike'
  []
  [push_deltaT]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppVariableValueSamplePostprocessorTransfer
    to_multi_app = dummyTBC
    source_variable = porousHeatFlux
    postprocessor = heatFlux_from_parent
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
  []
[]

[Postprocessors]
  [T_bc_sub]
    type = Receiver
    execute_on = 'timestep_begin'
  []
[]
