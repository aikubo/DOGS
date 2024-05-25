# testing cutout
# testing

# test 1:
# 1. Create a 10x10 mesh
# 2. Cut out a 3x7 block from the mesh
# 3. Rename the block to 'host dike'
# 4. Create a new boundary between the host and dike blocks
# 5. Delete the dike block
# 6. create cutout in mulitapp
# 7. transfer a constant aux variable from child to parent
# results: T_child is 0 across the entire domain, T_child_aux in sub set to 500
# test 2:
# add bbox_factor to parent of 1.2
# results: T_child has a value of 500 around the cutout and 0 elsewhere

# transfers back and forth worked for FE kernals
# but the q tranfer from FE to FV doesn't seem to be working
# MultiAppGeneralFieldShapeEvaluationTransfer does not work
# to transfer field variables from FE to FV
# MultiAppGeneralFieldNearestNodeTransfer works

# try with FixedPoints?
# withoutfixed points works fine
# with it fails to converge
# took out rel and abs tol and still no convergence

#adjusting tolerances got FixedPoints to converge
# based on
# https://github.com/idaholab/moose/discussions/24116

# fixed_point_abs_tol >> nl_abs_tol
# for FixedPoints to converge

# in the sub app, 1e-9 would not converger
# but added precond and automatic_scaling and it worked

# for some reason transfering parsed variable of k*gradT doesn't work
# just transfering k and gradT and doing the multiplication in the sub app works
# checked that changing the sub app resolution doesn't change the results

# added materials and porepressure for porousflow
# it fails completely

# works but not with fixed points
# trying to increase domain fails to converge
# when i increase the domain
# the nschild simulation does not solve at all????
#  child_app0: Pre-SMO residual: 0
# child_app0:
# child_app0: Performing automatic scaling calculation
# child_app0:
# child_app0:  0 Nonlinear |R| = 0.000000e+00
# child_app0:  Solve Converged!
# increasing the domain made the change in temperature across the domain of the sub app
# much smaller so it was approx zero
# added a source term to the sub app and added execute on initial and it worked
# also added line search = none to main app

# it works but I'm getting non physical results. negative temperatures!
# changing back to NEWTON worked and the results look better
# added permeability Temperature dependence and it actually speeds up convergence
# doesn't change the results too much

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin= 0
    xmax = 1000
    ymin = 0
    ymax = 1000
  []
  [cutout]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '100 1000 0'
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
    initial_condition = 300
  []
  [porepressure]
    order = FIRST
    family = LAGRANGE
    initial_condition = 1e6
  []
[]

[AuxVariables]
  [T_cutout]
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
  [GradTx]
    type = VariableGradientComponent
    variable = GradTx
    gradient_variable = T_parent
    component = x
    execute_on = 'initial timestep_end'
  []
  [diffx]
    type = ParsedAux
    variable = diffx
    coupled_variables = 'GradTx k'
    expression = 'k*GradTx'
    execute_on = 'initial timestep_end'
  []
  [k]
    type = ParsedAux
    variable = k
    expression = '5'
    execute_on = 'initial timestep_end'
  []
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
  [Matched]
    type = MatchedValueBC
    variable = T_parent
    boundary = interface
    v = T_cutout
  []
  [right]
    type = DirichletBC
    variable = T_parent
    boundary = 'right'
    value = 300.0
  []
  [NeumannBC]
    type = NeumannBC
    variable = porepressure
    boundary = 'right bottom interface'
    value = 0
  []
  # [pp_like_dirichlet]
  #   type = PorousFlowPiecewiseLinearSink
  #   variable = porepressure
  #   boundary = 'top right left bottom'
  #   pt_vals = '1e-9 1e9'
  #   multipliers = '1e-9 1e9'
  #   PT_shift = 1e6
  #   flux_function = 1e-5 #1e-2 too high causes slow convergence
  #   use_mobility = true
  #   use_relperm = true
  #   fluid_phase = 0
  # []
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
  end_time = 50
  line_search = 'none'
  dtmin = 0.01
  dt = 1
  automatic_scaling = true

  fixed_point_max_its = 15
  fixed_point_abs_tol = 1e-4
  fixed_point_rel_tol = 1e-3

  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-6
  verbose = true
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
  [qx_side_avg]
    type = SideAverageValue
    variable = diffx
    boundary = 'interface'
  []
[]

[Outputs]
  csv = true
  exodus = true
[]

[MultiApps]
  [./child_app]
    type = TransientMultiApp
    app_type = dikesApp
    input_files = 'childFV.i'
    #execute_on = 'initial timestep_begin'
    positions = '0 0 0'
  [../]
[]

[Transfers]
  [./transfer_to_child]
    type =  MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = child_app
    source_variable = T_child
    variable = T_cutout
    bbox_factor = 1.2
  [../]
  [push_qx]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppGeneralFieldNearestNodeTransfer
    to_multi_app = child_app
    source_variable = GradTx
    #bbox_factor = 1.2
    variable = GradTx_from_parent
  []
  [push_cond]
    type = MultiAppGeneralFieldNearestNodeTransfer
    to_multi_app = child_app
    source_variable = k
    variable = k_from_parent
  []
[]
