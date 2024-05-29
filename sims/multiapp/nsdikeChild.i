!include nsdike.i

[AuxVariables]
  [intqx_parent]
    type = MooseVariableFVReal
  []
  [qx_from_parent]
    type = MooseVariableFVReal
  []
  [qx_norm]
    type = MooseVariableFVReal
  []
  [intqx_BC]
    type = MooseVariableFVReal
  []
[]

[AuxKernels]
  [intqx]
    type = FunctorAux
    variable = intqx_BC
    functor = 'intqx_BC_calc'
  []
  [qx_conserve]
    type = FunctorAux
    variable = intqx_parent
    functor = 'qx_interface'
  []
  [qx_norm]
    type = ParsedAux
    variable = qx_norm
    coupled_variables = 'qx_from_parent intqx_BC intqx_parent'
    expression = 'qx_from_parent*abs(intqx_parent)/(abs(intqx_BC)+1)'
  []
[]

[FVBCs]
  inactive = 'cooling_side_single'
  [cooling_side_multi]
    type = FVFunctorNeumannBC
    variable = T_child
    boundary = 'right'
    functor = 'qx_norm'
  []
[]

[VectorPostprocessors]
  [Tbc]
    type = LineValueSampler
    variable = T_child
    execute_on = 'timestep_end'
    start_point = '100 0 0'
    end_point = '100 1000 0'
    num_points = 20
    sort_by = 'id'
  []
[]

[Postprocessors]
  [q_x_avg]
    type = SideAverageValue
    variable = qx_norm
    boundary = 'right'
  []
  [intqx_BC_calc]
    type = SideIntegralVariablePostprocessor
    variable = qx_from_parent
    boundary = 'right'
  []
  [qxchild_calculation] # to check
    type = SideDiffusiveFluxIntegral
    variable = T_child
    boundary = 'right'
    functor_diffusivity= 'k_mixture'
  []
  [qxnorm_total] # to check
    type = SideIntegralVariablePostprocessor
    variable = qx_norm
    boundary = 'right'
  []
  [qx_interface]
    type = Receiver
  []

[]
