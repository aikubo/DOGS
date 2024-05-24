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
# i noticed that it seems like the nschild app is not solving at all
# because the residual is smaller than the tolerance

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    xmin= 0
    xmax = 10
    ymin = 0
    ymax = 10
  []
  [cutout]
    type = SubdomainBoundingBoxGenerator
    input = gen
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '3 7 0'
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
  [GradTy]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffx]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffy]
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
  []
  [GradTy]
    type = VariableGradientComponent
    variable = GradTy
    gradient_variable = T_parent
    component = y
  []
  [diffx]
    type = ParsedAux
    variable = diffx
    coupled_variables = 'GradTx k'
    expression = 'k*GradTx'
  []
  [diffy]
    type = ParsedAux
    variable = diffx
    coupled_variables = 'GradTy k'
    expression = 'k*GradTy'
  []
  [k]
    type = ParsedAux
    variable = k
    expression = '5'
  []
  [porosity]
    type = ParsedAux
    variable = porosity
    expression = '0.1'
  []
  [permeability]
    type = ParsedAux
    variable = perm
    expression = '10e-13'
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
    boundary = 'top right'
    value = 300.0
  []
  [pp]
    type = DirichletBC
    variable = porepressure
    boundary = 'bottom left right top'
    value = 1e6
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
  [conductivity_dummy]
    type = ParsedMaterial
    property_name = conductivity_dummy
    expression = '3'
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
  solve_type = 'PJFNK'
  end_time = 5
  dt = 2

  # fixed_point_max_its = 5
  # fixed_point_abs_tol = 1e-6

  # nl_abs_tol = 1e-8
  # verbose = true
[]

[VectorPostprocessors]
  [t_sampler]
    type = LineValueSampler
    variable = T_parent
    start_point = '5 0 0'
    end_point = '5 10 0'
    num_points = 5
    sort_by = x
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
  [qx_side_avg]
    type = SideAverageValue
    variable = diffx
    boundary = 'interface'
  []
  [qy_side_avg]
    type = SideAverageValue
    variable = diffy
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
    execute_on = 'initial timestep_begin'
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
  [push_qy]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppGeneralFieldNearestNodeTransfer
    to_multi_app = child_app
    source_variable = GradTy
    #bbox_factor = 1.2
    variable = GradTy_from_parent
  []
  [push_cond]
    type = MultiAppGeneralFieldNearestNodeTransfer
    to_multi_app = child_app
    source_variable = k
    variable = k_from_parent
  []
[]
