Hello all (@cpgr especially) 

I am working on modeling the hydrothermal system of a dike intruded into granite. I've been struggling with convergence and pressure/temperature out of range issues for a while. I've prepared a simple example to demonstrate but the goal is to eventually 

1. heat source (dike) turns off after two years (6.3e7 s) 
2. use multiphase (pressure enthalpy formalation)
3. benchmark with USGS Hydrotherm [Code](https://volcanoes.usgs.gov/software/hydrotherm/)
4. custom heat capacity depending on temperature 
5. couple this to a Navier Stokes flow model multiapp of flow of magma in the dike

The problem is as follows: 
A dike intrudes into granite host rock at temperature of 500 C. It  is a constant temperature BC for 2 years then shuts off and cools (Neuman BC). 
The boundary at the dike is impermeable to flow (NeumanBC for porepressure). 
I've expanded the domain to include what I consider the "far field" so the right mosts boundaries 
should be uneffected by the dike heating. 

So far to deal with convergence issues I've tried the following 
1. Using `PorousFlowPiecewiseLinearSink` BCs instead of `DirichletBC` - This helped it run longer
2. Using `SimpleFluidProperties` instead of `Water97FluidProperties` - This helps the simulation runs to  completion but I'd like to use water properties in the long run especially for multiphase and benchmarking
3. Changing permeablitiy - Decreasing permeability to 1e-15 causes it to fail to converge after only a few timesteps
4. Trying different BCs such as `PorousFlowOutflowBC' didn't help. 
5. Adding dampers to pressure and temperature. This helps a bit but not in the long run since it will eventually cause convergence issues becuase I keep getting unphysical pr. 

I believe this is a boundary condition issue because when I get problems with pressure or temperature out of bounds (dampers off) it usually occurs on the top right corner or left corner. 


```
[Mesh]
    [gen]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 20
      ny = 20
      xmin = 0
      xmax = 4000 # units are meters
      ymax = 0
      ymin = -2000 # units are meters
    []
    [dike]
      type = ParsedGenerateSideset
      input = gen
      combinatorial_geometry = 'y <= -400 & x = 0'
      new_sideset_name = dike
    []
    uniform_refine = 1
  []
  
  [Variables]
    [porepressure]
    []
    [T]
        scaling = 1e-5
    []
  []

  [Dampers]
    [./dampPressure]
      type = BoundingValueNodalDamper
      variable = porepressure
      min_value = 1e4 # units Pa
      max_value = 1e8 # units Pa
    []
    [./dampTemperature]
      type = BoundingValueNodalDamper
      variable = T
      min_value = 274 # units K 
      max_value = 1000
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
  
  [AuxKernels]
    [./PorousFlowActionBase_Darcy_x_Aux]
      type = PorousFlowDarcyVelocityComponent
      
      component = x
      execute_on = TIMESTEP_END
      
      variable = darcy_vel_x
    [../]
    [./PorousFlowActionBase_Darcy_y_Aux]
      type = PorousFlowDarcyVelocityComponent
      
      component = y
      execute_on = TIMESTEP_END
      
      variable = darcy_vel_y
    [../]
    [./PorousFlowActionBase_Darcy_z_Aux]
      type = PorousFlowDarcyVelocityComponent
      
      component = z
      execute_on = TIMESTEP_END
      
      variable = darcy_vel_z
    [../]
  []
  
  [AuxVariables]
    [./darcy_vel_x]
      type = MooseVariableConstMonomial
    [../]
    [./darcy_vel_y]
      type = MooseVariableConstMonomial
    [../]
    [./darcy_vel_z]
      type = MooseVariableConstMonomial
    [../]
  []
  
  [Kernels]
    # from porousflow/examples/naturalconvection.i
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
      permeability = '1.21E-10 0 0   0 1.21E-10 0   0 0 1.21E-10'
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
      expression = '400'    
    []
    [ppfunc]
      type = ParsedFunction
      expression = '1.0135e5-9.81*1000*y'
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
    [pright]
        type = FunctionDirichletBC
        variable = porepressure
        function = ppfunc
        boundary = 'right bottom top'
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
    end_time = 1.5e9  # 31536000= 1 year, 1.5e9 = 47.5 years
    dtmax = 1e6
    nl_max_its = 30
    l_max_its = 100
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
  
[Outputs]
    [Exodus]
        type = Exodus
        execute_on = 'final timestep_end FAILED'
    []
[]

[Debug]
    show_var_residual_norms = true
[]


```

