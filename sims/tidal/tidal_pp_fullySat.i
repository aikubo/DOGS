# Trying to replace PorousFlowBasicTHM with PorousFlowFullySat
# - divergence issues "Nonlinear solve did not converge due to DIVERGED_FNORM_NAN."
# traced with --trap-fpe (in command line run) then gdb with "break libmesh_handleFPE"
#
# error is in
# (gdb) bt
# #0  0x00007ffff798c190 in PorousFlowJoinerTempl<false>::computeQpProperties (this=0x5555561a9dc0)
#     at /home/akh/myprojects/moose_projects/moose/modules/porous_flow/src/materials/PorousFlowJoiner.C:134
# #1  0x00007ffff0fd0f0a in Material::computeProperties (
#     this=0x5555561a9dc0)
#     at /home/akh/myprojects/moose_projects/moose/framework/src/materials/Material.C:132
# #2  0x00007ffff7994332 in PorousFlowMaterial::computeProperties
#     (this=0x5555561a9dc0)
# some issue with when PorousFlowFullySaturated adds materials
# added KT stabilization and it runs a lot faster but issue remains (which makes sense)

#From PorousFlowFullySaturated documentation
# it does not add all the materials you may need, notably PorousFlowRelativePermeabilityConst
# which is necessary for the darcyvelocity AuxKernals
# that didn't work I get this error
# The following material properties are declared on block 0 by multiple materials:

# what worked was moving biot_modulus from GlobalParams to PorousFlowFullySaturated


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
[PorousFlowFullySaturated]
  porepressure = porepressure
  coupling_type = HydroMechanical
  displacements = 'disp_x disp_y disp_z'
  fp = the_simple_fluid
  biot_coefficient = 0.6
  gravity = ' 0 0 0'
  stabilization = KT

[]

[Materials]
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
  [porosity]
    type = PorousFlowPorosityConst # only the initial value of this is ever used
    porosity = 0.1
  []
  [biot_modulus]
    type = PorousFlowConstantBiotModulus
    solid_bulk_compliance = 1E-10
    fluid_bulk_modulus = 2E9
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1E-12 0 0   0 1E-12 0   0 0 1E-12'
  []


[]

# [Postprocessors]
#   [pp]
#     type = PointValue
#     point = '0.5 0.5 0.5'
#     variable = porepressure
#   []
# []

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
  line_search = 'none'

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = .1
  []
[]

[Outputs]
  console = true
  csv = true
  exodus = true
[]
