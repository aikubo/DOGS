# temperatre transfer seems to be working
# but the heat flux is not being transferred?
# block doesn't seem to cool
# there was an issue with the temperature transfer because
# it wasn't being transferred to the top boundary in the parent app
# i increased the bbox_factor to 1.2 and the child app to be slightly wider
# and slightly taller than the deleted block in the parent app



# log linear perm relationship


[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 20
    xmin = 0
    xmax = 100
    ymax = 100
    ymin = 0
    #bias_x = 1.25
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = ' 0 0 0'
    top_right = ' 20 100 0'
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
  PorousFlowDictator = 'dictator'
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
  []
  [T]
  []
[]

[AuxVariables]
  [hydrostat]
  []
  [geotherm]
  []
  [darcy_vel_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [darcy_vel_y]
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
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
  [conductivity]
      family = MONOMIAL
      order = CONSTANT
  []
  [GradTx]
    family = MONOMIAL
    order = CONSTANT
  []
  [GradTy]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffTx]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffTy]
    family = MONOMIAL
    order = CONSTANT
  []
  [T_dike] #comes from sub app
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
  []
  [darcy_vel_x_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = x
    variable = darcy_vel_x
    fluid_phase = 0
    execute_on = 'initial timestep_end'
  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = darcy_vel_y
    fluid_phase = 0
    execute_on = 'initial timestep_end'
  []
  [enthalpy_water]
    type = PorousFlowPropertyAux
    variable = enthalpy
    property = enthalpy
    execute_on = 'initial timestep_end'
  []
  [perm]
    type = ParsedAux
    variable = perm
    coupled_variables = 'T'
    constant_names = 'k0 klow'
    constant_expressions = '10e-13 10e-19'
    expression = 'k0'
    execute_on = 'initial nonlinear timestep_end'
  []
  [conductivity]
    type = ParsedAux
    variable = conductivity
    coupled_variables = 'porosity'
    constant_names = 'kappaw kappar'
    constant_expressions = '0.6 3'
    expression = 'porosity*kappaw + (1-porosity)*(kappar)'
    execute_on = 'initial'
  []
  [GradTx]
    type = VariableGradientComponent
    variable = GradTx
    gradient_variable = 'T'
    execute_on = 'initial timestep_end'
    component = x
  []
  [GradTy]
    type = VariableGradientComponent
    variable = GradTy
    gradient_variable = 'T'
    execute_on = 'initial timestep_end'
    component = x
  []
  [diffTx]
    type = ParsedAux
    variable = diffTx
    coupled_variables = 'conductivity GradTx'
    expression = 'conductivity*GradTx'
    execute_on = 'initial timestep_end'
  []
  [diffTy]
    type = ParsedAux
    variable = diffTy
    coupled_variables = 'conductivity GradTy'
    expression = 'conductivity*GradTy'
    execute_on = 'initial timestep_end'
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

  []
  [porosity]
    type = RandomIC
    variable = porosity
    min = 0.1
    max = 0.3

  []
[]

[FluidProperties]
  [water]
    # thermal_expansion= 0.001
    type = SimpleFluidProperties
  []
[]

[Functions]
  [dike_cooling]
    type = ParsedFunction
    expression = '515*(1-exp(-t/5000))+(285+(-y)*10/1000)'
  []
  [ppfunc]
    type = ParsedFunction
    expression = '1.0135e5-(y)*9.81*1000' # hydrostatic gradientose   + atmospheric pressure in Pa
  []
  [tfunc]
    type = ParsedFunction
    expression = '285+(-y)*10/1000' # geothermal 10 C per kilometer in kelvin
  []
[]

[Kernels]
  [PorousFlowUnsaturated_HeatConduction]
    type = PorousFlowHeatConduction

    variable = T
  []
  [PorousFlowUnsaturated_EnergyTimeDerivative]
    type = PorousFlowEnergyTimeDerivative

    variable = T
  []
  [PorousFlowFullySaturated_AdvectiveFlux0]
    type = PorousFlowFullySaturatedAdvectiveFlux

    variable = porepressure
  []
  [PorousFlowFullySaturated_MassTimeDerivative0]
    type = PorousFlowMassTimeDerivative

    variable = porepressure
  []
  [PorousFlowFullySaturatedUpwind_HeatAdvection]
    type = PorousFlowFullySaturatedUpwindHeatAdvection
    variable = T

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
  [conductivity_dummy]
    type = ParsedMaterial
    property_name = conductivity_dummy
    expression = '3'
  []
[]

[BCs]
  [pp_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = porepressure
    boundary = 'top'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = hydrostat
    flux_function = 1e-6 #1e-2 too high causes slow convergence
    use_mobility = true
    use_relperm = true
    fluid_phase = 0
  []
  [T_like_dirichlet]
    type = PorousFlowPiecewiseLinearSink
    variable = T
    boundary = 'top'
    pt_vals = '1e-9 1e9'
    multipliers = '1e-9 1e9'
    PT_shift = geotherm
    flux_function = 1e-6 #1e-2 too high causes slow convergence
  []
  [pp_right]
    type = NeumannBC
    variable = porepressure
    boundary = 'host_edge right bottom'
    value = 0
  []
  [t_bc]
    type = NeumannBC
    variable = T
    boundary = 'right bottom'
    value = 0
  []
  [from_sub]
    type = MatchedValueBC
    variable = T
    boundary = 'host_edge'
    v = T_dike
  []

[]

[MultiApps]
  [dummyTBC]
    type = TransientMultiApp
    app_type = dikesApp # NavierStokesTestApp
    input_files = 'nsdike_child.i'
    execute_on = 'initial timestep_begin'
    sub_cycling = true
    output_sub_cycles=true
  []
[]

[Transfers]
  [pull_Tbc]
    # Transfer from the sub-app to this app
    # The name of the variable in the sub-app
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = dummyTBC
    source_variable = 'T'
    variable = 'T_dike'
    bbox_factor = 1.2
    execute_on = 'initial timestep_begin'
  []
  [push_qx]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = dummyTBC
    source_variable = diffTx
    variable = qx_from_parent
    execute_on = 'initial timestep_begin'
  []
  [push_qx]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppGeneralFieldShapeEvaluationTransfer
    to_multi_app = dummyTy
    source_variable = diffTu
    variable = qx_from_parent
    execute_on = 'initial timestep_begin'
  []
[]

[Postprocessors]
  [T_host_avg]
    type = ElementAverageValue
    variable = 'T'
  []
  [q_diffusive]
    type = SideAverageValue
    variable = 'diffT'
    boundary = 'host_edge'
  []
  [T_dike]
    type = ElementAverageValue
    variable = 'T_dike'
  []
[]

[Preconditioning]
  [mumps]
    # much better than superlu
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  end_time = 1e7
  line_search = none
  automatic_scaling = true

  dt = 5000
  fixed_point_max_its = 10
  fixed_point_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  verbose = true
[]

[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  [out]
    type = Exodus
    file_base = ./visuals/pflowParent_test

  []
[]


