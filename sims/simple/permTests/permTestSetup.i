depthAtTop = 1500 #m
L = 1000 #m
W = 50 #m
Ld = 700

nx = 20
ny = 20

geotherm = '${fparse 10/1000}' #K/m

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${nx}
    ny = ${ny}
    xmin= 0
    xmax = '${fparse L*2}'
    ymin = 0
    ymax = ${L}
    bias_x = 1.2
  []
  [cutout]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '${W} ${Ld} 0'
  []
  [rename]
    type = RenameBlockGenerator
    input = cutout
    old_block = '0 1'
    new_block = 'host dike'
  []
  [between]
   type = SideSetsBetweenSubdomainsGenerator
   input = rename
   primary_block = 'host'
   paired_block = 'dike'
   new_boundary = interface
  []
[]

[GlobalParams]
  PorousFlowDictator = 'dictator'
  gravity = '0 -9.81 0'
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'T porepressure'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[Variables]
  [T]
    order = FIRST
    family = LAGRANGE
  []
  [porepressure]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxVariables]
  [darcy_velx]
    family = MONOMIAL
    order = CONSTANT
  []
  [darcy_vely]
    family = MONOMIAL
    order = CONSTANT
  []
  [AreaAboveBackground]
    family = MONOMIAL
    order = CONSTANT
  []
  [geotherm]
    family = MONOMIAL
    order = CONSTANT
  []
  []

[AuxKernels]
  [darcy_vel_x_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = x
    variable = darcy_velx
    fluid_phase = 0
  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = darcy_vely
    fluid_phase = 0
  []
  [geotherm]
    type = FunctionAux
    variable = geotherm
    function = tfunc
    execute_on = 'initial'
  []
  [AreaAboveBackground]
    type = ParsedAux
    variable = AreaAboveBackground
    coupled_variables = 'geotherm T'
    expression = 'if(T>geotherm,1,0)'
  []
[]

[Functions]
  [ppfunc]
    type = ParsedFunction
    expression ='1.0135e5+(${depthAtTop})*9.81*1000+(${depthAtTop}-y)*1000*9.81' #1.0135e5-(y)*9.81*1000' #hydrostatic gradientose   + atmospheric pressure in Pa
  []
  [tfunc]
    type = ParsedFunction
    expression = '285+${depthAtTop}*${geotherm}+(${L}-y)*${geotherm}' #285+(-y)*10/1000 # geothermal 10 C per kilometer in kelvin
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
    block = 'host'
  []
  [dikeIC]
    type = ConstantIC
    variable = T
    value = 1438
    block = 'dike'
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

[BCs]
  [right]
    type = FunctionDirichletBC
    variable = T
    boundary = 'right'
    function = tfunc
  []
  [NeumannBC]
    type = NeumannBC
    variable = porepressure
    boundary = 'right top bottom'
    value = 0
  []


[]

[FluidProperties]
  [water]
    # thermal_expansion= 0.001
    type = SimpleFluidProperties
  []
[]


[Materials]
  [PorousFlowActionBase_Temperature_qp]
    type = PorousFlowTemperature

    temperature = 'T'
  []
  [PorousFlowActionBase_Temperature]
    type = PorousFlowTemperature

    at_nodes = true
    temperature = 'T'
  []
  [PorousFlowActionBase_MassFraction_qp]
    type = PorousFlowMassFraction

  []
  [PorousFlowActionBase_MassFraction]
    type = PorousFlowMassFraction

    at_nodes = true
  []
  [PorousFlowActionBase_FluidProperties_qp]
    type = PorousFlowSingleComponentFluid

    compute_enthalpy = true
    compute_internal_energy = true
    fp = water
    phase = 0
  []
  [PorousFlowActionBase_FluidProperties]
    type = PorousFlowSingleComponentFluid

    at_nodes = true
    fp = water
    phase = 0
  []
  [PorousFlowUnsaturated_EffectiveFluidPressure_qp]
    type = PorousFlowEffectiveFluidPressure

  []
  [PorousFlowUnsaturated_EffectiveFluidPressure]
    type = PorousFlowEffectiveFluidPressure

    at_nodes = true
  []
  [PorousFlowFullySaturated_1PhaseP_qp]
    type = PorousFlow1PhaseFullySaturated

    porepressure = 'porepressure'
  []
  [PorousFlowFullySaturated_1PhaseP]
    type = PorousFlow1PhaseFullySaturated

    at_nodes = true
    porepressure = 'porepressure'
  []
  [PorousFlowActionBase_RelativePermeability_qp]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.1
  []
  [Matrix_internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2400
    specific_heat_capacity = 790
    block = 'host'
  []
  [Matrix_internal_energy_dike]
    type = PorousFlowMatrixInternalEnergy
    density = 3000
    specific_heat_capacity = 1100
    block = 'dike'
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '3 0 0  0 3 0  0 0 3'
  []
[]

[Preconditioning]
  active = mumps
  [mumps]
    # much better than superlu
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
  [basic]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_shift_type '
    petsc_options_value = '  lu NONZERO'
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
  dt = 2e6
  line_search = none
  nl_abs_tol = 1e-7
  # dtmin = 1
  error_on_dtmin = false
  # steady_state_detection = true
  # steady_state_tolerance = 1e-12
  # verbose = true
  # [TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 1e6
  # []
[]

[Postprocessors]
  [T_host_max]
    type = ElementExtremeValue
    variable = 'T'
    block = 'host'
  []
  [T_host_avg]
    type = ElementAverageValue
    variable = 'T'
    block = 'host'
  []
  [T_dike_max]
    type = ElementExtremeValue
    variable = 'T'
    block = 'dike'
  []
  [vel_x_avg]
    type = ElementAverageValue
    variable = 'darcy_velx'
  []
  [vel_y_avg]
    type = ElementAverageValue
    variable = 'darcy_vely'
  []
  [vel_x_max]
    type = ElementExtremeValue
    variable = 'darcy_velx'
  []
  [vel_y_max]
    type = ElementExtremeValue
    variable = 'darcy_vely'
  []
  [T_dike_avg]
    type = ElementAverageValue
    variable = 'T'
    block = 'dike'
  []
  [q_dike]
    type = SideDiffusiveFluxIntegral
    variable = 'T'
    boundary = 'interface'
    diffusivity = '3'
  []
  [q_top]
    type = SideDiffusiveFluxIntegral
    variable = 'T'
    boundary = 'top'
    diffusivity = '3'
  []
  [perm]
    type = ElementAverageValue
    variable = 'perm'
  []
  [AreaAboveBackgroundSum]
    type = ElementIntegralVariablePostprocessor
    variable = 'AreaAboveBackground'
    block = 'host'
  []

[]

[VectorPostprocessors]
  [T_vec_near]
    type = LineValueSampler
    variable = T
    start_point = '0 750 0'
    end_point = '300 750 0'
    num_points = 20
    sort_by = x
    execute_on = 'initial timestep_end'
  []
  [T_vec_far]
    type = LineValueSampler
    variable = T
    start_point = '300 750 0'
    end_point = '150 750 0'
    num_points = 10
    sort_by = x
    execute_on = 'initial timestep_end'
  []
[]





