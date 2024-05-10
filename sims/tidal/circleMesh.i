[Mesh]
  type = ConcentricCircleMesh
  num_sectors = 2
  radii = '150 185'
  rings = '1 1'
  preserve_volumes = on
  has_outer_square = false
  coord_type = RZ
  inner_mesh_fraction = 0.5
[]

[Variables]
  [./u]
  [../]
[]

[Kernels]
  [./diff]
    type = Diffusion
    variable = u
  [../]
[]

[BCs]
  [./left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  [../]
  [./right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 1
  [../]
[]

[Executioner]
  type = Steady
[]

[Outputs]
  exodus = true
[]
