# simple fluid
# trying two blocks

# SVD: condition number            inf, 405 of 1722 singular values are (nearly) zero
# SVD: smallest singular values: 0.000000000000e+00 6.663015007334e-23 2.617273069264e-22 3.663168320510e-22 4.808092995164e-22
# SVD: largest singular values : 1.360954516662e+00 1.519359607295e+00 1.589988010036e+00 1.971365254318e+00 2.303490705802e+00
# very high condition number and 405 nearly zero
# added block restriction based on
# https://github.com/idaholab/moose/discussions/20139

# not bad after seperating T and Tdike
# SVD: condition number 6.446542593349e+04, 0 of 1360 singular values are (nearly) zero
# SVD: smallest singular values: 3.573209223428e-05 3.594185447286e-05 6.229076052830e-05 6.906932618048e-05 7.444232760879e-05
# SVD: largest singular values : 1.768705906337e+00 1.829057500034e+00 1.866225582747e+00 1.971986173037e+00 2.303484545378e+00

# had to add MatchedValueBC around dike to transfer Temperatures
# works pretty well
# Noah suggested taking k down to 1e-19 when T>300 C but I worry this might
# cause numerical issues, could do it with ParsedAux
# and PorousFlowPermabilityConstfromVar
# or with PorousFlowPorosity and PermeabilityKarmenKozeny
# (Didn't do this yet)
# simulation looks okay and runs GREAT
# but no plume
# something a bit weird at left top bC between dike and host
# high V out of domain and very hot
# didn't include host_left in the PorousFlowPiecewiseLinearSinkBC
# still a bit weird

