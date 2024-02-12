# added custom IC with temperature profile


[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 25
  ny = 25
  ymax = 100 #m
  xmax = 100 #m
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
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

[Variables]
  [pliquid]
  []
  [h]
    scaling = 1e-6
  []
[]

[Functions]
  [ppfunc]
    type = ParsedFunction
    expression = 1.5e5+(100-y)*9.81*2400
  []
[]


[ICs]
  [ppic]
    type = FunctionIC
    variable = pliquid
    function = ppfunc
  []
  [hic]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliquid
    property = enthalpy
    temperature = 50
    temperature_unit = Celsius
    fp = water
  []
[]

[BCs]
  [ptop]
    type = ADDirichletBC
    variable = pliquid
    value = 1.0e5
    boundary = top
  []
  [pbot]
    type = ADDirichletBC
    variable = pliquid
    value = 2354400
    boundary = bottom
  []
  [hleft]
    type = DirichletBC
    variable = h
    value = 678.52e3
    boundary = left
  []
  [hright]
    type = DirichletBC
    variable = h
    value = 721.4e3
    boundary = right
  []
[]

[Kernels]
  [mass]
    type = PorousFlowMassTimeDerivative
    variable = pliquid
  []
  [massflux]
    type = PorousFlowAdvectiveFlux
    variable = pliquid
  []
  [heat]
    type = PorousFlowEnergyTimeDerivative
    variable = h
  []
  # [heatflux]
  #   type = PorousFlowHeatAdvection
  #   variable = h
  # []
  [heatcond]
    type = PorousFlowHeatConduction
    variable = h
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
    type = PorousFlowCapillaryPressureVG
    pc_max = 1e6
    sat_lr = 0.1
    m = 0.5
    alpha = 1e-5
  []
  [fs]
    type = PorousFlowWaterVapor
    water_fp = wat
    capillary_pressure = pc
  []
[]

[FluidProperties]
  [wat]
    type = Water97FluidProperties    # IAPWS-IF97
  []
  [water]
    type = TabulatedBicubicFluidProperties
    fp = wat
    error_on_out_of_bounds = false
    #fluid_property_file = water_IAPWS95_kubo.csv
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
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.2
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1.8e-11 0 0 0 1.8e-11 0 0 0 1.8e-11'
  []
  [relperm_water]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 0
    s_res = 0.1
    sum_s_res = 0.1
  []
  [relperm_gas]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 1
    sum_s_res = 0.1
  []
  [internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2400
    specific_heat_capacity = 740
  []
  [rock_thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4'
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 5e3
  nl_abs_tol = 1e-10
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
  []
[]

[VectorPostprocessors]
  [line]
    type = ElementValueSampler
    sort_by = x
    variable = temperature
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  perf_graph = true
  exodus = true
  execute_on = 'initial timestep_end failed'
[]
