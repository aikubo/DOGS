[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    ny=25
    nx=15
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pliquid h'
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
    water_fp = true_water
    capillary_pressure = pc
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[Variables]
  [pliquid]
    initial_condition = 1e6
  []
  [h]
  []
[]

[AuxVariables]
  [temperature]
    order = CONSTANT
    family = MONOMIAL
  []
  [psteam]
    order = CONSTANT
    family = MONOMIAL
  []
  [sat]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [temperature]
    type = PorousFlowPropertyAux
    variable = temperature
    property = temperature
    execute_on = 'initial timestep_end'
  []
  [psteam]
    type=PorousFlowPropertyAux
    variable = psteam
    property = pressure
    phase = 1
    execute_on = 'initial timestep_end'
  []
  [steamsat]
    type=PorousFlowPropertyAux
    variable = sat
    property =saturation
    phase = 1
    execute_on = 'initial timestep_end'
  []
[]

[Kernels]
  [mass_water_dot]
    type = PorousFlowMassTimeDerivative
    variable = pliquid
  []
  [flux_water]
    type = PorousFlowAdvectiveFlux
    variable = pliquid
  []
  [eng_time]
    type=PorousFlowEnergyTimeDerivative
    variable = h
  []
  [h_advect]
    type=PorousFlowHeatAdvection
    variable = h
  []
  [h_cond]
    type=PorousFlowHeatConduction
    variable = h
  []
[]

[FluidProperties]
  [true_water]
    type = Water97FluidProperties    # IAPWS-IF97
  []
[]


[Materials]
  [watervapor]
    type = PorousFlowFluidStateSingleComponent
    porepressure = pliquid
    enthalpy = h
    temperature_unit = Celsius
    capillary_pressure = pc
    fluid_state = fs
  []
  [permeability1]
    type = PorousFlowPermeabilityConst
    permeability = '1e-10 0 0 0 1e-10 0 0 0 1e-10'
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
    porosity = 0.1
  []
  [internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2500
    specific_heat_capacity = 1200
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '2.5 0 0  0 2.5 0  0 0 2.5'
  []
[]


[ICs]
  [hic]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliquid
    property = enthalpy
    temperature = 50
    temperature_unit = Celsius
    fp = true_water
  []
  # [pic]
  #   # type = FunctionIC
  #   # variable = pliquid
  #   # function = '9.81*(25-y)*2500+101325'
  # []
[]


[BCs]

    # [heat_production]
    #   type = PorousFlowSink
    #   boundary = 'bottom'
    #   variable = h
    #   flux_function = -1e6
    #   use_enthalpy = true
    #   fluid_phase = 0
    #   use_relperm = true
    # []
    # [outflow_a]
    #   type = PorousFlowOutflowBC
    #   boundary = 'left right'
    #   variable = pliquid
    # []
    # [outflow_h]
    #   type = PorousFlowOutflowBC
    #   boundary = 'left right'
    #   variable = h
    # []
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

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1e9
  nl_max_its = 50
  l_max_its = 100
  dtmax = 5e5

  nl_abs_tol = 1.5E-08       # solver parameter. Nonlinear absolute tolerance. Default to 1E-50
  nl_rel_tol = 1E-9          # solver parameter. Nonlinear Relative Tolerance. Default to 1E-08
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
  []
  line_search = 'none'
  automatic_scaling = true
[]


[Outputs]
  print_linear_residuals = true
  perf_graph = true
  exodus = true
  csv = true
[]
