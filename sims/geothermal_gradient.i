# 1. start with dike with CONDUCTION ONLY

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 25
  ny = 25
  ymax = 100 #m
  xmax = 100 #m
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'porepressure temperature'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
  [pc]                                      # // Add the capillary pressure UserObject
    type = PorousFlowCapillaryPressureVG
    alpha = 1E-6
    m = 0.6
  []
[]


[Variables]
  [porepressure]
    family = LAGRANGE
    order = SECOND
    #initial_from_file_var = porepressure # this is handled by CopyNodalVarsAction
    #initial_from_file_timestep = LATEST # LATEST [note the ICs block must not appear, or would overrride this]
  []
   [temperature]
    family = LAGRANGE
    order = SECOND
    #initial_from_file_var = temperature # this is handled by CopyNodalVarsAction
    #initial_from_file_timestep = LATEST # LATEST [note the ICs block must not appear, or would overrride this]
    scaling = 1E-08
  []
[]


[AuxVariables]
  [darcy_vel_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [darcy_vel_y]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [darcy_vel_x_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = x
    variable = darcy_vel_x
    fluid_phase = 0                             # OPTIONAL for single-phase
    execute_on = TIMESTEP_END
  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = darcy_vel_y
    fluid_phase = 0                             # OPTIONAL for single-phase
    execute_on = TIMESTEP_END
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 5e3
  nl_abs_tol = 1e-10
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
  []
[]

[VectorPostprocessors]
  [line]
    type = ElementValueSampler
    sort_by = x
    variable = temperature
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  perf_graph = true
  exodus = true
  execute_on = 'initial timestep_end failed'
[]
