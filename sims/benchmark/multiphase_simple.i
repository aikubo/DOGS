# using no error version of water97 
# with dampers this helps 
# but was not enough to prevent divergence around 1500s 
# does the thing where residuals get bigger and bigger 
# then just stop changing altogether

# added h linearsink at bottom boundary and it converges great 
# but max gas sat is always 0 
# so I think there is no phase change 
# now it still does that thing with the residuals but reaches 30 timesteps 

# h dirichlet at bottom boundary seems to actually work better 
# but still no phase change

# tried a new BC with conversion from temperature to enthalpy
# causes convergence problems immediately with 
# Nonlinear solve did not converge due to DIVERGED_DTOL iterations 1

# tried SVD to see if it's illposed or illconditioned
#  0 Nonlinear |R| = 3.988235e-01
#SVD: condition number 4.742842658608e+09, 0 of 882 singular values are (nearly) zero
#SVD: smallest singular values: 2.108440173922e-10 2.108443791899e-10 2.255229731185e-10 3.327428484887e-10 3.861923369304e-10
#SVD: largest singular values : 1.000000000000e+00 1.000000000000e+00 1.000000000000e+00 1.000000000000e+00 1.000000000000e+00
# no singular values are zero but condition number is high
# so it's illconditioned

# first automatic scaling
# added flag to recalculate scaling every timestep
# so that might help the thing I was observing where the residual of h is much larger than the residual of pliquid
# SVD: condition number 8.468878940198e+04, 0 of 882 singular values are (nearly) zero

# back to old preconditioner 
# 49 Nonlinear |R| = 9.490993e-06
#       0 Linear |R| = 9.490993e-06
#       1 Linear |R| = 3.557695e-20
#     |residual|_2 of individual variables:
#                     pliquid: 9.41424e-06
#                     h:       1.20551e-08
# [DBG][0] Max 1 residuals
# [DBG][0] 1.36895623394106e-06 'pliquid' in subdomain(s) {''} at node 232: (x,y,z)=(       0,    -1010,        0)
# 50 Nonlinear |R| = 9.414247e-06
# going to reduce nl convergence settings


[Mesh]
    [gen]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 20
      ny = 20
      xmin = 0
      xmax = 4000
      ymax = -200
      ymin = -2000
    []
    [dike]
      type = ParsedGenerateSideset
      input = gen
      combinatorial_geometry = 'y <= -400 & x = 0'
      new_sideset_name = dike
    []

  []
  
  [Dampers]
    [./limit]
      type = BoundingValueNodalDamper
      variable = pliquid
      max_value = 1e9
      min_value = -1e4
    [../]
    [./limit2]
        type = BoundingValueNodalDamper
        variable = h
        max_value = 1e8
        min_value = -1e4

    [../]
  []

  [GlobalParams]
    PorousFlowDictator = dictator
    gravity = '0 -9.81 0'
  []

  [UserObjects]
    [dictator]
      type = PorousFlowDictator
      porous_flow_vars = 'pliquid h'
      number_fluid_phases = 2
      number_fluid_components = 1
    []
    [pc] #from porousflow/test/tests/fluidstate/watervapor.i
      type = PorousFlowCapillaryPressureBC
      pe = 1e5
      lambda = 2
      pc_max = 1e6
    []
    [fs]
      type = PorousFlowWaterVapor
      water_fp = water97
      capillary_pressure = pc
    []
  []
  
  
  [AuxVariables]
    [temperature]
      family = MONOMIAL
      order = CONSTANT
    []
    [water_darcy_vel_x]
      family = MONOMIAL
      order = CONSTANT
    []
    [water_darcy_vel_y]
      family = MONOMIAL
      order = CONSTANT
    []
    [gas_darcy_vel_x]
      family = MONOMIAL
      order = CONSTANT
    []
    [gas_darcy_vel_y]
      family = MONOMIAL
      order = CONSTANT
    []
    [pgas]
      family = MONOMIAL
      order = CONSTANT
    []
    [gas_sat]
        family = MONOMIAL
        order = CONSTANT  
    []
    [hydrostat]
        family = MONOMIAL
        order = CONSTANT
    []
    [geotherm]
      order = FIRST
      family = LAGRANGE
    []
