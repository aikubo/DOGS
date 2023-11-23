#
# [Adaptivity]
#   max_h_level = 2
#   marker = marker
#   initial_marker = initial
#   initial_steps = 2
#   [Indicators]
#     [indicator]
#       type = GradientJumpIndicator
#       variable = temperature
#     []
#   []
#   [Markers]
#     [marker]
#       type = ErrorFractionMarker
#       indicator = indicator
#       refine = 0.8
#     []
#     [initial]
#       type = BoxMarker
#       bottom_left = '0 1.95 0'
#       top_right = '2 2 0'
#       inside = REFINE
#       outside = DO_NOTHING
#     []
#   []
# []

[Mesh]
  type = GeneratedMesh
  dim = 2
  ymin = 1.5
  ymax = 2
  xmax = 2
  ny = 20
  nx = 40
  bias_y = 1.05
[]

[AuxVariables]
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []

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
  [temperature]
    type = PorousFlowPropertyAux
    variable = temperature
    property = temperature
    execute_on = 'initial timestep_end'
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[Variables]
  [pliq]
    initial_condition = 9e6
  []
  [h]
    scaling = 1e-3
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

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = ' pliq h'
    number_fluid_phases = 2
    number_fluid_components = 1
  []
  [pc]
    #The capillary pressure is the pressure difference between two fluid phases
    #in a porous medium that arises due to the interfacial
    # tension between the fluid phases and the surface tension
    #between fluids and the porous medium.
    # constant for testing
    type = PorousFlowCapillaryPressureConst
    pc = 0 #default

  []
  [fs]
    type = PorousFlowWaterVapor
    water_fp = true_water
    capillary_pressure = pc
  []
[]

[ICs]
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.25
    max = 0.275
    seed = 0
  []
  [hic]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliq
    property = enthalpy
    temperature = 30
    temperature_unit = Celsius
    fp = true_water
  []

[]

[BCs]
  [bottom_enthalpy]
    type = PorousFlowSink
    variable = h
    boundary = bottom
    flux_function = -5000
  []

  [pressureBC]
    type = PorousFlowOutflowBC
    boundary = 'left right top'
    variable = pliq
  []

[]


[FluidProperties]
  [true_water]
    type = Water97FluidProperties
  []
  # [tabulated_water]
  #   type = TabulatedBicubicFluidProperties
  #   fp=true_water
  #   interpolated_properties = 'density enthalpy viscosity internal_energy k c cv cp entropy'
  #   # fluid_property_file = fluid_properties.csv
  #   save_file = true
  #   construct_pT_from_ve = true
  #   construct_pT_from_vh = true
  #   error_on_out_of_bounds = false
  #
  #   # Tabulation range
  #   temperature_min = 280
  #   temperature_max = 850
  #   pressure_min = 1e5
  #   pressure_max = 7e5
  #
  #   # Newton parameters
  #   tolerance = 1e-8
  #   T_initial_guess = 310
  #   p_initial_guess = 1.8e5
  # []
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
  [porosity]
    type = PorousFlowPorosity
    porosity_zero = 0.1
  []
  [biot_modulus]
    type = PorousFlowConstantBiotModulus
    biot_coefficient = 0.8
    solid_bulk_compliance = 2E-7
    fluid_bulk_modulus = 1E7
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1E-14 0 0   0 1E-14 0   0 0 1E-14'
  []

  [thermal_expansion]
    type = PorousFlowConstantThermalExpansionCoefficient
    biot_coefficient = 0.8
    drained_coefficient = 0.003
    fluid_coefficient = 0.0002
  []
  [rock_internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2500.0
    specific_heat_capacity = 1200.0
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '10 0 0  0 10 0  0 0 10'
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
[]

# [Preconditioning]
#   # active = mumps
#   # [mumps]
#   #   type = SMP
#   #   full = true
#   #   petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
#   #   petsc_options_value = ' lu       mumps'
#   # []
#   # [basic]
#   #   type = SMP
#   #   full = true
#   #   petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
#   #   petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
#   #   petsc_options_value = ' asm      lu           NONZERO      2'
#   # []
# []
[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1e5
  nl_abs_tol = 1e-5
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 50
  []
  line_search = 'none'
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]
# [Executioner]
#   type = Transient
#   solve_type = NEWTON
#   end_time = 1e4
#   nl_max_its = 25
#   l_max_its = 100
#   dtmax = 1e4
#   nl_abs_tol = 1e-6
#   [TimeStepper]
#     type = IterationAdaptiveDT
#     dt = 100
#     growth_factor = 2
#     cutback_factor = 0.5
#   []
# []

# [VectorPostprocessors]
#   [tempvector]
#     type = LineValueSampler
#     variable = temperature
#     end_point = ' 1 0 0'
#     start_point = '1 2 0 '
#     sort_by = y
#     num_points = 20
#   []
# []

[Outputs]
  print_linear_residuals = true
  perf_graph = true
  exodus = true
  csv = true
[]
