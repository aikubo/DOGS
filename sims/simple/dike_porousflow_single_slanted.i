# singlephase

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 41
    ny = 41
  []
  [./image]
    input = gen
    type = ImageSubdomainGenerator
    image = 'meshImage/dike_pic_30_1600_10.jpg'
    show_info = true
  []
  [rename]
    type = RenameBlockGenerator
    input = image
    old_block = '0 1'
    new_block = 'dike host'
  []
  [boundary]
    type = SideSetsBetweenSubdomainGenerator
    input = rename
    primary_block = 'host'
    paired_block = 'dike'
    new_boundary = "dikeBC"
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
    scaling = 1
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
[]


[FluidProperties]
  [true_water]
    type = Water97FluidProperties
  []
  [water_tab]
    type = TabulatedBicubicFluidProperties
    fluid_property_file = 'water_extended.csv'
    fp= true_water
    error_on_out_of_bounds = false
  []
  [water]
    type = SimpleFluidProperties
    density0 = 1000
    viscosity = 1e-3

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
    compute_internal_energy = false
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
      flux_function = 1e-2
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
    flux_function = 1e-2
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


[Executioner]
  type = Transient
  solve_type = PJFNK
  end_time = 1.5e9
  dtmax = 1e8
  nl_abs_tol = 5e-6
  line_search = none
  dtmin = 1
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 500
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
    file_base = 'dike_porousflow_simple_slanted'
    min_simulation_time_interval = 10000
    sequence = true
  [../]
[]

[VectorPostprocessors]
  [./temperature1500m]
    type = LineValueSampler
    sort_by = x
    variable = T
    start_point = '0 -1500 0'
    end_point = '4000 -1500 0'
    num_points = 25
  []
  [./temperature300m]
    type = LineValueSampler
    sort_by = x
    variable = T
    start_point = '0 -300 0'
    end_point = '4000 -300 0'
    num_points = 25
  []
[]