[]
  
  
  [AuxKernels]
    [temperature]
      type = PorousFlowPropertyAux
      variable = temperature
      property = temperature
      execute_on = 'initial timestep_end'  
    []
    [darcy_vel_x_kernel]
      type = PorousFlowDarcyVelocityComponent
      component = x
      variable = water_darcy_vel_x
      fluid_phase = 0                            
      execute_on = 'initial timestep_end'
       
    []
    [darcy_vel_y_kernel]
      type = PorousFlowDarcyVelocityComponent
      component = y
      variable = water_darcy_vel_y
      fluid_phase = 0                             
      execute_on = 'initial timestep_end'
    []
    [darcy_vel_x_kernel_gas]
      type = PorousFlowDarcyVelocityComponent
      component = x
      variable =gas_darcy_vel_x
      fluid_phase = 1                            
      execute_on = 'initial timestep_end'
       
    []
    [darcy_vel_y_kernel_gas]
      type = PorousFlowDarcyVelocityComponent
      component = y
      variable = gas_darcy_vel_y
      fluid_phase = 1                             
      execute_on = 'initial timestep_end'
       
    []
    [pressure_gas]
      type = PorousFlowPropertyAux
      variable = pgas
      property = pressure
      phase = 1
      execute_on = 'initial timestep_end'
    []
    [gas_sat]
        type = PorousFlowPropertyAux
        variable = gas_sat
        property = saturation
        phase = 1
        execute_on = 'initial timestep_end'
    []
    [hydrostat]
        type = FunctionAux
        function = ppfunc
        variable = hydrostat
    []
    [geotherm]
      type = FunctionAux
      variable = geotherm
      function = tfuncSteam
      execute_on = 'initial timestep_end'
    []
  []
  
  [Variables]
    [pliquid]
      order = FIRST
      family = LAGRANGE
      #scaling = 1e-3
    []
    [h]
      order = FIRST
      family = LAGRANGE
      #scaling = 1e-4

    []
  []
  
  [Functions]
    [dike_cooling]
        type = ParsedFunction
        expression = '520*(1-exp(-t/5000))+(285+(-y)*10/1000)'    
      []
    [ppfunc]
      type = ParsedFunction
      expression = 1.0135e5-(y)*9.81*1000 #hydrostatic gradientose   + atmospheric pressure in Pa
    []
    [tfunc]
      type = ParsedFunction
      expression = 285+(-y)*10/1000 # geothermal 10 C per kilometer in kelvin
    []
    [tfuncSteam]
      type = ParsedFunction
      expression = 285+(-y)*10/1000+120*(1-(x/4000)) # geothermal 10 C per kilometer in kelvin
    []
  []
  

  
  [ICs]
    [t_ic]
      type = FunctionIC
      variable = geotherm
      function = tfuncSteam
    []
    [ppic]
      type = FunctionIC # pressure is hydrostatic
      variable = pliquid
      function = ppfunc
    []
    [hic]
      type = PorousFlowFluidPropertyIC
      variable = h
      temperature = geotherm
      property = enthalpy
      temperature_unit = Kelvin
      porepressure = pliquid
      fp = water97
    []

  []
  
  [BCs]
    # [t_dike_dirichlet]
    #     type = FunctionDirichletBC
    #     variable = h
    #     function = dike_temp
    #     boundary = 'dike'
    # []

    [t_dike_dirichlet]
        type = TemperatureToEnthalpyConversionBC
        variable = h
        function = dike_cooling
        fp = water97
        property = enthalpy
        porepressure = pliquid
        temperature_unit = Kelvin
        boundary = 'dike'
    []
    [t_dike_neumann]
        type = NeumannBC
        variable = h
        boundary = 'dike'
        value = 0
    []

    [pp_like_dirichlet]
        type = PorousFlowPiecewiseLinearSink
        variable = pliquid
        boundary = 'top bottom right'
        pt_vals = '1e-9 1e9'
        multipliers = '1e-9 1e9'
        PT_shift = hydrostat
        flux_function = 1e-5
        use_mobility = true 
        use_relperm = true
        fluid_phase = 0
    []
    [ptop_gas]
        type = PorousFlowPiecewiseLinearSink
        # allow fluid to flow out or in of the top boundary
        # based on pliquid - Pe
        variable = pliquid
        boundary = 'top bottom right'
        pt_vals = '1e-9 1e9'
        multipliers = '1e-9 1e9'
        PT_shift = hydrostat
        flux_function = 1e-5
        fluid_phase = 1
        use_mobility = true
        use_relperm = true
    []
    [pdike]
      type = NeumannBC
      variable = pliquid
      boundary = 'dike'
      value = 0
    []
    [hbottom]
      type = DirichletBC
      variable = h
      value = 1.5e5
      boundary = 'bottom'
    []
  []
  
  [Kernels]
    [mass]
      type = PorousFlowMassTimeDerivative
      variable = pliquid
      
    []
    [massflux]
      type = PorousFlowAdvectiveFlux
      variable = pliquid
       
    []
    [heat]
      type = PorousFlowEnergyTimeDerivative
      variable = h
       
    []
    [heatflux]
      type = PorousFlowHeatAdvection
      variable = h
       
    []
    [heatcond]
      type = PorousFlowHeatConduction
      variable = h 
    []
  []
  
 
  [FluidProperties]
    [water97]
      type = Water97NoError    # IAPWS-IF97
      error_on_out_of_bounds = false
    []
  []
  
  [Materials]
      [watervapor]
        type = PorousFlowFluidStateSingleComponent
        porepressure = pliquid
        enthalpy = h
        capillary_pressure = pc
        fluid_state = fs
        temperature_unit = Kelvin
      []

      [porosity_wallrock]
        type = PorousFlowPorosityConst
        porosity = 0.1
      []
      [permeability]
        type = PorousFlowPermeabilityConst
        permeability = '1E-15 0 0   0 1E-15 0   0 0 1E-15'
      []
      [relperm_water] # from watervapor.i
        type = PorousFlowRelativePermeabilityCorey
        n = 2
        phase = 0
      []
      [relperm_gas]  # from watervapor.i
        type = PorousFlowRelativePermeabilityCorey
        n = 3
        phase = 1
      []
      [internal_energy] 
        type = PorousFlowMatrixInternalEnergy
        density = 2400 # kg/m^3
        specific_heat_capacity = 790 # J/kg/K
      []
      [rock_thermal_conductivity]
        type = PorousFlowThermalConductivityIdeal
        dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4' # W/m/K
      []  
  []
  
  [Preconditioning]
    active = smp
    [smp]
      type = SMP
      full = true
      # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
      # petsc_options_value = ' lu       mumps'
    []
  []
  
  [Executioner]
    type = Transient
    solve_type = NEWTON
    end_time = 3.0e9
    nl_abs_tol = 1.e-5
    line_search = none
    automatic_scaling = true
    compute_scaling_once=false

    # petsc_options = '-pc_svd_monitor'
    # petsc_options_iname = '-pc_type'
    # petsc_options_value = 'svd'


    [TimeStepper]
      type = IterationAdaptiveDT
      dt = 1000
    []
    [Adaptivity]
        interval = 1
        refine_fraction = 0.2
        coarsen_fraction = 0.3
        max_h_level = 4
      []
  []
  
  [Postprocessors]
   [max_gassat] #check boundary behaves as expected
        type = ElementExtremeValue
        variable = gas_sat
        execute_on = 'initial timestep_end'
    []
    [max_temp]
      type = ElementExtremeValue
      variable = temperature
      execute_on = 'initial timestep_end'
  []
[]

[Controls]
    [period0]
        type = TimePeriod
        disable_objects = 'BoundaryCondition::t_dike_neumann'
        enable_objects = 'BoundaryCondition::t_dike_dirichlet'
        start_time = '0'
        end_time = '63072000'
        execute_on = 'initial timestep_begin'
      []
    
      [period2]
        type = TimePeriod
        disable_objects = 'BoundaryCondition::t_dike_dirichlet'
        enable_objects = 'BoundaryCondition::t_dike_neumann'
        start_time = '63072000'
        end_time = '3e9'
        execute_on = 'initial timestep_begin'
      []
[]

  [Outputs]
    perf_graph = true
    exodus = true
    execute_on = 'initial timestep_end failed'
    [residuals]
        type = TopResidualDebugOutput
        num_residuals = 1
        execute_on = 'NONLINEAR TIMESTEP_END INITIAL'
    []
  []
  
  [Debug]
    show_var_residual_norms = true
  []