

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
      max_value = 1e8
      min_value = 1e1
    [../]
    [./limit2]
        type = BoundingValueNodalDamper
        variable = h
        max_value = 1e6
        min_value = 1e2

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
      water_fp = water_tab
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
  []

  [Variables]
    [pliquid]
      order = FIRST
      family = LAGRANGE
      scaling = 1e1
    []
    [h]
      order = FIRST
      family = LAGRANGE
    []
  []

  [Functions]
    [dike_temp]
        type = ParsedFunction
        expression = '500000*(1-exp(-t/5000))+40000'
      []
    [ppfunc]
      type = ParsedFunction
      expression = 1.0135e5-(y)*9.81*1000 #hydrostatic gradientose   + atmospheric pressure in Pa
    []
    [tfunc]
      type = ParsedFunction
      expression = 285+(-y)*10/1000 # geothermal 10 C per kilometer in kelvin
    []
  []



  [ICs]
    [t_ic]
      type = FunctionIC
      variable = geotherm
      function = tfunc
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
      fp = water97 #_tab
    []

  []

  [BCs]
    [t_dike_dirichlet]
        type = FunctionDirichletBC
        variable = h
        function = dike_temp
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
      type = Water97FluidProperties    # IAPWS-IF97
    []
    [water_tab]
      type = TabulatedBicubicFluidProperties
      fp = water97
      fluid_properties_file = 'water_extended.csv'
      error_on_out_of_bounds = false
      p_h_variables = true
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
    [smp]
      type = SMP
      full = true
      petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
      petsc_options_value = ' lu       mumps'
    []
  []

  [Executioner]
    type = Transient
    solve_type = NEWTON
    end_time = 3.0e9
    line_search = none
    dtmin = 100
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

