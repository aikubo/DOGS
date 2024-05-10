# simple 1 phase convection model with a dike
# works fine but velocity field is a bit weird at times 
# seems like it "draws" water from the top boundary down to base
# the water is well mixed outside the plume associated with the dike 
# due to this draw down
# this is due to the BC at the top boundary which implies an "infinite well"

# added porousflowpiecewiselinearsink to the top boundary to simulate a more realistic top boundary condition
# actually seems like it runs faster

# eventually getting -pressures 
# using NodalMaxValueId to track the minimum pressure
# first make nodal var (family = LAGRANGE, order = FIRST)
# then parsedaux to multiply by -1
# then nodalmaxvalueid to track the minimum value ID
# in paraview top right near render view to split view 
# click spreadsheet view 
# click row and it highlights the block look for Point ID

# min T is at 420 first then at 1.68e7s 404
# min pressure always 420 

# 420: 100 0 (head of plume)
# 404 : 500 -100  (outside plume on top of domain)
# looks like BC does not allow for escape of hot water
# the top is at low T and P 
# zooming in the front of hot water reaches top boundary and is pushed down
# it's a BC issue at the top 

# tried decreasing flux from 1 to 1e-5 and 1e-10
# does not converge well at 1e-10 but fine at 1e-5

# trying adding a heat bc at top

# noticed that I forgot to delete the dirichlet bc on top 
# and scaling was bad 
# got rid of nl_res_tol too 

#convergence is less fast now but we'res seeing different 
# points for the min pressure and min temperature
# min T 585, 480, 421 // min P 440

# 440 is top right corner
# linear solve is having more problems less of the out of range but 
# it still occurs sometimes
# could increase l_max_its to 1000
# slightly better with right BC
# linear solve is decreasing just not very fast
# timesteps are much smaller than before

# now the plume can hit the top and exit :D
# more physical now

# looked at paraview and some weird stuff is happening
# plume looks good an normal but at ~1.17e6 it spreads out a lot 
# to the whole domain 
# this is not due to the BC dike shutting off
# might be edge effects?
# increasing size of domain seems to help convergence some 
# increased x and lowered the depth of the dike 

# tried porousflowsink heat BC and it didn't help much 
# went back to dirichlet BC for top temperature and it's better
# still getting out of range temperatures soemtimes but it just cuts the step and continues

# heat capacity was 0, increased to 750, heat conductivity was 1, increased to 4
# and decreased permeability to 1.21e-12 and now it does not converge at ALL
# increased permeability to 1.21e-10 and it's now goes to 1.7e7

# added aux variable hydrostat to track what the pressure should be across the domain 
# pipe this into porousflowsink to get better BCS 
#
# tried simple fluid properties and works much better
# looked at convergence criteria  and did the scaling analysis 
# Rfluid ~ V*10e-12
# Rthermal ~ V*10
# applied inverscaling so R~1 and now the convergence is fast! only a few seconds for the whole model
# it might also be faster because i reduced how many times it writes to Exodus 

# upped the temperature to 500 and it's now not converging 
# getting rid of scaling doesn't work 
# change damping to account for scaling!! don't forget to change the values
# not sure why this helps because I think scaling should apply automatically to BCs and ICs etc
# but it does help maybe just because I increased max value 
# at k=1e-15 it's mostly conduction dominated
# maybe timestep was too big since I got rid of dtmax 

# at 500 K, k = 1e-13 (converges fine) 
# nice convection cell develops but heat still looks mostly conduction dominated




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
  
  [Variables]
    [porepressure] 
      scaling = 1e12
    []
    [T]
      scaling = 1e1
    []
  []

  [Dampers]
    #change to account for scaling
    [./dampPressure]
      type = BoundingValueNodalDamper
      variable = porepressure
      min_value = 1e4
      max_value = 1e20
    []
    [./dampTemperature]
      type = BoundingValueNodalDamper
      variable = T
      min_value = 274
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
      function = ppfunc
    []
    [initial_temperature]
      type = FunctionIC
      function = geothermGrad
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
      type = SimpleFluidProperties
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
      specific_heat_capacity = 790
    []
    [thermal_conductivity]
      type = PorousFlowThermalConductivityIdeal
      dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4'
    []
  []
  
  [Functions]
    [dike_temp]
      type = ParsedFunction
      expression = '500'    
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
        flux_function = 1e-5
        use_mobility = true 
        use_relperm = true
        fluid_phase = 0
    []
    # [T_like_dirichlet]
    #   type = PorousFlowPiecewiseLinearSink
    #   variable = T
    #   boundary = 'bottom right'
    #   pt_vals = '1e-9 1e9'
    #   multipliers = '1e-9 1e9'
    #   PT_shift = geotherm
    #   flux_function = 1e-10
    #   use_mobility = true 
    #   use_relperm = true
    #   fluid_phase = 0
    # []
    # [T_top]
    #   type = PorousFlowOutflowBC
    #   variable = T
    #   boundary = 'top'
    #   flux_type = heat
    # []
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
    dtmin = 100
    steady_state_detection = true 
    steady_state_tolerance = 1e-12
    dtmax = 1e7
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
