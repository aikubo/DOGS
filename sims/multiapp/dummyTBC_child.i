[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 5
    xmin = 0
    xmax = 10
    ymax = 0
    ymin = -10
  []
[]


[Variables]
  [T]
  []
[]


[Kernels]
  [diff]
    type = Diffusion
    variable = T
  []
  [td]
    type = TimeDerivative
    variable = T
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = T
    boundary = bottom
    value = 400
  []
  [right]
    type = DirichletBC
    variable = T
    boundary = top
    value = 200
  []
[]

[AuxVariables]
  [h]
  []
[]


[Executioner]
  type = Transient
  end_time = 2
  dt = 0.2

  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Postprocessors]
  [h_avg]
    type = ElementAverageValue
    variable = h
  []
[]



