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

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure T'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[Variables]
  [porepressure]
    scaling = 1e2

  []
  [T]
    scaling = 1e-5

  []
[]

[AuxVariables]
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
  #coming from sub app
  [T_bc]
  []

  [h_calc]
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
    variable = water_darcy_vel_x
    fluid_phase = 0
    execute_on = 'initial timestep_end'

  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = water_darcy_vel_y
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
    coupled_variables = 'T'
    constant_names= 'k0 klow'
    constant_expressions = '10e-13 10e-19'
    expression = 'if(T>573,klow,k0)'

    execute_on = 'initial nonlinear timestep_end'
  []
  [h_calc]
    type = ParsedAux
    variable = h_calc
    coupled_variables = 'T'
    expression = 'T-100'
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
    variable = T
    function = tfunc

  []
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.1
    max = 0.3

  []
  [dike_temperature]
    type = ConstantIC
    variable = Tdike
    value = 583

  []
[]


[FluidProperties]

[water]
    type = SimpleFluidProperties
    #thermal_expansion= 0.001
[]
[]

[Functions]
  [dike_cooling]
      type = ParsedFunction
      expression = '515*(1-exp(-t/5000))+(285+(-y)*10/1000)'
    []
  [ppfunc]
    type = ParsedFunction
    expression = 1.0135e5-(y)*9.81*1000 #hydrostatic gradientose   + atmospheric pressure in Pa
  []
  [tfunc]
    type = ParsedFunction
    expression = 285+(-y)*10/1000 # geothermal 10 C per kilometer in kelvin
  []
[]

[Kernels]
  [./PorousFlowUnsaturated_HeatConduction]
    type = PorousFlowHeatConduction

    variable = T
  [../]
  [./PorousFlowUnsaturated_EnergyTimeDerivative]
    type = PorousFlowEnergyTimeDerivative

    variable = T
  [../]
  [./PorousFlowFullySaturated_AdvectiveFlux0]
    type = PorousFlowFullySaturatedAdvectiveFlux

    variable = porepressure
  [../]
  [./PorousFlowFullySaturated_MassTimeDerivative0]
    type = PorousFlowMassTimeDerivative

    variable = porepressure
  [../]
  [./PorousFlowFullySaturatedUpwind_HeatAdvection]
    type = PorousFlowFullySaturatedUpwindHeatAdvection
    variable = T

  [../]
[]

[Materials]
  [./PorousFlowActionBase_Temperature_qp]
    type = PorousFlowTemperature

    temperature = T
  [../]
  [./PorousFlowActionBase_Temperature]
    type = PorousFlowTemperature

    at_nodes = true
    temperature = T
  [../]
  [./PorousFlowActionBase_MassFraction_qp]
    type = PorousFlowMassFraction

  [../]
  [./PorousFlowActionBase_MassFraction]
    type = PorousFlowMassFraction

    at_nodes = true
  [../]
  [./PorousFlowActionBase_FluidProperties_qp]
    type = PorousFlowSingleComponentFluid

    compute_enthalpy = true
    compute_internal_energy = true
    fp = water
    phase = 0
  [../]
  [./PorousFlowActionBase_FluidProperties]
    type = PorousFlowSingleComponentFluid

    at_nodes = true
    fp = water
    phase = 0
  [../]
  [./PorousFlowUnsaturated_EffectiveFluidPressure_qp]
    type = PorousFlowEffectiveFluidPressure

  [../]
  [./PorousFlowUnsaturated_EffectiveFluidPressure]
    type = PorousFlowEffectiveFluidPressure

    at_nodes = true
  [../]
  [./PorousFlowFullySaturated_1PhaseP_qp]
    type = PorousFlow1PhaseFullySaturated

    porepressure = porepressure
  [../]
  [./PorousFlowFullySaturated_1PhaseP]
    type = PorousFlow1PhaseFullySaturated

    at_nodes = true
    porepressure = porepressure
  [../]
  [./PorousFlowActionBase_RelativePermeability_qp]
    type = PorousFlowRelativePermeabilityConst

    phase = 0
  [../]
  [porosity]
    type = PorousFlowPorosityConst
    porosity = porosity

  []
  [permeability]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = perm
    perm_yy = perm
    perm_zz = perm

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
  [parsedMatt]
    type = ParsedMaterial
    property_name = diff
    constant_names = 'kr kw'
    constant_expressions= '4 0.6'
    coupled_variables = 'porosity density'
    expression = '(porosity*kw+(1-porosity)*kr)*density'
  []
  [materials_host]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity_dike specific_heat_dike density_dike'
    prop_values = '3.3 1200.0 3000'

  []
[]

[BCs]
  [t_dike_dirichlet]
    type = FunctionDirichletBC
    variable = Tdike
    function = 500
    boundary = 'dike_center'
  []
  # [matched]
  #   type = MatchedValueBC
  #   variable = T
  #   boundary = 'dike_edge'
  #   v = Tdike
  # []
  [pp_like_dirichlet]
      type = PorousFlowPiecewiseLinearSink
      variable = porepressure
      boundary = 'top host_bottom right host_left'
      pt_vals = '1e-9 1e9'
      multipliers = '1e-9 1e9'
      PT_shift = hydrostat
      flux_function = 1e-5 #1e-2 too high causes slow convergence
      use_mobility = true
      use_relperm = true
      fluid_phase = 0
  []
  [T_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = T
    boundary = 'host_bottom right host_left'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = geotherm
    flux_function = 1e-5 #1e-2 too high causes slow convergence
  []
[]

[MultiApps]
  [./dummyTBC]
    type = TransientMultiApp
    app_type = dikesApp  #NavierStokesTestApp
    input_files = 'dummyTBC_child.i'
    positions = '0 -10 0'
  []
[]

[Transfers]
  [pull_Tbc]
    type = MultiAppShapeEvaluationTransfer

    # Transfer from the sub-app to this app
    from_multi_app = dummyTBC_child

    # The name of the variable in the sub-app
    source_variable = T

    # The name of the auxiliary variable in this app
    variable = T_bc_sub

    target_boundary = 'dike_edge'
  []
  [push_h]
    type = MultiAppShapeEvaluationTransfer

    # Transfer from this app to the sub-app
    to_multi_app = dummyTBC_child

    # The name of the auxiliary variable in this app
    source_variable = h_calc

    # The name of the variable in the sub-app
    variable = h
  []

[]

[Preconditioning]
  active = mumps
  [mumps] # much better than superlu
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
  [svd]
    type = SMP
    petsc_options = '-pc_svd_monitor'
    petsc_options_iname = '-pc_type'
    petsc_options_value = 'svd'
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  end_time = 1.5e9
  dtmax = 1e8
  line_search = none
  automatic_scaling = true
  nl_abs_tol = 1e-6
  dtmin = 1
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 2000
  []
  [Adaptivity]
    interval = 1
    refine_fraction = 0.2
    coarsen_fraction = 0.3
    max_h_level = 4
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  [./out]
    type = Exodus
    file_base = './visuals/two_block_simple'
    min_simulation_time_interval = 10000
    sequence = true
  [../]
[]

[Postprocessors]
  [./T_avg]
    type = ElementAverageValue
    variable = T_bc_sub
  [../]
[]
