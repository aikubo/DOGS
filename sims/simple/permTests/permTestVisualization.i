!include permTestSetup.i


[AuxVariables]
  [perm]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[Adaptivity]
  max_h_level = 2
  marker = marker
  initial_marker = initial
  initial_steps = 2
  [Indicators]
    [indicator]
      type = GradientJumpIndicator
      variable = T
    []
  []
  [Markers]
    [marker]
      type = ErrorFractionMarker
      indicator = indicator
      refine = 0.8
    []
    [initial]
      type = BoxMarker
      bottom_left = '0 0 0'
      top_right = '500 1100 0'
      inside = REFINE
      outside = DO_NOTHING
    []
  []
[]

[AuxKernels]
  [perm]
    type = ConstantAux
    variable = perm
    value = 10e-14
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

[Outputs]
  exodus = true
  csv = true
[]
