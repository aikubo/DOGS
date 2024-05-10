# not converging 
# increased x nodes and the residual in x did decrease
# increased ymax and it didn't change much 

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

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 10
    ymin = 0
    ymax = 500
    nx = 10
    ny = 30
  []
  uniform_refine = 0
[]

[Variables]
  [vel_x]
    type = INSFVVelocityVariable
    initial_condition = 0
  []
  [vel_y]
    type = INSFVVelocityVariable
    initial_condition = 5
  []
  [pressure]
    type = INSFVPressureVariable
  []
[]

[AuxVariables]
  [rho_m]
    type = MooseVariableFVReal
  []
  [mu_m]
    type = MooseVariableFVReal
  []
[]

[AuxKernels]
  [rho_m]
    type = FunctorAux
    variable = rho_m
    functor = density
  []
  [mu_m]
    type = FunctorAux
    variable = mu_m
    functor = viscosity
  []
[]

[FunctorMaterials]
  [props]
    type = GenericFunctorMaterial
    prop_names = 'density viscosity'
    prop_values = '1000 10e-3'
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    rho = rho_m
  []

  # [u_time]
  #   type = INSFVMomentumTimeDerivative
  #   variable = vel_x
  #   rho = rho_m
  #   momentum_component = 'x'
  # []
  [u_advection]
    type = INSFVMomentumAdvection
    variable = vel_x
    rho = rho_m
    momentum_component = 'x'
  []
  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_x
    mu = mu_m
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = vel_x
    momentum_component = 'x'
    pressure = pressure
  []

  # [v_time]
  #   type = INSFVMomentumTimeDerivative
  #   variable = vel_y
  #   rho = rho_m
  #   momentum_component = 'y'
  # []
  [v_advection]
    type = INSFVMomentumAdvection
    variable = vel_y
    rho = rho_m
    momentum_component = 'y'
  []
  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = vel_y
    mu = mu_m
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = vel_y
    momentum_component = 'y'
    pressure = pressure
  []
[]

[FVBCs]
  [inlet-v]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = vel_y
    functor = 1
  []
  [inlet-u]
    type = INSFVInletVelocityBC
    boundary = 'bottom'
    variable = vel_x
    functor = 0
  []
  [walls-u]
    type = INSFVNoSlipWallBC
    boundary = 'right left'
    variable = vel_x
    function = 0
  []
  [walls-v]
    type = INSFVNoSlipWallBC
    boundary = 'right left'
    variable = vel_y
    function = 0
  []
  [outlet-p]
    type = INSFVOutletPressureBC
    variable = pressure
    boundary = top
    function = 0
  []

[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  nl_rel_tol = 1e-12
  # [TimeStepper]
  #   type = IterationAdaptiveDT
  #   dt = 1e-3
  # []
[]

[Preconditioning]
  active = SMP
  [FSP]
    type = FSP
    # It is the starting point of splitting
    topsplit = 'up' # 'up' should match the following block name
    [up]
      splitting = 'u p' # 'u' and 'p' are the names of subsolvers
      splitting_type  = schur
      # Splitting type is set as schur, because the pressure part of Stokes-like systems
      # is not diagonally dominant. CAN NOT use additive, multiplicative and etc.
      #
      # Original system:
      #
      # | Auu Aup | | u | = | f_u |
      # | Apu 0   | | p |   | f_p |
      #
      # is factorized into
      #
      # |I             0 | | Auu  0|  | I  Auu^{-1}*Aup | | u | = | f_u |
      # |Apu*Auu^{-1}  I | | 0   -S|  | 0  I            | | p |   | f_p |
      #
      # where
      #
      # S = Apu*Auu^{-1}*Aup
      #
      # The preconditioning is accomplished via the following steps
      #
      # (1) p* = f_p - Apu*Auu^{-1}f_u,
      # (2) p = (-S)^{-1} p*
      # (3) u = Auu^{-1}(f_u-Aup*p)

      petsc_options_iname = '-pc_fieldsplit_schur_fact_type  -pc_fieldsplit_schur_precondition -ksp_gmres_restart -ksp_rtol -ksp_type'
      petsc_options_value = 'full                            selfp                             300                1e-4      fgmres'
    []
    [u]
      vars = 'vel_x vel_y'
      petsc_options_iname = '-pc_type -pc_hypre_type -ksp_type -ksp_rtol -ksp_gmres_restart -ksp_pc_side'
      petsc_options_value = 'hypre    boomeramg      gmres    5e-6      300                 right'
    []
    [p]
      vars = 'pressure'
      petsc_options_iname = '-ksp_type -ksp_gmres_restart -ksp_rtol -pc_type -ksp_pc_side'
      petsc_options_value = 'gmres    300                5e-6      jacobi    right'
    []
  []
  [SMP]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_shift_type'
    petsc_options_value = 'lu       NONZERO'
  []
[]

[Outputs]
  print_linear_residuals = true
  print_nonlinear_residuals = true
  
  [out]
    type = Exodus
  []
  [perf]
    type = PerfGraphOutput
  []
[]

[Debug]
  show_var_residual_norms = true
[]