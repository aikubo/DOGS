# altering tidal_pp_fullySat to use the kernals instead of the action
# added kernals based on test/pp_generation.i
# porepressure increases linearly like in pp generation
# not cyclically like expected ...
# that was because i added all earth gravity
# without earth gravity it performs well
# still requires to increase nl_abs_tol for convergence
# matches exactly with PorousFlowBasicTHM now :D

# does not converge with PP BC and BodyForce/gravity applied
# Nonlinear solve did not converge due to DIVERGED_DTOL iterations 2
#  Solve Did NOT Converge!
# Aborting as solve did not converge
# need to calculate gravity for enceladus
# do i need nodalgravity?

# added gravity for x, y, z
# cannot get mesh to converge (works okay for 1)

# using SVD
# shows x of y singular values are zero which might be
# bad boundary conditions
# added pin on "pole" to have one more BC
# can try just fixing one dimension of displacement

# shows high condition number
# suggests preconditionin, scaling, mesh refinement
# increased number of nodes to 20 x 20 x20
# runs way too slow
# went to 10 x 10 x 10
# same issue with convergence
#



[Mesh]
  [the_mesh]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 4
    ny = 4
    nz = 4
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    zmin = 0
    zmax = 1
  []
  [pole]
    type = ExtraNodesetGenerator
    input = the_mesh
    new_boundary = pole
    coord = '.5 0 .5'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  PorousFlowDictator = dictator
  block = 0
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure disp_x disp_y disp_z'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[AuxVariables]
  [porosity]
    order = CONSTANT
    family = MONOMIAL
  []
  [perm_x]
     order = CONSTANT
     family = MONOMIAL
   []
   [perm_y]
     order = CONSTANT
     family = MONOMIAL
   []
   [perm_z]
     order = CONSTANT
     family = MONOMIAL
   []
  #  [g_aux]
  #    order = FIRST
  #    family = LAGRANGE
  # []
[]

 [AuxKernels]
   [poro]
     type = PorousFlowPropertyAux
     property = porosity
     variable = porosity
   []
   [perm_x]
     type = PorousFlowPropertyAux
     property = permeability
     variable = perm_x
     row = 0
     column = 0
   []
   [perm_y]
     type = PorousFlowPropertyAux
     property = permeability
     variable = perm_y
     row = 1
     column = 1
   []
   [perm_z]
     type = PorousFlowPropertyAux
     property = permeability
     variable = perm_z
     row = 2
     column = 2
   []
[]

[Variables]
  [disp_x]

    initial_condition = 0
  []
  [disp_y]

    initial_condition = 0
  []
  [disp_z]

    initial_condition = 0
  []
  [porepressure]
    initial_condition = 10
  []

[]

[BCs]
  [pp]
    type =DirichletBC
    variable = porepressure
    value = 10
    boundary = 'left right bottom top front back'
  []
  [polex]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = pole
  []
  [poley]
    type = DirichletBC
    variable = disp_z
    value = 0
    boundary = pole
  []
  [z]
    type = DirichletBC
    variable = disp_z
    value = 0
    boundary = top
  []
  [z2]
    type = DirichletBC
    variable = disp_z
    value = 0
    boundary = bottom
  []

[]

# [ICs]
#   [pp]
#
#   []
# []

[Functions]
  [earth_tide_x]
    type = ParsedFunction
    expression = 10*cos(t*20*pi)
    #expression = 'x*1E-3*(5*cos(t*2*pi) + 2*cos((t-0.5)*2*pi) + 1*cos((t+0.3)*0.5*pi))'
  []
  [earth_tide_y]
    type = ParsedFunction
    expression = 5*cos(t*60*pi)
    #expression = 'y*1E-3*(7*cos(t*2*pi) + 4*cos((t-0.3)*2*pi) + 7*cos((t+0.6)*0.5*pi))'
  []
  [earth_tide_z]
    type = ParsedFunction
    expression = 2*cos(t*40*pi)
    #expression = 'z*1E-3*(7*cos((t-0.5)*2*pi) + 4*cos((t-0.8)*2*pi) + 7*cos((t+0.1)*4*pi))'
  []
[]

[FluidProperties]
  [the_simple_fluid]
    type = SimpleFluidProperties
    bulk_modulus = 2E9
  []
[]

