!include permTestSetup.i

[AuxVariables]
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
  [permExp]
    family = MONOMIAL
    order = CONSTANT
  []
  [m]
    family = MONOMIAL
    order = CONSTANT
  []
  [b]
    family = MONOMIAL
    order = CONSTANT
  []
  [Tlow]
    family = MONOMIAL
    order = CONSTANT
  []
  [Thigh]
    family = MONOMIAL
    order = CONSTANT
  []
  [klow]
    family = MONOMIAL
    order = CONSTANT
  []
  [khigh]
    family = MONOMIAL
    order = CONSTANT
  []
  [distanceFrmDikeCorner]
    family = MONOMIAL
    order = CONSTANT
  []
  [anipermx]
    family = MONOMIAL
    order = CONSTANT
  []
  [anifactor]
    family = MONOMIAL
    order = CONSTANT
  []
  [Tfracture]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [klow]
    type = ConstantAux
    variable = klow
    value = -20
    execute_on = 'initial'
  []
  [khigh]
    type = ConstantAux
    variable = khigh
    value = -13
    execute_on = 'initial'
  []
  [Tlow]
    type = ConstantAux
    variable = Tlow
    value = 400
    execute_on = 'initial'
  []
  [Thigh]
    type = ConstantAux
    variable = Thigh
    value = 900
    execute_on = 'initial'
  []
  [anifactor]
    type = ConstantAux
    variable = anifactor
    value = 1
    execute_on = 'initial'
  []
  [Tfracture]
    type = ConstantAux
    variable = Tfracture
    value = 1438
    execute_on = 'initial'
  []
  [m]
    type = ParsedAux
    variable = m
    coupled_variables = 'klow khigh Tlow Thigh'
    execute_on = 'initial'
    expression = '(klow-khigh)/(Thigh-Tlow)'
  []
  [b]
    type = ParsedAux
    variable = b
    coupled_variables = 'klow m Thigh'
    expression = 'klow-m*Thigh'
    execute_on = 'initial'
  []
  [distanceFrmDikeCorner]
    type = ParsedAux
    variable = distanceFrmDikeCorner
    use_xyzt = true
    constant_names = 'w l'
    constant_expressions = '${W} ${L}'
    expression = '(x-2*l)/2*l'
    execute_on = 'initial'
  []
  [permExp]
    type = ParsedAux
    variable = permExp
    coupled_variables = 'T m b Tlow khigh'
    expression = 'if(T>Tlow, m*T+b, khigh)'
    execute_on = 'initial nonlinear timestep_end'
  []
  [perm]
    type = ParsedAux
    variable = perm
    coupled_variables = 'T permExp Thigh klow'
    expression = 'if(T>Thigh, 10^klow, 10^permExp)'
    execute_on = 'initial nonlinear timestep_end'
  []
  [permx]
    type = ParsedAux
    variable = anipermx
    coupled_variables = 'perm Tfracture'
    expression = 'if(T>Tfracture, perm*10^anifactor, perm)'
  []
[]

[Materials]
  [permeability]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = 'anipermx'
    perm_yy = 'perm'
    perm_zz = 'perm'
  []
[]

[Controls/stochastic]
  type = SamplerReceiver
[]

[Postprocessors]
  [klow]
    type = ElementAverageValue
    variable = klow
  []
  [khigh]
    type = ElementAverageValue
    variable = khigh
  []
  [Tlow]
    type = ElementAverageValue
    variable = Tlow
  []
  [Thigh]
    type = ElementAverageValue
    variable = Thigh
  []
  [m]
    type = ElementAverageValue
    variable = m
  []
  [b]
    type = ElementAverageValue
    variable = b
  []
  [permExp]
    type = ElementAverageValue
    variable = permExp
  []
[]

[Outputs]
  exodus = true
[]
