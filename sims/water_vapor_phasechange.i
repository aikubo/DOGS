# Tests correct calculation of properties in PorousFlowWaterVapor as a phase change
# from liquid to a two-phase model occurs due to a pressure drop.
# A single 10 m^3 element is used, with constant mass and heat production using
# a Dirac kernel. Initial conditions correspond to just outside the two-phase region in
# the liquid state.
#
# An identical problem can be run using TOUGH2, with the following outputs after 1,000s
# Pressure: 8.58 Mpa
# Temperature: 299.92 K
# Vapor saturation: 0.00637

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 10
  ymax = 10
  nx=10
  ny=10

[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = ' 0 9.81 0'
[]

[Variables]
  [pliq]
    initial_condition = 9e6
  []
  [h]
  []
[]

[ICs]
  [hic]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliq
    property = enthalpy
    temperature = 200
    temperature_unit = Celsius
    fp = water
  []
[]

[DiracKernels]
  # [mass]
  #   type = ConstantPointSource
  #   point = '5 5 0'
  #   variable = pliq
  #   value = -1
  # []
  [heat]
    type = ConstantPointSource
    point = '5 5 0'
    variable = h
    value = -2.344269e6
  []
[]

[AuxVariables]
  [pressure_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [pressure_water]
    order = CONSTANT
    family = MONOMIAL
  []
  [enthalpy_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [enthalpy_water]
    order = CONSTANT
    family = MONOMIAL
  []
  [saturation_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [saturation_water]
    order = CONSTANT
    family = MONOMIAL
  []
  [density_water]
    order = CONSTANT
    family = MONOMIAL
  []
  [density_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [viscosity_water]
    order = CONSTANT
    family = MONOMIAL
  []
  [viscosity_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [temperature]
    order = CONSTANT
    family = MONOMIAL
  []
  [e_gas]
    order = CONSTANT
    family = MONOMIAL
  []
  [e_water]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [enthalpy_water]
    type = PorousFlowPropertyAux
    variable = enthalpy_water
    property = enthalpy
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [enthalpy_gas]
    type = PorousFlowPropertyAux
    variable = enthalpy_gas
    property = enthalpy
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [pressure_water]
    type = PorousFlowPropertyAux
    variable = pressure_water
    property = pressure
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [pressure_gas]
    type = PorousFlowPropertyAux
    variable = pressure_gas
    property = pressure
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [saturation_water]
    type = PorousFlowPropertyAux
    variable = saturation_water
    property = saturation
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [saturation_gas]
    type = PorousFlowPropertyAux
    variable = saturation_gas
    property = saturation
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [density_water]
    type = PorousFlowPropertyAux
    variable = density_water
    property = density
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [density_gas]
    type = PorousFlowPropertyAux
    variable = density_gas
    property = density
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [viscosity_water]
    type = PorousFlowPropertyAux
    variable = viscosity_water
    property = viscosity
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [viscosity_gas]
    type = PorousFlowPropertyAux
    variable = viscosity_gas
    property = viscosity
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [temperature]
    type = PorousFlowPropertyAux
    variable = temperature
    property = temperature
    execute_on = 'initial timestep_end'
  []
  [e_water]
    type = PorousFlowPropertyAux
    variable = e_water
    property = internal_energy
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [egas]
    type = PorousFlowPropertyAux
    variable = e_gas
    property = internal_energy
    phase = 1
    execute_on = 'initial timestep_end'
  []
[]

[Kernels]
  [mass]
    type = PorousFlowMassTimeDerivative
    variable = pliq
  []
  [heat]
    type = PorousFlowEnergyTimeDerivative
    variable = h
  []
[]

[BCs]
  [flow]
    type= PorousFlowOutflowBC
    boundary = 'top bottom left right'
    variable = h
  []
[]


[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pliq h'
    number_fluid_phases = 2
    number_fluid_components = 1
  []
  [pc]
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

[FluidProperties]
  [water]
    type = Water97FluidProperties
  []
  [watertab]
    type = TabulatedBicubicFluidProperties
    fp = water
    interpolated_properties = 'density enthalpy viscosity internal_energy k c cv cp entropy'
    # fluid_property_file = fluid_properties.csv
    save_file = true
    construct_pT_from_ve = false
    construct_pT_from_vh = false
    error_on_out_of_bounds = false

    # Tabulation range
    temperature_min = 280
    temperature_max = 800
    pressure_min = 1e5
    pressure_max = 1e8

    # Newton parameters
    tolerance = 1e-5
    T_initial_guess = 313
    p_initial_guess = 9e6
  []
[]

[Materials]
  [watervapor]
    type = PorousFlowFluidStateSingleComponent
    porepressure = pliq
    enthalpy = h
    temperature_unit = Celsius
    capillary_pressure = pc
    fluid_state = fs
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1e-14 0 0 0 1e-14 0 0 0 1e-14'
  []
  [relperm0]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 0
  []
  [relperm1]
    type = PorousFlowRelativePermeabilityCorey
    n = 3
    phase = 1
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.2
  []
  [internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2650
    specific_heat_capacity = 1000
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  end_time = 1e4
  nl_abs_tol = 1e-4
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 10
  []

  automatic_scaling = true
  scaling_group_variables = 'h pliq'
  line_search = 'none'
  petsc_options = '-pc_svd_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'svd'
[]

[Preconditioning]

  active = mumps
  [mumps]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Postprocessors]
  [density_water]
    type = ElementAverageValue
    variable = density_water
    execute_on = 'initial timestep_end'
  []
  [density_gas]
    type = ElementAverageValue
    variable = density_gas
    execute_on = 'initial timestep_end'
  []
  [viscosity_water]
    type = ElementAverageValue
    variable = viscosity_water
    execute_on = 'initial timestep_end'
  []
  [viscosity_gas]
    type = ElementAverageValue
    variable = viscosity_gas
    execute_on = 'initial timestep_end'
  []
  [enthalpy_water]
    type = ElementAverageValue
    variable = enthalpy_water
    execute_on = 'initial timestep_end'
  []
  [enthalpy_gas]
    type = ElementAverageValue
    variable = enthalpy_gas
    execute_on = 'initial timestep_end'
  []
  [sg]
    type = ElementAverageValue
    variable = saturation_gas
    execute_on = 'initial timestep_end'
  []
  [sw]
    type = ElementAverageValue
    variable = saturation_water
    execute_on = 'initial timestep_end'
  []
  [pwater]
    type = ElementAverageValue
    variable = pressure_water
    execute_on = 'initial timestep_end'
  []
  [pgas]
    type = ElementAverageValue
    variable = pressure_gas
    execute_on = 'initial timestep_end'
  []
  [temperature]
    type = ElementAverageValue
    variable = temperature
    execute_on = 'initial timestep_end'
  []
  [enthalpy]
    type = ElementAverageValue
    variable = h
    execute_on = 'initial timestep_end'
  []
  [pliq]
    type = ElementAverageValue
    variable = pliq
    execute_on = 'initial timestep_end'
  []
  [liquid_mass]
    type = PorousFlowFluidMass
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [vapor_mass]
    type = PorousFlowFluidMass
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [liquid_heat]
    type = PorousFlowHeatEnergy
    phase = 0
    execute_on = 'initial timestep_end'
  []
  [vapor_heat]
    type = PorousFlowHeatEnergy
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [e_water]
    type = ElementAverageValue
    variable = e_water
    execute_on = 'initial timestep_end'
  []
  [e_gas]
    type = ElementAverageValue
    variable = e_gas
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  csv = true
  perf_graph = false
  exodus= true
[]

[Debug]
    show_var_residual_norms = true
[]
