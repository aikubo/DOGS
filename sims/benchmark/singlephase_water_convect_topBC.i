# tried with water97 and it immediately crashes with k = 1e-15
# with k = 1e-10 it runs to steady state
# run and hot water accumulates at the top and then stays there
# seems unphysical so I tried running with OutflowBC
# fails quickly with OutflowBC
# without scaling 

# Time Step 1, time = 1000, dt = 1000
#     |residual|_2 of individual variables:
#                porepressure: 3913.07
#                T:            3.16493e+08


[Mesh]
    [gen]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 20
      ny = 20
      xmin = 0
      xmax = 4000
      ymax = 0
      ymin = -2000
    []
    [dike]
      type = ParsedGenerateSideset
      input = gen
      combinatorial_geometry = 'y <= -400 & x = 0'
      new_sideset_name = dike
    []

  []
  
  [Variables]
    [porepressure] 
      scaling = 1e12
      order = FIRST
      family = LAGRANGE
    []
    [T]
      scaling = 1e1
      order = FIRST
      family = LAGRANGE
    []
  []

  [Dampers]
    [./dampPressure]
      type = BoundingValueNodalDamper
      # change values due to scaling
      variable = porepressure
      min_value = 1e1
      max_value = 1e20
    []
    [./dampTemperature]
      type = BoundingValueNodalDamper
      variable = T
      min_value = 1e1
      max_value = 10000
    []
  []
  
  [AuxVariables]
    [water_darcy_vel_x]
      family = MONOMIAL
      order = CONSTANT
    []
    [water_darcy_vel_y]
      family = MONOMIAL
      order = CONSTANT
    []
    [hydrostat]
    []
    [geotherm]
    []  
  []
  
  [AuxKernels]
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
    [hydrostat]
      type = FunctionAux
      function = ppfunc
      variable = hydrostat
    []
    [geotherm]
      type = FunctionAux
      function = geothermGrad
      variable = geotherm
    []
  []
  
  [ICs]
    [hydrostatic]
      type = FunctionIC
      variable = porepressure
      function = '1e5 - 9.81 * 1000 * y'
    []
    [initial_temperature]
      type = FunctionIC
      function = 285-(y)*10/1000
      variable = T
    []
  []
  
  [GlobalParams]
    PorousFlowDictator = dictator
    gravity = '0 -9.81 0'
  []

  [UserObjects]
    [dictator]
      type = PorousFlowDictator
      porous_flow_vars = 'porepressure T'
      number_fluid_phases = 1
      number_fluid_components = 1
    []
  []
  
  [FluidProperties]
    [water]
      type = Water97FluidProperties
    []
  []
  
  
  [Kernels]
    [./PorousFlowUnsaturated_HeatConduction]
      type = PorousFlowHeatConduction
      
      variable = T
    [../]
    [./PorousFlowUnsaturated_EnergyTimeDerivative]
      type = PorousFlowEnergyTimeDerivative
      
      variable = T
    [../]
    [./PorousFlowFullySaturated_AdvectiveFlux0]
      type = PorousFlowFullySaturatedAdvectiveFlux
      
      
      variable = porepressure
    [../]
    [./PorousFlowFullySaturated_MassTimeDerivative0]
      type = PorousFlowMassTimeDerivative
      
      variable = porepressure
    [../]
    [./PorousFlowFullySaturatedUpwind_HeatAdvection]
      type = PorousFlowFullySaturatedUpwindHeatAdvection
      variable = T
    [../]
  []
  
  [Materials]
    [./PorousFlowActionBase_Temperature_qp]
      type = PorousFlowTemperature
      
      temperature = T
    [../]
    [./PorousFlowActionBase_Temperature]
      type = PorousFlowTemperature
      
      at_nodes = true
      temperature = T
    [../]
    [./PorousFlowActionBase_MassFraction_qp]
      type = PorousFlowMassFraction
      
    [../]
    [./PorousFlowActionBase_MassFraction]
      type = PorousFlowMassFraction
      
      at_nodes = true
    [../]
    [./PorousFlowActionBase_FluidProperties_qp]
      type = PorousFlowSingleComponentFluid
      
      compute_enthalpy = false
      compute_internal_energy = false
      fp = water
      phase = 0
    [../]
    [./PorousFlowActionBase_FluidProperties]
      type = PorousFlowSingleComponentFluid
      
      at_nodes = true
      fp = water
      phase = 0
    [../]
    [./PorousFlowUnsaturated_EffectiveFluidPressure_qp]
      type = PorousFlowEffectiveFluidPressure
      
    [../]
    [./PorousFlowUnsaturated_EffectiveFluidPressure]
      type = PorousFlowEffectiveFluidPressure
      
      at_nodes = true
    [../]
    [./PorousFlowFullySaturated_1PhaseP_qp]
      type = PorousFlow1PhaseFullySaturated
      
      porepressure = porepressure
    [../]
    [./PorousFlowFullySaturated_1PhaseP]
      type = PorousFlow1PhaseFullySaturated
      
      at_nodes = true
      porepressure = porepressure
    [../]
    [./PorousFlowActionBase_RelativePermeability_qp]
      type = PorousFlowRelativePermeabilityConst
      
      phase = 0
    [../]
    [porosity]
      type = PorousFlowPorosityConst
      porosity = 0.1
    []
    [permeability]
      type = PorousFlowPermeabilityConst
      permeability = '1E-10 0 0   0 1E-10 0   0 0 1E-10'
    []
    [Matrix_internal_energy]
      type = PorousFlowMatrixInternalEnergy
      density = 2400
      specific_heat_capacity = 750
    []
    [thermal_conductivity]
      type = PorousFlowThermalConductivityIdeal
      dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4'
    []
  []
  
  [Functions]
    [dike_temp]
      type = ParsedFunction
      expression = '800'    
    []
    [ppfunc]
      type = ParsedFunction
      expression = '1.0135e5-9.81*1000*y'
    []
    [geothermGrad]
      type = ParsedFunction
      expression = '285-(y)*10/1000'
    []
  []

  [BCs]
    [t_dike_dirichlet]
      type = FunctionDirichletBC
      variable = T
      function = dike_temp
      boundary = 'dike'
    []
    [t_dike_neumann]
      type = NeumannBC
      variable = T
      boundary = 'dike'
      value = 0
    []
    [pp_like_dirichlet]
        type = PorousFlowPiecewiseLinearSink
        variable = porepressure
        boundary = 'top bottom right'
        pt_vals = '1e-9 1e9'
        multipliers = '1e-9 1e9'
        PT_shift = hydrostat
        flux_function = 1e-10
        use_mobility = true 
        use_relperm = true
        fluid_phase = 0
    []
    [T_like_dirichlet]
      type = PorousFlowPiecewiseLinearSink
      variable = T
      boundary = 'bottom right'
      pt_vals = '1e-9 1e9'
      multipliers = '1e-9 1e9'
      PT_shift = geotherm
      flux_function = 1e-10
      use_mobility = true 
      use_relperm = true
      fluid_phase = 0
    []
    [T_top]
      type = PorousFlowOutflowBC
      variable = T
      boundary = 'top'
      flux_type = heat
    []
  []
  
  [Preconditioning]
    [mumps]
        type = SMP
        full = true
        petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
        petsc_options_value = ' lu       mumps'
      []
  []
  
  [Executioner]
    type = Transient
    end_time = 3.0e9  # 31536000= 1 year, 1.5e9 = 47.5 years
    dtmin = 10
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
        end_time = '1.5e9'
        execute_on = 'initial timestep_begin'
      []
[]

[Outputs]
    [Exodus]
        type = Exodus
        execute_on = 'final timestep_end FAILED'
        minimum_time_interval = 1e5
    []
[]

[Debug]
    show_var_residual_norms = true
[]