# [PorousFlowBasicTHM]
#   coupling_type = HydroMechanical
#   displacements = 'disp_x disp_y disp_z'
#   porepressure = porepressure
#   gravity = '0 0 0'
#   fp = the_simple_fluid
# []
# [PorousFlowFullySaturated]
#   porepressure = porepressure
#   coupling_type = HydroMechanical
#   displacements = 'disp_x disp_y disp_z'
#   fp = the_simple_fluid
#   biot_coefficient = 0.6
#   gravity = ' 0 0 0'
#   #stabilization = KT
#
# []

[Kernels]
  [grad_stress_x]
    type = StressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [grad_stress_y]
    type = StressDivergenceTensors
    variable = disp_y
    component = 1
  []
  [grad_stress_z]
    type = StressDivergenceTensors
    variable = disp_z
    component = 2
  []
  [poro_x]
    type = PorousFlowEffectiveStressCoupling
    biot_coefficient = 0.6
    variable = disp_x
    component = 0
  []
  [poro_y]
    type = PorousFlowEffectiveStressCoupling
    biot_coefficient = 0.6
    variable = disp_y
    component = 1
  []
  [poro_z]
    type = PorousFlowEffectiveStressCoupling
    biot_coefficient = 0.6
    component = 2
    variable = disp_z
  []
  [poro_vol_exp]
    type = PorousFlowMassVolumetricExpansion
    variable = porepressure
    fluid_component = 0
  []
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
  [flux]
    type = PorousFlowAdvectiveFlux
    variable = porepressure
    gravity = '0 0 0'
    fluid_component = 0
  []
  [gravity_x]
    type = Gravity
    variable = disp_x
    value = -9.81
    function = earth_tide_x
  []
  [gravity_y]
    type = Gravity
    variable = disp_y
    value = -9.81
    function = earth_tide_y
  []
  [gravity_z]
    type = Gravity
    variable = disp_z
    value = -9.81
    function = earth_tide_z
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
  []
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    bulk_modulus = 10.0E9 # drained bulk modulus
    poissons_ratio = 0.25
  []
  [strain]
    type = ComputeSmallStrain
  []
  [stress]
    type = ComputeLinearElasticStress
  []
  [eff_fluid_pressure]
    type = PorousFlowEffectiveFluidPressure
  []
  [vol_strain]
    type = PorousFlowVolumetricStrain
  []
  [ppss]
    type = PorousFlow1PhaseFullySaturated
    porepressure = porepressure
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
  [simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = the_simple_fluid
    phase = 0
  []
  [porosity]
    type = PorousFlowPorosity
    fluid = true
    mechanical = true
    porosity_zero = 0.1
    biot_coefficient = 0.6
    solid_bulk = 10.0E9
  []

  [biot_modulus]
    type = PorousFlowConstantBiotModulus
    solid_bulk_compliance = 1E-10
    fluid_bulk_modulus = 2E9
  []
  [permeability]
    type = PorousFlowPermeabilityKozenyCarman
    poroperm_function = kozeny_carman_phi0
    k0 = 10e-12
    phi0 = 0.1
    m = 2
    n = 7
  []

  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    n = 0 # unimportant in this fully-saturated situation
    phase = 0
  []
  [density]
    type = PorousFlowTotalGravitationalDensityFullySaturatedFromPorosity
    rho_s = 2400
  []

[]

[Postprocessors]
  [pp]
    type = PointValue
    point = '0.5 0.5 0.5'
    variable = porepressure
  []
  [poro]
    type = PointValue
    point = '0.5 0.5 0.5'
    variable = porosity
  []
  [permx]
    type = PointValue
    point = '0.5 0.5 0.5'
    variable = perm_x
  []
[]
#
# [Preconditioning]
#   [mumps]
#     type = SMP
#     full = true
#     petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
#     petsc_options_value = ' lu       mumps'
#   []
# []

[Executioner]
  type = Transient
  solve_type = Newton
  automatic_scaling = true
  end_time = 100
  #nl_abs_tol = 1e-8
  #l_abs_tol = 1e-5
  dt = .1

  petsc_options = '-pc_svd_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'svd'
  line_search = 'none'
  # [./TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 0.1
  # []
[]

[Outputs]
  console = true
  csv = true
  exodus = true
[]
