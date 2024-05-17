# 2D transient flow in a rectangular channel with a solid wall
# slowling incrementing to dike conditions
# 1. increase domain
# 2. bottom inlet
# 3. increase mu and rho by 10x
# 4. increase to dike values
# works pretty well, converges but has to cut tstep occasionally
# 5. add melt fraction aux
# increase temp to 1200
# increasing the temp to 1200 causes the dv/dx velocity gradient to go to zero
# increase h_fs accordingly to get velocity drop at edges
# since it doesn't run for long and is very hot the T drop is very low > 1 deg
# but it's working :D
# 6. add buoyancy
# needs alpha_b functor material
# takes longer to converge and adds funky velocity field
# maybe due to pressure gradient + temp gradient
# taking out for now
# [v_buoyancy]
#   type = INSFVMomentumBoussinesq
#   variable = vel_y
#   T_fluid = T]
#   gravity = '0 -9.81 0'
#   rho = ''rho_mixture''
#   ref_temperature = ${T_cold}
#   momentum_component = 'y'
# []
# [v_gravity]
#   type = INSFVMomentumGravity
#   variable = vel_y
#   gravity = '0 -9.81 0'
#   rho = ''rho_mixture''
#   momentum_component = 'y'
# []
# 7. add phase change based on gallium solidification
# put dt as 0.2
# it runs!! but slowly
# might be time to move to hpc




# Fluid properties
mu = 100

# Operating conditions
y_inlet = 1
T_inlet = 1170
T_cold = 190
p_outlet = 10
h_fs = 10000
alpha_b = 1

# Phase change properties
L = 300000
T_liquidus = 1165
T_solidus = 1015

#Solid Properties
cp_solid = 1100
k_solid = 4
rho_solid = 2800

#Liquid Properties
cp_liquid = 1100
k_liquid = 4
rho_liquid = 3000

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
    rho = rho_mixture
  []
  [u_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_x
    rho = rho_mixture
    momentum_component = 'x'
  []
  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = rho_mixture
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
  [u_friction]
    type = INSFVMomentumFriction
    variable = vel_x
    momentum_component = 'x'
    linear_coef_name = 'Darcy_coefficient'
    quadratic_coef_name = 'Forchheimer_coefficient'
  []
  [u_buoyancy]
    type = INSFVMomentumBoussinesq
    variable = vel_x
    T_fluid = T
    gravity = '0 -9.81 0'
    rho = '${rho_liquid}'
    ref_temperature = ${T_cold}
    momentum_component = 'x'
  []
  [u_gravity]
    type = INSFVMomentumGravity
    variable = vel_x
    gravity = '0 -9.81 0'
    rho = '${rho_liquid}'
    momentum_component = 'x'
  []

  [v_time]
    type = INSFVMomentumTimeDerivative
    variable = vel_y
    rho = rho_mixture
    momentum_component = 'y'
  []
  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    advected_interp_method = ${advected_interp_method}
    velocity_interp_method = ${velocity_interp_method}
    rho = rho_mixture
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
  [v_friction]
    type = INSFVMomentumFriction
    variable = vel_y
    momentum_component = 'y'
    linear_coef_name = 'Darcy_coefficient'
    quadratic_coef_name = 'Forchheimer_coefficient'
  []
  [v_buoyancy]
    type = INSFVMomentumBoussinesq
    variable = vel_y
    T_fluid = T
    gravity = '0 -9.81 0'
    rho = '${rho_liquid}'
    ref_temperature = ${T_cold}
    momentum_component = 'y'
  []
  [v_gravity]
    type = INSFVMomentumGravity
    variable = vel_y
    gravity = '0 -9.81 0'
    rho = '${rho_liquid}'
    momentum_component = 'y'
  []

  [T_time]
    type = INSFVEnergyTimeDerivative
    variable = T
    rho = rho_mixture
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
    coeff = k_mixture
    variable = T
  []
  [energy_source]
    type = NSFVPhaseChangeSource
    variable = T
    L = ${L}
    liquid_fraction = 'meltFraction'
    T_liquidus = ${T_liquidus}
    T_solidus = ${T_solidus}
    rho = 'rho_mixture'
  []
  [energy_convection]
    type = PINSFVEnergyAmbientConvection
    variable = T
    is_solid = false
    T_fluid = 'T'
    T_solid = 'T_cold'
    h_solid_fluid = 'h_cv'
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
    value = '${fparse y_inlet * rho_liquid * cp_liquid * T_inlet}'
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
    rho = 'rho_mixture'
  []
  [outlet_v]
    type = INSFVMomentumAdvectionOutflowBC
    variable = vel_y
    u = vel_x
    v = vel_y
    boundary = 'top'
    momentum_component = 'y'
    rho = 'rho_mixture'
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'top'
    variable = pressure
    function = '${p_outlet}'
  []


[]

[AuxVariables]
  [meltFraction]
    type = MooseVariableFVReal
  []
  [U]
    type = MooseVariableFVReal
  []
  [density]
    type = MooseVariableFVReal
  []
  [th_cond]
    type = MooseVariableFVReal
  []
  [cp_var]
    type = MooseVariableFVReal
  []
  [darcy_coef]
    type = MooseVariableFVReal
  []
  [fch_coef]
    type = MooseVariableFVReal
  []
[]

[AuxKernels]
  [meltFraction]
    type = ParsedAux
    variable = meltFraction
    coupled_variables = T
    constant_names = 'Solidus Liquidus bd'
    constant_expressions = '1015 1165 1.7'
    expression = 'if(T < Solidus, 0, if(T > Liquidus, 1, ((T - Solidus) / (Liquidus - Solidus))^bd))'
  []
  [mag]
    type = VectorMagnitudeAux
    variable = U
    x = vel_x
    y = vel_y
  []
  [rho_out]
    type = FunctorAux
    functor = 'rho_mixture'
    variable = 'density'
  []
  [th_cond_out]
    type = FunctorAux
    functor = 'k_mixture'
    variable = 'th_cond'
  []
  [cp_out]
    type = FunctorAux
    functor = 'cp_mixture'
    variable = 'cp_var'
  []
  [darcy_out]
    type = FunctorAux
    functor = 'Darcy_coefficient'
    variable = 'darcy_coef'
  []
  [fch_out]
    type = FunctorAux
    functor = 'Forchheimer_coefficient'
    variable = 'fch_coef'
  []
[]



[FunctorMaterials]
  [constants]
    type = ADGenericFunctorMaterial
    prop_names = 'h_cv T_cold'
    prop_values = '${h_fs} ${T_cold}'
  []
  [ins_fv]
    type = INSFVEnthalpyMaterial
    rho = 'rho_mixture'
    cp = 'cp_mixture'
    temperature = 'T'
  []
  [eff_cp]
    type = NSFVMixtureFunctorMaterial
    phase_2_names = '${cp_solid} ${k_solid} ${rho_solid}'
    phase_1_names = '${cp_liquid} ${k_liquid} ${rho_liquid}'
    prop_names = 'cp_mixture k_mixture rho_mixture'
    phase_1_fraction = 'meltFraction'
  []
  [mushy_zone_resistance]
    type = INSFVMushyPorousFrictionFunctorMaterial
    liquid_fraction = 'meltFraction'
    mu = '${mu}'
    rho_l = '${rho_liquid}'
    dendrite_spacing_scaling = 1e-1
  []
  [const_functor]
    type = ADGenericFunctorMaterial
    prop_names = 'alpha_b'
    prop_values = '${alpha_b}'
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'
  line_search = 'none'
  end_time = 4
  dt = 0.02
[]

[Outputs]
  exodus = true
  csv = true
[]
