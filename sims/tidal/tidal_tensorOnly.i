# making a tensor TensorMechanics only example
# changed so large strains are posible based her
# https://github.com/idaholab/moose/discussions/22784
# and use_displaced_mesh = true

# running kernals/gravity with value = -100
# runs and reaches steady state
# after changing nl and l tols
# using nodal kernal or kernal gravity
# with function defined in function section
# does not seem to work at all

# using bodyforce kernal with function
# might work after changing tol again

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  #large_kinematics = true
  use_displaced_mesh = true
[]

[Mesh]
  [generated]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 10
    nz = 10
  []
[]

[Variables]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_z]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Functions]
  [gravf]
    type = ParsedFunction
    expression = -100*cos(t*20*pi)*(t/5)
  []
[]

# [NodalKernels]
#   [./force_y2]
#     type = NodalGravity
#     variable = disp_y
#     block = 0
#     function = gravf
#     mass = 1
#   #  nodal_mass_file = nodal_mass.csv # commented out for testing purposes
#   # mass = 0.01899772 # commented out for testing purposes
#   [../]
# []

[Kernels]
  # [./gravity_y]
  #   type = Gravity
  #   use_displaced_mesh = true
  #   variable = disp_y
  #   value = 1
  #   function = gravf
  # [../]
  [./TensorMechanics]
    #Stress divergence kernels
    displacements = 'disp_x disp_y disp_z'
  [../]
  [gravy]
    type = BodyForce
    variable = disp_y
    function = gravf
  []
[]

[BCs]
  [bottom_x]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  []
  [bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  # [Pressure]
  #   [top]
  #     boundary = top
  #     function = 1e7*t
  #   []
  # []
[]

[Materials]
  [./elasticity_tensor_core]
    #Creates the elasticity tensor using steel parameters
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e9 #Pa
    poissons_ratio = 0.3

    block = 0
  [../]
  [./strain]
    #Computes the strain, assuming small strains
    type = ComputeFiniteStrain
    block = 0
    displacements = 'disp_x disp_y disp_z'
  [../]
  [./stress]
    #Computes the stress, using linear elasticity
    type = ComputeFiniteStrainElasticStress
    block = 0
  [../]
  [./density_steel]
    #Defines the density of core
    type = GenericConstantMaterial
    block = 0
    prop_names = density
    prop_values = 2400 # kg/m^3
  [../]
[]

# consider all off-diagonal Jacobians for preconditioning
[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  end_time = 50
  dt = 1

  nl_rel_tol = 1e-14
  nl_abs_tol = 1e-14
  l_tol = 1e-14
  l_abs_tol = 1e-14

  nl_max_its = 50
  l_max_its = 100
  line_search = none

  automatic_scaling = true

[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
