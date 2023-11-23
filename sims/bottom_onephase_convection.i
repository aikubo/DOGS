

[Adaptivity]
  max_h_level = 2
  marker = marker
  initial_marker = initial
  initial_steps = 2
  [Indicators]
    [indicator]
      type = GradientJumpIndicator
      variable = temperature
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
      bottom_left = '0 1.95 0'
      top_right = '2 2 0'
      inside = REFINE
      outside = DO_NOTHING
    []
  []
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    ymin = 0
    ymax = 300
    xmax = 100
    ny = 100
    nx = 50
  []

  [dike]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '100 35 0'
    block_name = dike
    input = gen
  []
[]

[AuxVariables]
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []
  [perm]
    order = CONSTANT
    family = MONOMIAL
  []

[]

[AuxKernels]
  [perm]
    type = PorousFlowPropertyAux
    variable = perm
    property = permeability
  []

[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Variables]
  [porepressure]

  []
  [temperature]

  []
[]

[PorousFlowBasicTHM]
  porepressure = porepressure
  temperature = temperature
  coupling_type = ThermoHydro
  gravity = '0 -9.81 0'
  fp = true_water
[]


[ICs]
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.25
    max = 0.350
    seed = 0
  []
  [pressure]
    type = ConstantIC
    variable = porepressure
    value = 10e6
  []
  [temperature1]
    type= ConstantIC
    variable = temperature
    value = 300
    block = 0
  []
  [temperature2]
    type= ConstantIC
    variable = temperature
    value = 500
    block = 'dike'
  []
[]

[BCs]
  [insulaing]
    type = NeumannBC
    value = 0
    variable = temperature
    boundary = 'right left top bottom'
  []
[]


[FluidProperties]
  [true_water]
    type = Water97FluidProperties
  []
[]

[Materials]
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
  [permeability2]
    type = PorousFlowPermeabilityConst
    permeability = '1E-14 0 0   0 1E-14 0   0 0 1E-14'
    block = 0
  []
  [permeability1]
    type = PorousFlowPermeabilityConst
    permeability = '0 0 0   0 0 0   0 0 0'
    block = 'dike'
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
    specific_heat_capacity = 1200.
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '2.5 0 0  0 2.5 0  0 0 2.5'
  []
[]

[Preconditioning]
  active = mumps
  [mumps]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
  [basic]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = ' asm      lu           NONZERO      2'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1e9
  nl_max_its = 25
  l_max_its = 100
  dtmax = 5e5
  nl_abs_tol = 1e-8
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 10000
  []
  line_search = 'none'
[]

[Postprocessors]
  [tempTime]
    type = SideAverageValue
    variable = temperature
    boundary =  'right'
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  print_linear_residuals = true
  perf_graph = true
  exodus = true
  csv = true
[]
