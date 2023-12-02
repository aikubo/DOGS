# Increased PP on right to 10, left 1
# Nonlinear residual gets down to 9e-9 but then fluctates
# heat advects much faster in only 2.5 "s"
# can reduce nl tol
# might be due to functionIC

# increased ymax and xmax
#changed functionIC to reflect size
# converges fine

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 50
  ny = 50
  xmax = 10
  ymax = 10
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [temp]
    initial_condition = 200
  []
  [pp]
  []
[]

[ICs]
  [pp]
    type = FunctionIC
    variable = pp
    function = 'x-10'
  []
[]

[BCs]
  [pp0]
    type = DirichletBC
    variable = pp
    boundary = left
    value = 1
  []
  [pp1]
    type = DirichletBC
    variable = pp
    boundary = right
    value = 10
  []
  [spit_heat]
    type = DirichletBC
    variable = temp
    boundary = left
    value = 300
  []
  [suck_heat]
    type = DirichletBC
    variable = temp
    boundary = right
    value = 200
  []
[]

[Kernels]
  [mass_dot]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pp
  []
  [advection]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = pp
  []
  [energy_dot]
    type = PorousFlowEnergyTimeDerivative
    variable = temp
  []
  [heat_advection]
    type = PorousFlowHeatAdvection
    variable = temp
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'temp pp'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
  [pc]
    type = PorousFlowCapillaryPressureVG
    m = 0.6
    alpha = 1.3
  []
[]

[FluidProperties]
  [simple_fluid]
    type = SimpleFluidProperties
    bulk_modulus = 100
    density0 = 1000
    viscosity = 4.4
    thermal_expansion = 0
    cv = 2
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
    temperature = temp
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.2
  []
  [rock_heat]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 1.0
    density = 125
  []
  [simple_fluid]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '1.1 0 0 0 2 0 0 0 3'
  []
  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 0
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
  [PS]
    type = PorousFlow1PhaseP
    porepressure = pp
    capillary_pressure = pc
  []
[]

[Preconditioning]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  nl_max_its = 100           # solver parameter. Max Nonlinear Iterations. Default to 50
  l_max_its = 100
  end_time = 100
  l_abs_tol = 1e-16
  l_tol = 1e-13
  nl_abs_tol = 1e-09       # solver parameter. Nonlinear absolute tolerance. Default to 1E-50
  nl_rel_tol = 1E-8          # solver parameter. Nonlinear Relative Tolerance. Default to 1E-08
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.01
  []
  line_search = none
[]

# [VectorPostprocessors]
#   [T]
#     type = LineValueSampler
#     start_point = '0 0 0'
#     end_point = '1 0 0'
#     num_points = 51
#     sort_by = x
#     variable = temp
#   []
# []

[Outputs]
  exodus = true
  print_linear_residuals = true
[]
