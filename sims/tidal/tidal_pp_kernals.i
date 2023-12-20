# altering tidal_pp_fullySat to use the kernals instead of the action
# added kernals based on test/pp_generation.i
# porepressure increases linearly like in pp generation
# not cyclically like expected ...
# that was because i added all earth gravity
# without earth gravity it performs well
# still requires to increase nl_abs_tol for convergence
# matches exactly with PorousFlowBasicTHM now :D

[Mesh]

  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 1
  zmin = 0
  zmax = 1
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
  [pc]
    type = PorousFlowCapillaryPressureVG
    m = 0.8
    alpha = 1
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
  []
  [disp_y]
  []
  [disp_z]
  []
  [porepressure]
  []
[]

[BCs]
  [strain_x]
    type = FunctionDirichletBC
    variable = disp_x
    function = earth_tide_x
    boundary = 'left right'
  []
  [strain_y]
    type = FunctionDirichletBC
    variable = disp_y
    function = earth_tide_y
    boundary = 'bottom top'
  []
  [strain_z]
    type = FunctionDirichletBC
    variable = disp_z
    function = earth_tide_z
    boundary = 'back front'
  []
[]

[Functions]
  [earth_tide_x]
    type = ParsedFunction
    expression = 'x*1E-8*(5*cos(t*2*pi) + 2*cos((t-0.5)*2*pi) + 1*cos((t+0.3)*0.5*pi))'
  []
  [earth_tide_y]
    type = ParsedFunction
    expression = 'y*1E-8*(7*cos(t*2*pi) + 4*cos((t-0.3)*2*pi) + 7*cos((t+0.6)*0.5*pi))'
  []
  [earth_tide_z]
    type = ParsedFunction
    expression = 'z*1E-8*(7*cos((t-0.5)*2*pi) + 4*cos((t-0.8)*2*pi) + 7*cos((t+0.1)*4*pi))'
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
  # [source]
  #   type = BodyForce
  #   function = 0.1
  #   variable = porepressure
  # []
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

[Preconditioning]
  [mumps]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton

  end_time = 2
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'
  nl_abs_tol = 1.3e-5
  dt = 0.01
  line_search = 'none'
[]

[Outputs]
  console = true
  csv = true
  exodus = true
[]
