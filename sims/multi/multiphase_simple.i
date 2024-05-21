[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 20
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
  [SideSetsBetweenSubdomainsGenerator]
    type = SideSetsBetweenSubdomainsGenerator
    input = rename
    primary_block= 'host'
    paired_block = 'dike'
    new_boundary = 'host_edge'
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure h'
    number_fluid_phases = 2
    number_fluid_components = 1
  []
  [advective_flux_water]
    type = PorousFlowAdvectiveFluxCalculatorSaturated
    phase = 0
  []
  [advective_flux_steam]
    type = PorousFlowAdvectiveFluxCalculatorSaturated
    phase = 1
  []
  [heat_advective_flux]
    type = PorousFlowAdvectiveFluxCalculatorSaturatedHeat
  []
  [pc] #from porousflow/test/tests/fluidstate/watervapor.i
  type = PorousFlowCapillaryPressureBC
  pe = 1e5
  lambda = 2
  pc_max = 1e6
  []
  [fs]
    type = PorousFlowWaterVapor
    water_fp = water
    capillary_pressure = pc
  []
[]

[Variables]
  [porepressure]

  []
  [h]
  []
[]

[AuxVariables]
  [temperature]
    family = MONOMIAL
    order = CONSTANT
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
  [pgas]
    family = MONOMIAL
    order = CONSTANT
  []
  [gas_sat]
      family = MONOMIAL
      order = CONSTANT
  []
  [geotherm]
  []
[]

[AuxKernels]
  [geotherm]
    type = FunctionAux
    variable = geotherm
    function = tfunc
    execute_on = 'initial timestep_end'
  []
  [temperature]
    type = PorousFlowPropertyAux
    variable = temperature
    property = temperature
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
  [perm]
    type = ParsedAux
    variable = perm
    coupled_variables = 'temperature'
    constant_names= 'k0 klow'
    constant_expressions = '10e-13 10e-25'
    expression = 'if(temperature>800,klow,k0)'
    execute_on = 'initial nonlinear timestep_end'
  []
  [pressure_gas]
    type = PorousFlowPropertyAux
    variable = pgas
    property = pressure
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [gas_sat]
      type = PorousFlowPropertyAux
      variable = gas_sat
      property = saturation
      phase = 1
      execute_on = 'initial timestep_end'
  []
[]

[ICs]
  [hydrostatic]
    type = FunctionIC
    variable = porepressure
    function = ppfunc
    block = 'host'
  []
  [enthalpy]
    type = PorousFlowFluidPropertyIC
    variable = h
    property = enthalpy
    porepressure = porepressure
    temperature = geotherm
    fp = water
    block = 'host'
  []
  [pp_dike]
    type = ConstantIC
    variable = porepressure
    value = 20100000
    block = 'dike'
  []
  [enthalpy_dike]
    type = PorousFlowFluidPropertyIC
    variable = h
    property = enthalpy
    porepressure = porepressure
    temperature = 1000
    fp = water
    block = 'dike'
  []
  [porosity]
    type = ConstantIC
    variable = porosity
    value = 0.2
  []
[]


[FluidProperties]
  [water97]
    type = Water97FluidProperties    # IAPWS-IF97
  []
  [water]
    type = TabulatedBicubicFluidProperties
    fp = water97
    fluid_properties_file = 'water_extended.csv'
    error_on_out_of_bounds = false
    p_h_variables = true
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
[]

[Kernels]
  [./PorousFlowUnsaturated_HeatConduction]
    type = PorousFlowHeatConduction
    #block = 'host'
    variable = h
  [../]
  [mass_dot]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
  [fluid_advection_water]
    type = PorousFlowFluxLimitedTVDAdvection
    variable = porepressure
    advective_flux_calculator = advective_flux_water
  []
  [fluid_advection_gas]
    type = PorousFlowFluxLimitedTVDAdvection
    variable = porepressure
    advective_flux_calculator = advective_flux_steam
  []
  [energy_dot]
    type = PorousFlowEnergyTimeDerivative
    variable = h
  []
  [heat_advection]
    type = PorousFlowFluxLimitedTVDAdvection
    variable = h
    advective_flux_calculator = heat_advective_flux
  []
[]

[Materials]
  [watervapor]
    type = PorousFlowFluidStateSingleComponent
    porepressure = porepressure
    enthalpy = h
    capillary_pressure = pc
    fluid_state = fs
    temperature_unit = Kelvin
  []

  [relperm_water] # from watervapor.i
  type = PorousFlowRelativePermeabilityCorey
  n = 2
  phase = 0
  []
  [relperm_gas]  # from watervapor.i
    type = PorousFlowRelativePermeabilityCorey
    n = 3
    phase = 1
  []
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

[]

[BCs]
  [pp_like_dirichlet]
      type = PorousFlowPiecewiseLinearSink
      variable = porepressure
      boundary = 'top'
      pt_vals = '1e-9 1e9'
      multipliers = '1e-9 1e9'
      PT_shift = 14816350 #pressre shift at 1500m
      flux_function = 1e-6 #1e-2 too high causes slow convergence
      use_mobility = true
      use_relperm = true
      fluid_phase = 0
  []
  [pp_like_dirichlet_gas]
    type = PorousFlowPiecewiseLinearSink
    variable = porepressure
    boundary = 'top'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = 14816350
    flux_function = 1e-6 #1e-2 too high causes slow convergence
    use_mobility = true
    use_relperm = true
    fluid_phase = 1
[]
  [T_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = h
    boundary = 'top'
    pt_vals = '1e-9 1e12'
    multipliers = '1e-9 1e12'
    PT_shift = 1.3e6
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
    variable = h
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
  [./out]
    type = Exodus
    file_base = './visuals/multiKT'
    min_simulation_time_interval = 3e7

  [../]
  [csv]
    type = CSV
    file_base = ./visuals/multiKT
  []
[]
[Postprocessors]
  [T_host_avg]
    type = ElementAverageValue
    variable = 'temperature'
    block = 'host'
  []
  [flowx_bc]
    type = SideAverageValue
    variable = water_darcy_vel_x
    boundary = 'host_edge'
  []
  [flowy_bc]
    type = SideAverageValue
    variable = water_darcy_vel_y
    boundary = 'host_edge'
  []
  [Tdike_avg]
    type = ElementAverageValue
    variable = 'h'
    block = 'dike'
  []
  [Residual]
    type = Residual

  []
[]

