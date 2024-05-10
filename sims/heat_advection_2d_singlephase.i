# CHANGELOG
# - commit when it converges but log changes here

# Increased PP on right to 10, left 1
# Nonlinear residual gets down to 9e-9 but then fluctates
# heat advects much faster in only 2.5 "s"
# can reduce nl tol
# might be due to functionIC

# increased ymax and xmax
#changed functionIC to reflect size
# converges fine

# switched bcs and it does not look like it converges
# gets to 85 s, 16 timesteps
# kind of weird behavior
# PP starts off looking constant with a high on the right
# PP increases toward the left
# temperature diffuses toward middle then hits the high PP
# gets pushed back to the left

#changed function IC so it looks correct
# converging takes a while still
# stalls at around 5.19 s, timestep 10
# Nl residual around 6.5e-9
# reducing nl to 1e-8
# converged great then
# heat only comes >> 1m from starting point
# PP stays the same
# commit 8df2a69

# changed left to 0, right at 10 PP
# heat only changes a little
# worried that my tolerances are too HIGH
# again and it's not actually solving anything
# works if i change the PP so right is low and left is high
# that's a good sign
#
# trying left 0, right 10 porepressure
# commented out all the stuff in the executioner settings
# simulation gets to 2.5 s then diverges
# DIVERGED_LINE_SEARCH iterations 8
# fails at timestep 9
# looks basically the same
# added linesearh none and it still does that
# diverges
# nl gets to 2e-8 lr gets to 9-14

# Time Step 4, time = 7, dt = 1.19209e-07
#  0 Nonlinear |R| = 1.083285e-01
#       0 Linear |R| = 1.083285e-01
#       1 Linear |R| = 9.568398e-10
#  1 Nonlinear |R| = 2.538682e-04
#       0 Linear |R| = 2.538682e-04
#       1 Linear |R| = 8.794674e-12
#  2 Nonlinear |R| = 2.018859e-04
#
# adding automatic_scaling gets the residuals for both
# significantly lower


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
    function = 'x'
  []
[]

[BCs]
  [pp0]
    type = DirichletBC
    variable = pp
    boundary = left
    value = 0
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
  automatic_scaling = true
  # nl_max_its = 100           # solver parameter. Max Nonlinear Iterations. Default to 50
  # l_max_its = 100
  # end_time = 100
  # l_abs_tol = 1e-16
  # l_tol = 1e-13
  # nl_abs_tol = 5e-08      # solver parameter. Nonlinear absolute tolerance. Default to 1E-50
  # nl_rel_tol = 1E-7          # solver parameter. Nonlinear Relative Tolerance. Default to 1E-08
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
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
