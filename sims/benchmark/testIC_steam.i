# test IC for steam injection

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
      expression = 285+(-y)*10/1000+200*(1-(x/4000)) # geothermal 10 C per kilometer in kelvin
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
      temperature = 400
      property = enthalpy
      temperature_unit = Kelvin
      porepressure = pliquid
      fp = water97
    []

  []
  
  [BCs]
   [pbc]
    type = NeumannBC
    variable = pliquid
    value = 0
    boundary = 'left right bottom top'
   []
   [hbc]
    type = NeumannBC
    variable = h
    value = 0
    boundary = 'left right top bottom'
   []


  []
  
  [Kernels]
    [mass]
      type = PorousFlowMassTimeDerivative
      variable = pliquid
      
    []
    # [massflux]
    #   type = PorousFlowAdvectiveFlux
    #   variable = pliquid
       
    # []
    [heat]
      type = PorousFlowEnergyTimeDerivative
      variable = h
       
    []
    # [heatflux]
    #   type = PorousFlowHeatAdvection
    #   variable = h
       
    # []
    # [heatcond]
    #   type = PorousFlowHeatConduction
    #   variable = h 
    # []
  []
  
 
  [FluidProperties]
    [water97]
      type = Water97FluidProperties # IAPWS-IF97
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
        porosity = 0.2
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
    end_time = 5000
    # nl_abs_tol = 1.e-5
    line_search = none
    # automatic_scaling = true
    # compute_scaling_once=false

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