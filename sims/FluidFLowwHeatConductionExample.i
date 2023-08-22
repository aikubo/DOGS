fluid_mu = 0.001   # Pa*s
fluid_rho = 998.2    #kg/m3
fluid_cp = 4128      #j/kg-k
fluid_k = 0.6     #w/m-k
plate_k = 30
source_k = 401


[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 10
    xmax = 10
    ymax = 10
    nz = 5
    zmax = 5
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '2 10 5'
    block_name = dike
    input = gen
  []
  [create_sideset1]
    type = SideSetsAroundSubdomainGenerator
    input = dike
    block = 'dike'
    new_boundary = 'outlet'
    normal = ' 0 1 0'
    external_only = true
  []
  [create_sideset2]
    type = SideSetsAroundSubdomainGenerator
    input = create_sideset1
    block = 'dike'
    new_boundary = 'inlet'
    normal = ' 0 -1 0'
    external_only = true
  []
  [wallrock]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '2 0 0 '
    top_right = '10 10 5'
    block_name = wallrock
    input = create_sideset2
  []
  [contact_area]
    type = SideSetsBetweenSubdomainsGenerator
    input = wallrock
    primary_block = 'dike'
    paired_block = 'wallrock'
    new_boundary = 'dike_contact'
  []
  # [rename1]
  #   type = RenameBoundaryGenerator
  #   input = contact_area
  #   old_boundary = 'left'
  #   new_boundary = 'inlet'
  # []
  # [rename2]
  #   type = RenameBoundaryGenerator
  #   input = rename1
  #   old_boundary = 'right'
  #   new_boundary = 'outlet'
  # []
[]


[Variables]
  [Tf]
    order = FIRST
    family = LAGRANGE
    block = 'dike'
    initial_condition = 293
  []
  [Ts]
    order = FIRST
    family = LAGRANGE
    block = 'wallrock'
    initial_condition = 293
  []
  [./velocity]
    family = LAGRANGE_VEC
    block='dike'
  [../]
  [./p]
    order = FIRST
    family = LAGRANGE
    block='dike'
  [../]
[]

[ICs]
  [velocity]
    type = VectorConstantIC
    x_value = 1e-15
    y_value = 2.87
    z_value = 1e-15
    variable = velocity
  []
[]


[Kernels]
 [./mass]
    type = INSADMass
    variable = p
  [../]
  [./mass_pspg]
    type = INSADMassPSPG
    variable = p
  [../]
  [./momentum_convection]
    type = INSADMomentumAdvection
    variable = velocity
  [../]
  [./momentum_viscous]
    type = INSADMomentumViscous
    variable = velocity
  [../]
  [./momentum_pressure]
    type = INSADMomentumPressure
    variable = velocity
    pressure = p
    integrate_p_by_parts = true
  [../]
  [./momentum_supg]
    type = INSADMomentumSUPG
    variable = velocity
    velocity = velocity
  [../]
  [./temperature_advection]
    type = INSADEnergyAdvection
    variable = Tf
    block = 'dike'
  [../]
  [fluid_temperature_conduction]
    type = ADHeatConduction
    variable = Tf
    block = 'dike'
    thermal_conductivity = 'k'
  []
  [temperature_supg]
    type = INSADEnergySUPG
    variable = Tf
    velocity = velocity
    block = 'dike'
  []

  [solid_temperature_conduction]
    type = ADHeatConduction
    variable = Ts
    block ='wallrock'
    thermal_conductivity = 'k'
  []
[]

[InterfaceKernels]
  [./convection_heat_transfer]
    type = ConjugateHeatTransfer
    variable = Tf
    T_fluid = Tf
    neighbor_var = 'Ts'
    boundary = 'dike_contact'
    htc = 50000
  [../]
[]

[BCs]
  [./plane_wall]#PCB
    type = ADConvectiveHeatFluxBC
    variable = Ts
    boundary = 'right'
    T_infinity = 293
    heat_transfer_coefficient = 25
  [../]
  [./no_slip]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = 'dike_contact'
  [../]
  [./vec_inlet]
    type = VectorFunctionDirichletBC
    variable = velocity
    boundary = 'inlet'
    function_y = 2.87 #m/s
  [../]
  [./inlet_temp]
    type = DirichletBC
    variable =Tf
    boundary = 'inlet'
    value = 303
  [../]
  # [./outlet_p]
  #   type = DirichletBC
  #   variable = p
  #   boundary = 'outlet'
  #   value = 0
  # [../]
  # [./source]
  #   type = NeumannBC
  #   variable = Ts
  #   boundary = 'dike_contact'
  #   value = 2.432e5
  # [../]
[]

[Materials]
  [./plate_mat]
    type = ADGenericConstantMaterial
    prop_names = 'k'
    prop_values =  30 #'${plate_k}'
    block = 'wallrock'
  [../]

  [./fluid_mat]
    type = ADGenericConstantMaterial
    prop_names = 'rho mu cp k'
    prop_values = '998 0.001 4128 0.6' #'${fluid_rho} ${fluid_mu}  ${fluid_cp}  ${fluid_k}'
    block = 'dike'
  [../]
  [ins_mat]
    type = INSADStabilized3Eqn
    velocity = velocity
    pressure = p
    temperature = Tf
    block='dike'
  []
[]
[Preconditioning]
  [./SMP]
    type = SMP
    full = false
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
    solve_type = PJFNK
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 20
  nl_max_its =1000

  l_tol = 1e-5
  nl_rel_tol = 1e-3

  solve_type = PJFNK
  ##petsc_options_iname = '-pc_type -pc_hypre_type'
  ##petsc_options_value = 'hypre boomeramg'
   petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart'
  petsc_options_value = 'lu       superlu_dist                  200'

[]
[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = true
  file_base = htccflux_out1
  perf_graph = true
[]
