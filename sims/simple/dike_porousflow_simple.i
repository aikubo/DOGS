# simple fluid

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 20
    xmin = 0
    xmax = 500
    ymax = -500
    ymin = -1500
    bias_x = 1.20
  []
  [dike]
    type = ParsedGenerateSideset
    input = gen
    combinatorial_geometry = 'x = 0'
    new_sideset_name = dike
  []
  [dike2]
    type = ParsedGenerateSideset
    input = dike
    combinatorial_geometry = 'x > 50 & x< 60'
    new_sideset_name = dike2
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
    scaling = 1e4
  []
  [T]
    scaling = 1e-2
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
  [advectiveFlux]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffusiveFlux]
    family = MONOMIAL
    order = CONSTANT
  []
  [GradT]
    family = MONOMIAL
    order = CONSTANT
  []
  [nu]
    family = MONOMIAL
    order = CONSTANT
  []
  [eff_k]
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
  [enthalpy_water]
    type = PorousFlowPropertyAux
    variable = enthalpy
    property = enthalpy
    execute_on = 'initial timestep_end'
  []
  [advectiveFlux]
    type = AdvectiveFluxAux
    variable = advectiveFlux
    vel_x = water_darcy_vel_x
    vel_y = water_darcy_vel_y
    advected_variable = T
    component = x
    boundary = dike2
    check_boundary_restricted = false

  []
  [diffusiveFlux]
    type = DiffusionFluxAux
    variable = diffusiveFlux
    component = x
    diffusion_variable = T
    diffusivity = 'diff'
    boundary = dike2
    check_boundary_restricted = false
  []
  [GradT]
    type = VariableGradientComponent
    variable = GradT
    component = x
    gradient_variable = T
  []
  [eff_k]
    type = ParsedAux
    variable = eff_k
    coupled_variables = 'diffusiveFlux advectiveFlux GradT'
    expression='(diffusiveFlux+advectiveFlux)/(GradT+0.0001)'
  []
  [nu]
    type = ParsedAux
    variable = nu
    coupled_variables = 'diffusiveFlux advectiveFlux '
    expression ='advectiveFlux/(diffusiveFlux+0.0001)'
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
[]


[FluidProperties]

[water]
    type = SimpleFluidProperties
[]
[]

[Functions]
  [dike_cooling]
      type = ParsedFunction
      expression = '515*(1-exp(-t/20000))+(285+(-y)*10/1000)'
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
    porosity = 0.1
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1E-13 0 0   0 1E-13 0   0 0 1E-13'
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
[]

[BCs]
  [t_dike_dirichlet]
    type = FunctionDirichletBC
    variable = T
    function = dike_cooling
    boundary = 'dike'
  []
  [t_dike_neumann]
    type = NeumannBC
    variable = T
    boundary = 'dike'
    value = 0
  []
  [pp_like_dirichlet]
      type = PorousFlowPiecewiseLinearSink
      variable = porepressure
      boundary = 'top bottom right'
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
    boundary = 'bottom right'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = geotherm
    flux_function = 1e-5 #1e-2 too high causes slow convergence
  []
[]


[Controls]
  [period0]
      type = TimePeriod
      disable_objects = 'BoundaryCondition::t_dike_neumann'
      enable_objects = 'BoundaryCondition::t_dike_dirichlet'
      start_time = '0'
      end_time = '63072000'
      execute_on = 'initial timestep_begin'
    []

    [period2]
      type = TimePeriod
      disable_objects = 'BoundaryCondition::t_dike_dirichlet'
      enable_objects = 'BoundaryCondition::t_dike_neumann'
      start_time = '63072000'
      end_time = '1.5e9'
      execute_on = 'initial timestep_begin'
    []
[]

[Preconditioning]
  [mumps] # much better than superlu
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  end_time = 1.5e9
  dtmax = 1e8
  line_search = none
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
  show_material_props = true
[]

[Outputs]
  [./out]
    type = Exodus
    file_base = 'dike_porousflow_simple'
    min_simulation_time_interval = 10000
    sequence = true
  [../]
[]

[VectorPostprocessors]
  [./temperature1500m]
    type = LineValueSampler
    sort_by = x
    variable = T
    start_point = '0 -1200 0'
    end_point = '500 -1200 0'
    num_points = 25
  []
  [./temperature300m]
    type = LineValueSampler
    sort_by = x
    variable = T
    start_point = '0 -600 0'
    end_point = '500 -600 0'
    num_points = 25
  []
[]

