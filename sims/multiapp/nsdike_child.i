# simple test for nsdike
# 1. remove gravity, buoyancy, friction, and phase change
# works fine



# Fluid properties
mu = 10
rho = 300
k = 1
cp = 1 #1100

# Operating conditions
y_inlet = 1
T_inlet = 1170
T_cold = 190
p_outlet = 10
hs = 10


# Numerical scheme
advected_interp_method = 'average'
velocity_interp_method = 'rc'

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 5
    ymin = 0
    ymax = 10
    nx = 20
    ny = 50
  []
[]

[GlobalParams]
  rhie_chow_user_object = 'rc'
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = vel_x
    v = vel_y
    pressure = pressure
  []
[]

[Variables]
  [vel_x]
    type = INSFVVelocityVariable
    initial_condition = 1e-12
  []
  [vel_y]
    type = INSFVVelocityVariable
    initial_condition = ${y_inlet}
  []
  [pressure]
    type = INSFVPressureVariable
  []
  [T]
    type = INSFVEnergyVariable
    initial_condition = ${T_inlet}
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho}
  []
  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_x
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = ${mu}
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
  []


  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_y
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = ${mu}
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
  []

  [T_time]
    type = INSFVEnergyTimeDerivative
    variable = T
    rho = ${rho}
    dh_dt = dh_dt
  []
  [energy_advection]
    type = INSFVEnergyAdvection
    variable = T
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []
  [energy_diffusion]
    type = FVDiffusion
    coeff = ${k}
    variable = T
  []

[]

[FVBCs]
  [inlet-u]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = vel_x
    function = '0'
  []
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = vel_y
    function = 1
  []
  [inlet-T]
    type = FVNeumannBC
    variable = T
    value = '${fparse y_inlet * rho * cp * T_inlet}'
    boundary = 'bottom'
  []

  [no-slip-u]
    type = INSFVNoSlipWallBC
    boundary = 'right'
    variable = vel_x
    function = 0
  []
  [no-slip-v]
    type = INSFVNoSlipWallBC
    boundary = 'right'
    variable = vel_y
    function = 0
  []

  [symmetry-u]
    type = INSFVSymmetryVelocityBC
    boundary = 'left'
    variable = vel_x
    u = vel_x
    v = vel_y
    mu = ${mu}
    momentum_component = 'x'
  []
  [symmetry-v]
    type = INSFVSymmetryVelocityBC
    boundary = 'left'
    variable = vel_y
    u = vel_x
    v = vel_y
    mu = ${mu}
    momentum_component = 'y'
  []
  [symmetry-p]
    type = INSFVSymmetryPressureBC
    boundary = 'left'
    variable = pressure
  []

  [outlet_u]
    type = INSFVMomentumAdvectionOutflowBC
    variable = vel_x
    u = vel_x
    v = vel_y
    boundary = 'top'
    momentum_component = 'x'
    rho = ${rho}
  []
  [outlet_v]
    type = INSFVMomentumAdvectionOutflowBC
    variable = vel_y
    u = vel_x
    v = vel_y
    boundary = 'top'
    momentum_component = 'y'
    rho = ${rho}
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'top'
    variable = pressure
    function = '${p_outlet}'
  []

  [CoolingSideBC]
    type = FVFunctorNeumannBC
    variable = T
    functor = -100
    boundary = 'top right'
  []



[]

[AuxVariables]
  [U]
    type = MooseVariableFVReal
  []
  [Tfluid]
    type = MooseVariableFVReal
  []
  [h_parent]
  []
[]

[AuxKernels]
  [mag]
    type = VectorMagnitudeAux
    variable = U
    x = vel_x
    y = vel_y
  []
  [Tfluid]
    type = ParsedAux
    variable = Tfluid
    coupled_variables = 'T'
    expression = 'T'
  []

[]



[FunctorMaterials]
  [constants]
    type = ADGenericFunctorMaterial
    prop_names = 'h_cv T_cold'
    prop_values = '${hs} ${T_cold}'
  []
  [ins_fv]
    type = INSFVEnthalpyFunctorMaterial
    rho = ${rho}
    cp = ${cp}
    temperature = 'T'
  []

[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'
  line_search = 'none'
  end_time = 4
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.2
  []
[]

[Outputs]
  exodus = true
  csv = true
[]

[Postprocessors]
  [./h_avg]
    type = ElementAverageValue
    variable = h_parent
  []
[]
