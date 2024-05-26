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

[Materials]
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