# lowering perm to 10e-12 gives nice plume

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 40
    ny = 20
    xmin = 0
    xmax = 500
    ymax = -200
    ymin = -1500
    bias_x = 1.20
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = ' 0 -1500 0'
    top_right = ' 50 -500 0'
  []
  [dike2]
    type = ParsedGenerateSideset
    input = dike
    combinatorial_geometry = 'x > 50 & x< 60'
    new_sideset_name = dike2
  []
  [rename]
    type = RenameBlockGenerator
    input = dike2
    old_block = '0 1'
    new_block = 'host dike'
  []
  [sidesets]
    type = SideSetsAroundSubdomainGenerator
    input = rename
    block = 'dike'
    new_boundary = 'dike_center'
    normal = '-1 0 0'
  []
  [sidesets2]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets
    block = 'dike'
    new_boundary = 'dike_edge_R'
    normal = '1 0 0'
  []
  [sidesets3]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets2
    block = 'dike'
    new_boundary = 'dike_edge_top'
    normal = '0 1 0'
  []
  [sidesets4]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets3
    block = 'host'
    new_boundary = 'host_bottom'
    normal = '0 -1 0'
  []
  [sidesets5]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets4
    block = 'host'
    new_boundary = 'host_left'
    normal = '-1 0 0'
  []
  [sidesets6]
    type = RenameBoundaryGenerator
    input = sidesets5
    old_boundary = 'dike_edge_R dike_edge_top'
    new_boundary = 'dike_edge dike_edge'
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
    scaling = 1e2
    block = 'host'
  []
  [T]
    scaling = 1e-5
    block = 'host'
  []
  [Tdike]
    scaling = 1e-2
    block = 'dike'
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
  [advectiveFlux]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffusiveFlux]
    family = MONOMIAL
    order = CONSTANT
  []
  [GradT]
    family = MONOMIAL
    order = CONSTANT
  []
  [nu]
    family = MONOMIAL
    order = CONSTANT
  []
  [eff_k]
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
  [Tall]
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
  [porosity]
    type = PorousFlowPropertyAux
    variable = porosity
    property = porosity
    block = 'host'
  []
  [density]
    type = PorousFlowPropertyAux
    variable = density
    property = density
    block = 'host'
  []
  [darcy_vel_x_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = x
    variable = water_darcy_vel_x
    fluid_phase = 0
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = water_darcy_vel_y
    fluid_phase = 0
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [enthalpy_water]
    type = PorousFlowPropertyAux
    variable = enthalpy
    property = enthalpy
    execute_on = 'initial timestep_end'
    block = 'host'
  []
  [advectiveFlux]
    type = AdvectiveFluxAux
    variable = advectiveFlux
    vel_x = water_darcy_vel_x
    vel_y = water_darcy_vel_y
    advected_variable = T
    component = x
    boundary = dike2
    check_boundary_restricted = false
  []
  [diffusiveFlux]
    type = DiffusionFluxAux
    variable = diffusiveFlux
    component = x
    diffusion_variable = T
    diffusivity = 'diff'
    boundary = dike2
    check_boundary_restricted = false
  []
  [GradT]
    type = VariableGradientComponent
    variable = GradT
    component = x
    gradient_variable = T
    block = 'host'
  []
  [eff_k]
    type = ParsedAux
    variable = eff_k
    coupled_variables = 'diffusiveFlux advectiveFlux GradT'
    expression='(diffusiveFlux+advectiveFlux)/(GradT+0.0001)'
    block = 'host'
  []
  [nu]
    type = ParsedAux
    variable = nu
    coupled_variables = 'diffusiveFlux advectiveFlux '
    expression ='advectiveFlux/(diffusiveFlux+0.0001)'
    block = 'host'
  []
  [perm]
    type = ParsedAux
    variable = perm
    coupled_variables = 'T'
    constant_names= 'k0 klow'
    constant_expressions = '10e-13 10e-19'
    expression = 'if(T>573,klow,k0)'
    block = 'host'
    execute_on = 'initial nonlinear timestep_end'
  []

[]

[ICs]
  [hydrostatic]
    type = FunctionIC
    variable = porepressure
    function = ppfunc
    block = 'host'
  []
  [geothermal]
    type = FunctionIC
    variable = T
    function = tfunc
    block = 'host'
  []
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.1
    max = 0.3
    block = 'host'
  []
  [dike_temperature]
    type = ConstantIC
    variable = Tdike
    value = 583
    block = 'dike'
  []
[]


[FluidProperties]

[water]
    type = SimpleFluidProperties
    #thermal_expansion= 0.001
[]
[]

[Functions]
  [dike_cooling]
      type = ParsedFunction
      expression = '515*(1-exp(-t/5000))+(285+(-y)*10/1000)'
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
    block = 'host'
    variable = T
  [../]
  [./PorousFlowUnsaturated_EnergyTimeDerivative]
    type = PorousFlowEnergyTimeDerivative
    block = 'host'
    variable = T
  [../]
  [./PorousFlowFullySaturated_AdvectiveFlux0]
    type = PorousFlowFullySaturatedAdvectiveFlux
    block = 'host'
    variable = porepressure
  [../]
  [./PorousFlowFullySaturated_MassTimeDerivative0]
    type = PorousFlowMassTimeDerivative
    block = 'host'
    variable = porepressure
  [../]
  [./PorousFlowFullySaturatedUpwind_HeatAdvection]
    type = PorousFlowFullySaturatedUpwindHeatAdvection
    variable = T
    block = 'host'
  [../]
  [./SpecificHeatConductionTimeDerivative]
    type = SpecificHeatConductionTimeDerivative
    variable = Tdike
    block = 'dike'
    density = density_dike
    specific_heat = specific_heat_dike
  [../]
  [./HeatCond]
    type = HeatConduction
    variable = Tdike
    block = 'dike'
    diffusion_coefficient = thermal_conductivity_dike
  []
[]

[Materials]
  [./PorousFlowActionBase_Temperature_qp]
    type = PorousFlowTemperature
    block = 'host'
    temperature = T
  [../]
  [./PorousFlowActionBase_Temperature]
    type = PorousFlowTemperature
    block = 'host'
    at_nodes = true
    temperature = T
  [../]
  [./PorousFlowActionBase_MassFraction_qp]
    type = PorousFlowMassFraction
    block = 'host'
  [../]
  [./PorousFlowActionBase_MassFraction]
    type = PorousFlowMassFraction
    block = 'host'
    at_nodes = true
  [../]
  [./PorousFlowActionBase_FluidProperties_qp]
    type = PorousFlowSingleComponentFluid
    block = 'host'
    compute_enthalpy = true
    compute_internal_energy = true
    fp = water
    phase = 0
  [../]
  [./PorousFlowActionBase_FluidProperties]
    type = PorousFlowSingleComponentFluid
    block = 'host'
    at_nodes = true
    fp = water
    phase = 0
  [../]
  [./PorousFlowUnsaturated_EffectiveFluidPressure_qp]
    type = PorousFlowEffectiveFluidPressure
    block = 'host'
  [../]
  [./PorousFlowUnsaturated_EffectiveFluidPressure]
    type = PorousFlowEffectiveFluidPressure
    block = 'host'
    at_nodes = true
  [../]
  [./PorousFlowFullySaturated_1PhaseP_qp]
    type = PorousFlow1PhaseFullySaturated
    block = 'host'
    porepressure = porepressure
  [../]
  [./PorousFlowFullySaturated_1PhaseP]
    type = PorousFlow1PhaseFullySaturated
    block = 'host'
    at_nodes = true
    porepressure = porepressure
  [../]
  [./PorousFlowActionBase_RelativePermeability_qp]
    type = PorousFlowRelativePermeabilityConst
    block = 'host'
    phase = 0
  [../]
  [porosity]
    type = PorousFlowPorosityConst
    porosity = porosity
    block = 'host'
  []
  [permeability]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = perm
    perm_yy = perm
    perm_zz = perm
    block = 'host'
  []
  [Matrix_internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2400
    specific_heat_capacity = 790
    block = 'host'
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4'
    block = 'host'
  []
  [parsedMatt]
    type = ParsedMaterial
    property_name = diff
    constant_names = 'kr kw'
    constant_expressions= '4 0.6'
    coupled_variables = 'porosity density'
    expression = '(porosity*kw+(1-porosity)*kr)*density'
  []
  [materials_host]
    type = GenericConstantMaterial
    prop_names = 'thermal_conductivity_dike specific_heat_dike density_dike'
    prop_values = '3.3 1200.0 3000'
    block = 'dike'
  []
[]

[BCs]
  [t_dike_dirichlet]
    type = FunctionDirichletBC
    variable = Tdike
    function = dike_cooling
    boundary = 'dike_center'
  []
  [t_dike_neumann]
    type = NeumannBC
    variable = Tdike
    boundary = 'dike_center'
    value = 0
  []
  [matched]
    type = MatchedValueBC
    variable = T
    boundary = 'dike_edge'
    v = Tdike
  []
  [pp_like_dirichlet]
      type = PorousFlowPiecewiseLinearSink
      variable = porepressure
      boundary = 'top host_bottom right host_left'
      pt_vals = '1e-9 1e9'
      multipliers = '1e-9 1e9'
      PT_shift = hydrostat
      flux_function = 1e-5 #1e-2 too high causes slow convergence
      use_mobility = true
      use_relperm = true
      fluid_phase = 0
  []
  [T_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = T
    boundary = 'host_bottom right host_left'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = geotherm
    flux_function = 1e-5 #1e-2 too high causes slow convergence
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
      end_time = '1.5e10'
      execute_on = 'initial timestep_begin'
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
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  end_time = 1.5e9
  dtmax = 1e8
  line_search = none
  automatic_scaling = true
  nl_abs_tol = 1e-6
  dtmin = 1
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 2000
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
    file_base = './visuals/two_block_simple'
    min_simulation_time_interval = 10000
    sequence = true
  [../]
[]

[VectorPostprocessors]
  [./temperature1500m]
    type = LineValueSampler
    sort_by = x
    variable = T
    start_point = '0 -1200 0'
    end_point = '500 -1200 0'
    num_points = 25
  []
  [./temperature300m]
    type = LineValueSampler
    sort_by = x
    variable = T
    start_point = '0 -600 0'
    end_point = '500 -600 0'
    num_points = 25
  []
[]
