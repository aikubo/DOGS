!include nsdike_lowqx.i
[Functions]
  [qxdy_high]
    type = ParsedFunction
    symbol_names = 'qmax'
    symbol_values = '-30000'
    expression = 'qmax/sqrt(y)*sqrt(1000)'
  []
[]

[FVBCs]
  inactive = cooling_side_low
  [cooling_side_high]
    type = FVFunctorNeumannBC
    variable = T_child
    boundary = 'right'
    functor = 'qxdy_high'
  []
[]
