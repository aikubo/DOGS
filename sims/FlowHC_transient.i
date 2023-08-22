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
    ny = 3
    xmax = 10
    ymax = 3
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
    initial_condition = 1073 #800 c
  []
  [Ts]
    order = FIRST
    family = LAGRANGE
    block = 'wallrock'
#    initial_condition = 313 #40 c
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
  [initial_Ts]
  type = ConstantIC
  variable = Ts
  value = 313
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
  [./ftemperature_time0]
    type = INSADHeatConductionTimeDerivative
    variable = Tf
    block = 'dike'
  [../]
    [f_time]
      type=ADHeatConductionTimeDerivative
      variable=Tf
      block='dike'
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
  [s_temp_time]
    type=ADHeatConductionTimeDerivative
    variable=Ts
    block='wallrock'
  []
[]

[InterfaceKernels]
  [./convection_heat_transfer]
    type = ConjugateHeatTransfer
    variable = Tf
    T_fluid = Tf
    neighbor_var = 'Ts'
    boundary = 'dike_contact'
    htc = 1 # 50000
  [../]
[]

[BCs]
  [./right]
    #tried HeatConductionBC which doesn't seem to work
    # we should make the domain large enough that the heat should
    # dissipate so we can just put this as a constant Temp BC
    type=ADDirichletBC
    variable= Ts
    value= 313
    boundary = 'right'
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
  # [./inlet_temp]
  #   type = DirichletBC
  #   variable =Tf
  #   boundary = 'inlet'
  #   value = 1073
  # [../]
  [./left_temp]
    #assume fully molten in center of dike
    type = DirichletBC
    variable =Tf
    boundary = 'left'
    value = 1073
  [../]

  # pressure boundary conditions
  #

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

  [./dike_mat]
    type = ADGenericConstantMaterial
    prop_names = 'density rho mu cp k'
    prop_values = '998 998 0.001 4128 0.6' #'${fluid_rho} ${fluid_mu}  ${fluid_cp}  ${fluid_k}'
    block = 'dike'
  [../]

  [ins_mat]
    type = INSADStabilized3Eqn
    velocity = velocity
    pressure = p
    temperature = Tf
    block='dike'
  []

  [./granite_mat]
    type = ADGenericConstantMaterial
    prop_names = 'density rho k'
    prop_values = '2750 2750 3.2'  # kg m^-3
    block = 'wallrock'
  []
  [thermal_granite]
    type = ADHeatConductionMaterial
    thermal_conductivity = 3.2 #W/mK
    specific_heat = 790 #J/kgK
    block = 'wallrock'
  []
  [thermal_dike]
    type = ADHeatConductionMaterial
    thermal_conductivity = 1.48 #W/mK
    specific_heat = 1480 #J/kgK
    block = 'dike'
  []
[]
# [Preconditioning]
#   [./SMP]
#     type = SMP
#     full = false
#     petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
#     petsc_options_value = ' lu       mumps'
#     solve_type = PJFNK
#   [../]
# []

[Executioner]
  type = Transient
  dt = 1e-3
  num_steps = 1000
  end_time = 1009
  solve_type = 'NEWTON'
  # solve_type = PJFNK


  l_max_its = 100
  nl_max_its =100
  l_tol = 1e-5
  nl_abs_tol = 1e-3
  nl_rel_tol = 1e-5

#petsc_options_iname = '-pc_type -pc_factor_mat_solver_package -ksp_gmres_restart'
#  petsc_options_value = 'lu       superlu_dist                  200'
  line_search = 'none'
  automatic_scaling = 'true'
[]
[Debug]
  show_var_residual_norms = true
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
  perf_graph = true
[]
