# log linear perm relationship
!include permTestSetup.i

[AuxVariables]
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [perm]
    type = ConstantAux
    variable = perm
    value = 10e-12
  []
[]

[Materials]:q_dike
  [permeability]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = 'perm'
    perm_yy = 'perm'
    perm_zz = 'perm'
  []
[]

[Controls/stochastic]
  type = SamplerReceiver
[]

[Reporters]
  [acc]
    type = AccumulateReporter
    reporters = 'T_host_avg/value T_dike_avg/value q_dike/value'
  []
[]

