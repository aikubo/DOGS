!include nsdike.i

[AuxVariables]
  [GradTx_from_parent]
    type = MooseVariableFVReal
  []
  [qx]
    type = MooseVariableFVReal
  []
  [k_from_parent]
    type = MooseVariableFVReal
  []
  [dtaux]
    type = MooseVariableFVReal
  []
[]

[AuxKernels]
  [dtaux]
    type = FunctorAux
    variable = dtaux
    functor = 'dtpost'
  []
  [qx]
    type = ParsedAux
    variable = qx
    coupled_variables = 'GradTx_from_parent k_from_parent dtaux'
    expression = 'k_from_parent*GradTx_from_parent*dtaux'
  []
[]

[FVBCs]
  inactive = 'cooling_side_single'
  [cooling_side_multi]
    type = FVFunctorNeumannBC
    variable = T_child
    boundary = 'right'
    functor = 'qx'
  []
[]

[Postprocessors]
  [q_x_side]
    type = SideAverageValue
    variable = qx
    boundary = 'right'
  []
  [qxchild]
    type = SideDiffusiveFluxIntegral
    variable = T_child
    boundary = 'right'
    functor_diffusivity= 'k_mixture'
    execute_on = 'transfer'
  []
  [dtpost]
    type = TimestepSize
    execute_on = TIMESTEP_BEGIN
  []
[]
