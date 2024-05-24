
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 15
    ny = 15
    xmin= 0
    xmax = 100
    ymin = 0
    ymax = 500
  []
[]

[Variables]
  [T_child]
    type = INSFVEnergyVariable
    initial_condition = 1438
  []

[]

[AuxVariables]
  [GradTx_from_parent]
    type = MooseVariableFVReal
  []
  [GradTy_from_parent]
    type = MooseVariableFVReal
  []
  [diffx]
    type = MooseVariableFVReal
  []
  [diffy]
    type = MooseVariableFVReal
  []
  [k_from_parent]
    type = MooseVariableFVReal
  []
[]

[AuxKernels]
  [diffx]
    type = ParsedAux
    variable = diffx
    coupled_variables = 'GradTx_from_parent k_from_parent'
    expression = 'k_from_parent*GradTx_from_parent'
  []
  [diffy]
    type = ParsedAux
    variable = diffy
    coupled_variables = 'GradTy_from_parent k_from_parent'
    expression = 'k_from_parent*GradTy_from_parent'
  []
[]


[FVKernels]
  [heat_conduction]
    type = FVDiffusion
    variable = T_child
    coeff = 4
  []
  [time_derivative]
    type = INSFVEnergyTimeDerivative
    variable = T_child
    rho = 1000
  []
[]

[FVBCs]
  [right]
    type = FVDirichletBC
    variable = T_child
    boundary = 'bottom'
    value = 1438
  []
  [from_parentx]
    type = FVFunctorNeumannBC
    variable = T_child
    boundary = 'right'
    functor = 'diffx'
  []
  [from_parenty]
    type = FVFunctorNeumannBC
    variable = T_child
    boundary = 'top'
    functor = 'diffy'
  []
[]

[FunctorMaterials]
  [ins_fv]
    type = INSFVEnthalpyFunctorMaterial
    rho = 1000
    cp = 1000
    temperature = 'T_child'
  []
[]



[Executioner]
  type = Transient
  end_time = 5
  dt = 1
  automatic_scaling = true
  line_search = 'none'
  # petsc_options_iname = '-pc_type -pSc_factor_shift_type'
  # petsc_options_value = 'lu NONZERO'

  nl_abs_tol = 1e-11
  l_abs_tol = 1e-16
[]

[Postprocessors]
  [t_avg_interface]
    type = SideAverageValue
    variable = T_child
    boundary = 'right top'
  []
  [q_x_side]
    type = SideAverageValue
    variable = diffx
    boundary = 'right'
  []
  [q_y_side]
    type = SideAverageValue
    variable = diffy
    boundary = 'top'
  []
  [t_avg]
    type = ElementAverageValue
    variable = T_child
  []
[]

[Outputs]
  csv = true
  exodus = true
[]
