
#porous flow in main app working
# lets add flow in this app

# units of heatflux are MT^-3
# units of FVNeumannBC are MT^-2
# so we need to multiply by the timestep to get the heatflux

# trying to speed up convergence
# 1. added off_diagonals_in_auto_scaling = true
# 2. added compute_scaling_once = false
# 3. added nl_abs_tol = 1e-5
# 4. INSFVMomentumAdvectionOutflowBC
# 5. Added SymmetryBC for T

timeUnit = 1 #s

# Fluid properties
mu = 100 #Pa S
rho_liquid = 3000  #kg/m^3
k_liquid = 1 #W/mK
cp_liquid = 1100 #J/kgK

# Solid properties
rho_solid = 3000 #kg/m^3
k_solid = 1.5 #W/mK
cp_solid = 1400 #J/kgK

# Phase change
L = 300000 #J/kg
T_solidus = 1170 #K
T_liquidus = 1438 #K
alpha_b = 1.2e-4 #K^-1
#bd=1.7

# Operating conditions
y_inlet = 1 #m/s
T_inlet = 1438 #K
p_outlet = 10 #Pa


# Numerical scheme
advected_interp_method = 'average'
velocity_interp_method = 'rc'


[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 15
    ny = 35
    xmin= 0
    xmax = 100
    ymin = 0
    ymax = 1000
  []
[]

[Adaptivity]
  max_h_level = 2
  marker = marker
  [Indicators]
    [indicator]
      type = GradientJumpIndicator
      variable = T_child
    []
  []
  [Markers]
    [marker]
      type = ErrorFractionMarker
      indicator = indicator
      refine = 0.8
    []
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
    initial_condition = '${fparse y_inlet*timeUnit}'
  []
  [pressure]
    type = INSFVPressureVariable
  []
  [T_child]
    type = INSFVEnergyVariable
    initial_condition = ${T_inlet}
  []
[]

[AuxVariables]
  [fl]
    type = MooseVariableFVReal
    initial_condition = 0.0
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
  [meltfraction]
    type = MooseVariableFVReal
  []
[]

[AuxKernels]
  [meltfraction]
    type = ParsedAux
    variable = meltfraction
    coupled_variables = 'T_child'
    constant_names = 'T_solidus T_liquidus bd'
    constant_expressions = '${T_solidus} ${T_liquidus} 1.7'
    expression = 'if(T_child > T_solidus, ((T_child - T_solidus)/(T_liquidus - T_solidus))^bd, 1)'
  []
  [fl]
    type = ParsedAux
    variable = fl
    coupled_variables = 'T_child meltfraction'
    constant_names = 'T_solius T_liquidus'
    constant_expressions = '${T_solidus} ${T_liquidus}'
    expression = 'if (T_child < T_liquidus, meltfraction, 1)'
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
    mu = '${fparse mu/timeUnit}'
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
  []
  [u_friction]
    type = PINSFVMomentumFriction
    variable = vel_x
    momentum_component = 'x'
    u = vel_x
    v = vel_y
    Darcy_name = 'Darcy_coeff'
    Forchheimer_name = 'Forchheimer_coeff'
    rho = ${rho_liquid}
    mu = ${mu}
    standard_friction_formulation = false
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
    mu = '${fparse mu/timeUnit}'
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
  []
  [v_friction]
    type = PINSFVMomentumFriction
    variable = vel_y
    momentum_component = 'y'
    u = vel_x
    v = vel_y
    Darcy_name = 'Darcy_coeff'
    Forchheimer_name = 'Forchheimer_coeff'
    rho = ${rho_liquid}
    mu = ${mu}
    standard_friction_formulation = false
  []
  [v_gravity]
    type = INSFVMomentumGravity
    variable = vel_y
    gravity = '0 -9.81 0'
    rho = '${rho_liquid}'
    momentum_component = 'y'
  []
  [v_buoyancy]
    type = INSFVMomentumBoussinesq
    variable = vel_y
    T_fluid = T_child
    gravity = '0 -9.81 0'
    rho = '${rho_liquid}'
    ref_temperature = ${T_solidus}
    momentum_component = 'y'
  []
  [T_time]
    type = INSFVEnergyTimeDerivative
    variable = T_child
    rho = rho_mixture
    dh_dt = dh_dt
  []
  [energy_advection]
    type = INSFVEnergyAdvection
    variable = T_child
    velocity_interp_method = ${velocity_interp_method}
    advected_interp_method = ${advected_interp_method}
  []
  [energy_diffusion]
    type = FVDiffusion
    coeff = 'k_mixture'
    variable = T_child
  []
  [energy_source]
    type = NSFVPhaseChangeSource
    variable = T_child
    L = ${L}
    liquid_fraction = fl
    T_liquidus = ${T_liquidus}
    T_solidus = ${T_solidus}
    rho = 'rho_mixture'
  []
[]

[Functions]
  [qxdy]
    type = ParsedFunction
    symbol_names = 'qmax'
    symbol_values = '-5000'
    expression = 'qmax/sqrt(y)*sqrt(1000)'
  []
[]

[FVBCs]
  [inlet-u]
  type = INSFVInletVelocityBC
  boundary = 'bottom'
  variable = vel_x
  functor = '0'
  []
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = vel_y
    functor = 1
  []
  [inlet-T]
    type = FVNeumannBC
    variable = T_child
    value = '${fparse y_inlet * timeUnit * rho_liquid * cp_liquid * T_inlet}'
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
    mu = '${fparse mu/timeUnit}'
    momentum_component = 'x'
  []
  [symmetry-v]
    type = INSFVSymmetryVelocityBC
    boundary = 'left'
    variable = vel_y
    u = vel_x
    v = vel_y
    mu = '${fparse mu/timeUnit}'
    momentum_component = 'y'
  []
  [symmetry-p]
    type = INSFVSymmetryPressureBC
    boundary = 'left'
    variable = pressure
  []
  [sym_T]
    type = INSFVSymmetryScalarBC
    variable = T_child
    boundary = 'left'
  []
  [outlet_p]
    type = INSFVOutletPressureBC
    boundary = 'top'
    variable = pressure
    function = '${p_outlet}'
  []
  [cooling_side_low]
    type = FVFunctorNeumannBC
    variable = T_child
    boundary = 'right'
    functor = 'qxdy'
  []
[]

[FunctorMaterials]
  [ins_fv]
    type = INSFVEnthalpyFunctorMaterial
    rho = rho_mixture
    cp = cp_mixture
    temperature = 'T_child'
  []
  [eff_cp]
    type = NSFVMixtureMaterial
    phase_2_names = '${cp_solid} ${k_solid} ${rho_solid}'
    phase_1_names = '${cp_liquid} ${k_liquid} ${rho_liquid}'
    prop_names = 'cp_mixture k_mixture rho_mixture'
    phase_1_fraction = fl
  []
  [mushy_zone_resistance]
    type = INSFVMushyPorousFrictionMaterial
    liquid_fraction = 'fl'
    mu = '${fparse mu/timeUnit}'
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
  end_time = 1e6
  automatic_scaling = true
  line_search = 'none'
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -sub_pc_factor_shift_type -ksp_gmres_restart'
  petsc_options_value = ' lu       NONZERO                   200'
  nl_abs_tol = 1e-5
  off_diagonals_in_auto_scaling = true #helps with convergence
  compute_scaling_once = false #helps with convergence
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1
  []
[]

[Postprocessors]
  [t_avg_interface]
    type = SideAverageValue
    variable = T_child
    boundary = 'right'
  []
  [t_avg]
    type = ElementAverageValue
    variable = T_child
  []
  [u_avg]
    type = ElementAverageValue
    variable = vel_x
  []
  [v_avg]
    type = ElementAverageValue
    variable = vel_y
  []
  [density_avg]
    type = ElementAverageValue
    variable = density
  []
  [meltfraction_avg]
    type = ElementAverageValue
    variable = meltfraction
  []
[]



[Outputs]
  csv = true
  exodus = true
[]

[Debug]
  show_var_residual_norms = true
[]
