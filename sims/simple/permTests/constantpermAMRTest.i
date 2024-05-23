# log linear perm relationship
permInput = 1e-13

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 200
    ny = 200
    xmin = 0
    xmax = 1500
    ymax = 1500
    ymin = 0
    #bias_x = 1.25
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = ' 0 0 0'
    top_right = ' 50 1200 0'
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
  [SideSetsBetweenSubdomainsGenerator]
    type = SideSetsBetweenSubdomainsGenerator
    input = sidesets6
    primary_block= 'host'
    paired_block = 'dike'
    new_boundary = 'host_edge'
  []
[]

[Adaptivity]
  max_h_level = 2
  marker = marker
  initial_marker = initial
  initial_steps = 2
  [Indicators]
    [indicator]
      type = GradientJumpIndicator
      variable = velMag
    []
  []
  [Markers]
    [marker]
      type = ErrorFractionMarker
      indicator = indicator
      refine = 0.8
    []
    [initial]
      type = BoxMarker
      bottom_left = '0 0 0'
      top_right = '100 1500 0'
      inside = REFINE
      outside = DO_NOTHING
    []
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

  []
  [T]
   # scaling = 1e-5
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
  [density]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
  [Tall]
    family = MONOMIAL
    order = CONSTANT
  []
  [pflow_heatflux]
    family = MONOMIAL
    order = CONSTANT
  []
  [GradT]
    family = MONOMIAL
    order = CONSTANT
  []
  [GradT_dike]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffT]
    family = MONOMIAL
    order = CONSTANT
  []
  [permExp]
    family = MONOMIAL
    order = CONSTANT
  []
  [velMag]
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
  [density]
    type = PorousFlowPropertyAux
    variable = density
    property = density

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
  [velMag]
    type = ParsedAux
    variable = velMag
    coupled_variables = 'water_darcy_vel_x water_darcy_vel_y'
    expression = 'sqrt(water_darcy_vel_x^2 + water_darcy_vel_y^2)'
    execute_on = 'initial timestep_end'
  []
  [enthalpy_water]
    type = PorousFlowPropertyAux
    variable = enthalpy
    property = enthalpy
    execute_on = 'initial timestep_end'

  []
  [perm]
    type = ConstantAux
    variable = perm
    value = 10e-13
  []
  [pflow_heatflux]
    type = PorousFlowHeatFluxAux
    variable = pflow_heatflux
  []
  [gradT]
    type = VariableGradientComponent
    variable = GradT
    component = x
    gradient_variable = T
  []
  [diffT]
    type = DiffusionFluxAux
    diffusivity = dike_thermal_conductivity
    variable = diffT
    component = normal
    diffusion_variable = T
    boundary = 'dike_edge host_edge'
    check_boundary_restricted = false
  []
[]

[ICs]
  [hydrostatic]
    type = FunctionIC
    variable = porepressure
    function = ppfunc
   # block = 'host'
  []
  # [dike_pp]
  #   type = FunctionIC
  #   variable = porepressure
  #   function = dike_pressure
  #   block = 'dike'
  # []
  [geothermal]
    type = FunctionIC
    variable = T
    function = tfunc
    block = 'host'
  []
  [porosity]
    type = ConstantIC
    variable = porosity
    value = 0.2
    # type = RandomIC
    # variable = porosity
    # min = 0.1
    # max = 0.2
    # #block = 'host'
  []
  [dike_temperature]
    type = ConstantIC
    variable = T
    value = 1438
    block = 'dike'
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
      expression = '785'
    []
  [ppfunc]
    type = ParsedFunction
    expression ='1.0135e5+(1500)*9.81*1000+(1500-y)*1000*9.81' #1.0135e5-(y)*9.81*1000' #hydrostatic gradientose   + atmospheric pressure in Pa
  []
  [tfunc]
    type = ParsedFunction
    expression = '300+(1500-y)*10/1000' #285+(-y)*10/1000 # geothermal 10 C per kilometer in kelvin
  []
  [dike_pressure]
    type = ParsedFunction
    expression = '1.0135e6 + (1500-y)*1000*9.81'  #hydrostatic gradientose   + atmospheric pressure in Pa
  []
  [kfunc]
    type = PiecewiseLinear
    x = '0 600 900 1600'
    y = '10e-13 10e-13 10e-18 10e-20'
  []
