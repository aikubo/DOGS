depthAtTop = 1500 #m
L = 1000 #m
W = 100 #m

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
  []
  [cutout]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '${W} ${L} 0'
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
  [delete]
    type = BlockDeletionGenerator
    input = between
    block = 'dike'
  []
[]

[GlobalParams]
  PorousFlowDictator = 'dictator'
  gravity = '0 -9.81 0'
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'T_parent porepressure'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[Variables]
  [T_parent]
    order = FIRST
    family = LAGRANGE
  []
  [porepressure]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxVariables]
 [dikeTemp]
    order = FIRST
    family = LAGRANGE
  []
  [GradTx]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffx]
    family = MONOMIAL
    order = CONSTANT
  []
  [k]
    family = MONOMIAL
    order = CONSTANT
  []
  [porosity]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
  [permExp]
    family = MONOMIAL
    order = CONSTANT
  []
  [darcy_velx]
    family = MONOMIAL
    order = CONSTANT
  []
  [darcy_vely]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
   [porosity]
    type = ParsedAux
    variable = porosity
    expression = '0.1'
  []
  [permExp]
    type = ParsedAux
    variable = permExp
    coupled_variables = 'T_parent'
    constant_names= 'm b k0exp'
    constant_expressions = '-0.01359 -9.1262 -13' #calculated myself via linear
    expression = 'if(T_parent>400, m*T_parent+b, k0exp)'
    execute_on = 'initial nonlinear timestep_end'
  []
  [perm]
    type = ParsedAux
    variable = perm
    coupled_variables = 'T_parent permExp'
    constant_names= 'klow'
    constant_expressions = '10e-20 '
    expression = 'if(T_parent>900,klow, 10^permExp)'
    execute_on = 'initial nonlinear timestep_end'
  []
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
  [tfuncdike]
    type = ParsedAux
    variable = dikeTemp
    expression = '1438'
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
    variable = T_parent
    function = tfunc
  []
[]

[Kernels]
  [./PorousFlowUnsaturated_HeatConduction]
    type = PorousFlowHeatConduction
    #block = 'host'
    variable = T_parent
  [../]
  [./PorousFlowUnsaturated_EnergyTimeDerivative]
    type = PorousFlowEnergyTimeDerivative
    #block = 'host'
    variable = T_parent
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
    variable = T_parent
    #block = 'host'
  [../]

[]

[BCs]
  [right]
    type = FunctionDirichletBC
    variable = T_parent
    boundary = 'right bottom top interface'
    function = tfunc
  []
  [NeumannBC]
    type = NeumannBC
    variable = porepressure
    boundary = 'right top bottom interface'
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

    temperature = 'T_parent'
  []
  [PorousFlowActionBase_Temperature]
    type = PorousFlowTemperature

    at_nodes = true
    temperature = 'T_parent'
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
    porosity = 'porosity'
  []
  [permeability]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = 'perm'
    perm_yy = 'perm'
    perm_zz = 'perm'
  []
  [Matrix_internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2400
    specific_heat_capacity = 790
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
  solve_type = 'NEWTON'
  end_time = 3e9
  line_search = 'none'
  dtmin = 0.01
  automatic_scaling = true
  nl_abs_tol = 1e-9
  nl_rel_tol = 1e-6
  verbose = true
  steady_state_detection = true
  steady_state_tolerance = 1e-12
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1000
  []
[]

[Postprocessors]
  [t_avg_interface]
    type = SideAverageValue
    variable = T_parent
    boundary = 'interface'
  []
  [t_avg]
    type = ElementAverageValue
    variable = T_parent
  []
[]

[Outputs]
  csv = true
  exodus = true
[]

