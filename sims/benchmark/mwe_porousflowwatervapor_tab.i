# MWE showing that PorousFlowWaterVapor does not work with TabulatedBicubicFluidProperties
# based on water_vapor_phase_change.i

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmax = 10
  ymax = 10
  zmax = 10
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Variables]
  [pliq]
    initial_condition = 9e6
  []
  [h]
    scaling = 1e-3
  []
[]

[ICs]
  [hic]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliq
    property = enthalpy
    temperature = 300
    temperature_unit = Celsius
    fp = water_tab
  []
[]

[DiracKernels]
  [mass]
    type = ConstantPointSource
    point = '5 5 5'
    variable = pliq
    value = -1
  []
  [heat]
    type = ConstantPointSource
    point = '5 5 5'
    variable = h
    value = -1.344269e6
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
    water_fp = water_tab
    capillary_pressure = pc
  []
[]

[FluidProperties]
  [water]
    type = Water97FluidProperties
  []
  [water_tab]
    type = TabulatedBicubicFluidProperties
    fp = water
    save_file = false

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


[AuxVariables]

    [temperature]
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
  []
  

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1e3
  nl_abs_tol = 1e-12
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 10
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]


[Outputs]
  csv = true
  perf_graph = false
[]