[]

[Kernels]
  [./PorousFlowUnsaturated_HeatConduction]
    type = PorousFlowHeatConduction
    #block = 'host'
    variable = T
  [../]
  [./PorousFlowUnsaturated_EnergyTimeDerivative]
    type = PorousFlowEnergyTimeDerivative
    #block = 'host'
    variable = T
  [../]
  [./PorousFlowFullySaturated_AdvectiveFlux0]
    type = PorousFlowFullySaturatedAdvectiveFlux
    #block = 'host'
    variable = porepressure
  [../]
  [./PorousFlowFullySaturated_MassTimeDerivative0]
    type = PorousFlowMassTimeDerivative
    #block = 'host'
    variable = porepressure
  [../]
  [./PorousFlowFullySaturatedUpwind_HeatAdvection]
    type = PorousFlowFullySaturatedUpwindHeatAdvection
    variable = T
    #block = 'host'
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
    dry_thermal_conductivity = '3 0 0  0 3 0  0 0 3' # too high per noah W/mK
  []
  [parsed_thermal_conductivity]
    type = ParsedMaterial
    property_name = dike_thermal_conductivity
    constant_names = 'kw k'
    constant_expressions = '3 0.1'
    coupled_variables = 'porosity'
    expression = 'kw*porosity + k*(1-porosity)'
  []

[]

[BCs]
  [pp_like_dirichlet]
      type = PorousFlowPiecewiseLinearSink
      variable = porepressure
      boundary = 'top'
      pt_vals = '1e-9 1e9'
      multipliers = '1e-9 1e9'
      PT_shift = hydrostat
      flux_function = 1e-6 #1e-2 too high causes slow convergence
      use_mobility = true
      use_relperm = true
      fluid_phase = 0
  []
  [T_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = T
    boundary = 'top'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = geotherm
    flux_function = 1e-6 #1e-2 too high causes slow convergence
  []
  [pp_right]
    type = NeumannBC
    variable = porepressure
    boundary = 'left right bottom'
    value = 0
  []
  [t_bc]
    type = NeumannBC
    variable = T
    boundary = 'left right bottom'
    value = 0
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
  [andy]
    type = SMP # less linear iterations but more non lincear ones
    full = true
    petsc_options = '-snes_converged_reason'
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_max_it -sub_pc_factor_shift_type '
    petsc_options_value = 'gmres asm lu 100 NONZERO '
  []
[]

[Executioner]
  type = Transient
  #newton plus mumps seems faster but more timestep cuts

  # 1e6 s is 0.03 years, 1e7 is 0.3 years
  # 1.5e9 is 47.5 years
  solve_type = NEWTON # MUCH better than PJFNK
  automatic_scaling = true
  end_time = 3e9
  #dtmax= 6.312e+7
  line_search = none
  nl_abs_tol = 1e-9
  dtmin = 1
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e6
  []
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  # [./out]
  #   type = Exodus
  #   file_base = './visuals/loglinearpermAMR'

  # [../]
  # [csv]
  #   type = CSV
  #   file_base = ./visuals/loglinearpermAMR
  # []
[]

[Postprocessors]
  [T_host_avg]
    type = ElementAverageValue
    variable = 'T'
    block = 'host'
  []
  [T_dike_avg]
    type = ElementAverageValue
    variable = 'T'
    block = 'dike'
  []
  [q_dike]
    type = SideDiffusiveFluxAverage
    variable = 'T'
    boundary = 'host_edge'
    diffusivity = 'dike_thermal_conductivity'
  []
[]

[VectorPostprocessors]
  [T_vec]
    type = LineValueSampler
    variable = T
    start_point = '0 750 0'
    end_point = '1500 750 0'
    num_points = 10
    sort_by = x
    execute_on = 'initial timestep_end'
  []
[]

[Controls/stochastic]
  type = SamplerReceiver
[]
