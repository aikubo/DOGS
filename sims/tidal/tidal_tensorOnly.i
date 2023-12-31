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

# as expected doen't work with BCs
# trying a NeumanBC function the same as the body force?
#

# works ad neuman BC
# when i try to visualize in paraview
# it looks like a box moving around
# try to "pin" it
# Next steps: figure out how to add pinned boundary
#
# pin with ExtraNodesetGenerator seems to be working
# don't check "Apply displacements" in paraview!
#
# trying sphere

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  #large_kinematics = true
  use_displaced_mesh = true
[]

[Mesh]
  [mesh]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 10
    nz = 10
    xmax = 10
    ymax = 10
    zmax = 10
  []
  [pin]
    type = ExtraNodesetGenerator
    input = mesh
    new_boundary = 100
    coord = '5 5 5'
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
    expression = -10*cos(t/5)
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
    variable = disp_x
    function = gravf
    use_displaced_mesh = true
  []

[]

[BCs]
  # [bottom_x]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = bottom
  #   value = 0
  # []
  # [bottom_y]
  #   type = DirichletBC
  #   variable = disp_y
  #   boundary = bottom
  #   value = 0
  # []

  [xbc]
    type = FunctionNeumannBC
    variable = disp_x
    boundary = 'right left'
    function = gravf
  []
  # [ybc]
  #   type = DirichletBC
  #   variable = disp_y
  #   value = 0
  #   boundary = ' top bottom'
  # []
  [polex]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = 100
  []
  [poley]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = 100
  []
  [polez]
    type = DirichletBC
    variable = disp_z
    value = 0
    boundary = 100
  []
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

  nl_rel_tol = 5e-9
  nl_abs_tol = 5e-9
  l_tol = 5e-9
  l_abs_tol = 5e-9

  nl_max_its = 50
  l_max_its = 100
  line_search = none

  automatic_scaling = true
[]
[Postprocessors]
  [./disp_x]
    type = PointValue
    point = '1 1 1'
    variable = disp_x
    use_displaced_mesh = true
  [../]
[]

[Outputs]
  exodus = true
  print_linear_residuals = true
[]

[Debug]
  show_var_residual_norms = true
[]
