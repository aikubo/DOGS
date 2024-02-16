# enthalpy set to 700000 in dike and 1.4e8 Pressures cause pressure out of bounds error
# tried turning off kernals in dike and get -inf pressure
# tried removing neumann bc around dike 
# tried making porosity and perm the same as in the wall rock 
# reduced enthalpy to 100000 and first timestep runs 
# then Segmentation fault (core dumped)
# trying dbg
# i think it is related to mesh adaptivity 
# i get this error 
# Time Step 2, time = 15, dt = 10
# We caught a libMesh error in ThreadedElementLoopBase:Assertion `comp < this->n_comp(s,var)' failed.
# comp = 0
# this->n_comp(s,var) = 0


# Stack frames: 16
# 0: libMesh::print_trace(std::ostream&)
# 1: libMesh::MacroFunctions::report_error(char const*, int, char const*, char const*, std::ostream&)
# 2: /home/akh/myprojects/moose_projects/moose/framework/libmoose-dbg.so.0(+0xe41e63) [0x7ffff1641e63]
# 3: UpdateErrorVectorsThread::onElement(libMesh::Elem const*)
# 4: ThreadedElementLoopBase<libMesh::StoredRange<libMesh::MeshBase::const_element_iterator, libMesh::Elem const*> >::operator()(libMesh::StoredRange<libMesh::MeshBase::const_element_iterator, libMesh::Elem const*> const&, bool)
# 5: /home/akh/myprojects/moose_projects/moose/framework/libmoose-dbg.so.0(+0x1f42069) [0x7ffff2742069]
# 6: Adaptivity::updateErrorVectors()
# 7: FEProblemBase::computeMarkers()
# 8: Transient::endStep(double)
# 9: Transient::execute()
# 10: MooseApp::executeExecutioner()
# 11: MooseApp::run()
# 12: main
# 13: /lib/x86_64-linux-gnu/libc.so.6(+0x29d90) [0x7fffe5c29d90]
# 14: __libc_start_main
# 15: /home/akh/myprojects/moose_projects/dikes/dikes-dbg(+0x3079) [0x555555557079]
# [0] /home/akh/miniforge/envs/moose/libmesh/include/libmesh/dof_object.h, line 1031, compiled Feb 16 2024 at 12:14:35

# commented out adaptivity and it runs
# but enthalpy is low enough there is not gas saturation 
# maybe i need to increase it slowly 
# added ramp function 
# still get the same error but halfway through the ramp at 270 s 
# now it's diverging because nl solve doesn't converge (no pressure error)
# residual for H is 10e7 higher than for P


[Mesh]
  [mesh]
    type = CartesianMeshGenerator
    dim = 2
    ix = '15 30' 
    dx = '10 2000'
    iy = '19 1'
    dy = '1900 100' 
    subdomain_id = ' 0 1
                     2 1'
    
  []
  [rename]
    type = RenameBlockGenerator
    input = mesh
    old_block = '0 1 2'
    new_block = 'dike wallrock wallrock_top'
    
  []
  [sidesets1]
    type = SideSetsAroundSubdomainGenerator
    input = rename
    block = 'dike'
    normal = '0 1 0'
    new_boundary = 'dike_top'
  []
  [sidesets2]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets1
    block = 'dike'
    normal = '0 -1 0'
    new_boundary = 'dike_bottom'
  []
  [sidesets3]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets2
    block = 'dike'
    normal = '-1 0 0'
    new_boundary = 'dike_left'
  []
  [sidesets4]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets3
    block = 'dike'
    normal = '1 0 0'
    new_boundary = 'dike_right'
  []
  [sidesets5]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets4
    block = 'wallrock'
    normal = '0 1 0'
    new_boundary = 'host_top'
  []
  [sidesets6]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets5
    block = 'wallrock'
    normal = '0 -1 0'
    new_boundary = 'host_bottom'
  []
  [sidesets7]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets6
    block = 'wallrock'
    normal = '1 0 0'
    new_boundary = 'host_right'
  []
  [sidesets8]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets7
    block = 'wallrock'
    normal = '-1 0 0'
    new_boundary = 'host_left'
  []
  [sidesets9]
    type = SideSetsAroundSubdomainGenerator
    input = sidesets8
    block = 'wallrock_top'
    normal = '-1 0 0'
    new_boundary = 'host_top_left'
  []
  [rename2]
    type = RenameBlockGenerator
    input = sidesets9
    old_block = 'wallrock wallrock_top'
    new_block = 'wallrock wallrock'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = rename2
    primary_block = 'dike'
    paired_block = 'wallrock'
    new_boundary = 'interface'
  []
[]


  # [Adaptivity]
  #   marker = errorfrac # this specifies which marker from 'Markers' subsection to use
  #   steps = 2 # run adaptivity 2 times, recomputing solution, indicators, and markers each time
  
  #   # Use an indicator to compute an error-estimate for each element:
  #   [./Indicators]
  #     # create an indicator computing an error metric for the convected variable
  #     [./error]
  #       # arbitrary, use-chosen name
  #       type = GradientJumpIndicator
  #       variable = pliquid
  #       outputs = none
  #       block = 'wallrock'
  #     [../]
  #   [../]
  
  #   # Create a marker that determines which elements to refine/coarsen based on error estimates
  #   # from an indicator:
  #   [./Markers]
  #     [./errorfrac]
  #       # arbitrary, use-chosen name (must match 'marker=...' name above
  #       type = ErrorFractionMarker
  #       indicator = error # use the 'error' indicator specified above
  #       refine = 0.5 # split/refine elements in the upper half of the indicator error range
  #       coarsen = 0 # don't do any coarsening
  #       outputs = none
  #       block = 'wallrock'
  #     [../]
  #   [../]
  # []
  
  # [Dampers]
  #   [./limit]
  #     type = BoundingValueNodalDamper
  #     variable = pliquid
  #     max_value = 1e8
  #     min_value = 1e1
  #     min_damping = 0.00001
  #   [../]
  #   [./limit2]
  #       type = BoundingValueNodalDamper
  #       variable = h
  #       max_value = 1e6
  #       min_value = 1e2

  #   [../]
  # []

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
    [pc]
      type = PorousFlowCapillaryPressureConst
      pc = 0 #for testing
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
    [perm_aux]
        family = MONOMIAL
        order = CONSTANT
    []
    [poro_aux]
        family = MONOMIAL
        order = CONSTANT
    []
    [hleft]
        family = LAGRANGE
        order = FIRST
    []
    [ptop]
        family = LAGRANGE
        order = FIRST
    []
    [gas_sat]
        family = MONOMIAL
        order = CONSTANT  
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
  []
  
  [Variables]
    [pliquid]
      order = FIRST
      family = LAGRANGE
      scaling = 1e-4
    []
    [h]
      order = FIRST
      family = LAGRANGE
      scaling = 1e-5
    []
  []
  
  [Functions]
    [ppfunc]
      type = ParsedFunction
      expression = 1.0135e5+(2000-y)*9.81*1000 #hydrostatic gradientose   + atmospheric pressure in Pa
    []
    [tfunc]
      type = ParsedFunction
      expression = 273+10+(2000-y)*10/1000 # geothermal 10 C per kilometer in kelvin
    []
    [dikefunc]
      type = ParsedFunction
      expression ='(273+T)-T*exp(t/-100)' # temperature of dike on left boundary in K
      symbol_names = 'T'
      symbol_values = 200
    []
    [dikefunc2]
        type = ParsedFunction
        expression = 'if( (y<=1900),550000,4000)' # temperature of dike on left boundary in K for Y= 1000-1700 only
    []
    [permfunc]
        type = ParsedFunction
        expression = 10e-17 #'if(x>20,1e-11,1e-15)' # permeability in m^2
    []
    [porofunc2]
        type = ParsedFunction
        expression = 0.1
    []
    [porofunc]
        type = PiecewiseConstant
        axis = x
        xy_data = '20 0
                   100 0.1
                   1000 0.1'
        direction = RIGHT_INCLUSIVE
    []
    [edikefunc]
        type = ParsedFunction # enthalpy of dike on left boundary in J/kg
        expression = 'if(t < ramp_duration, max_value*t/ramp_duration+min_value, max_value+min_value)'
        symbol_names = 'ramp_duration max_value min_value'
        symbol_values = '500 100000 40000' 
    []

  []
  

  
  [ICs]
    [ppic]
      type = FunctionIC # pressure is hydrostatic
      variable = pliquid
      function = ppfunc
    []
    [tempic]
      type = FunctionIC # temperature is geothermal
      variable = temperature
      function = tfunc
    []
    [hic]
      type = PorousFlowFluidPropertyFunctionIC
      variable = h
      function = tfunc
      property = enthalpy
      temperature_unit = Kelvin
      porepressure = pliquid
      fp = water_tab
      # block = 'wallrock'

    []
    [perm_auxvar_IC]
        type = FunctionIC # permeability is a function of x or can be constant
        variable = perm_aux
        function = permfunc
    []
    [poro_auxvar_IC] # porosity is a function of x or can be constant
        type = FunctionIC
        variable = poro_aux
        function = porofunc2
    []
    # [dikeic]
    #     type = ConstantIC
    #     variable = h
    #     value = 100000
    #     block = 'dike'
    # []
  []
  
  [BCs]
    [pright]
      type = FunctionDirichletBC # pressure is hydrostatic in far field
      # assumes "infinite" well of fluid to draw from, ie the rest of the crust
      variable = pliquid
      function = ppfunc
      boundary = 'right'
    []
    [ptop]
        type = PorousFlowPiecewiseLinearSink
        # allow fluid to flow out or in of the top boundary
        # based on pliquid - Pe
        variable = pliquid
        boundary = 'top'
        pt_vals = '1e-9 1e9'
        multipliers = '1e-9 1e9'
        PT_shift = 1.0135e5
        flux_function = 1
        save_in = 'ptop'
        fluid_phase = 0
        use_mobility = true
        use_relperm = true
    []
    [ptop_gas]
        type = PorousFlowPiecewiseLinearSink
        # allow fluid to flow out or in of the top boundary
        # based on pliquid - Pe
        variable = pliquid
        boundary = 'top'
        pt_vals = '1e-9 1e9'
        multipliers = '1e-9 1e9'
        PT_shift = 1.0135e5
        flux_function = 1
        fluid_phase = 1
        use_mobility = true
        use_relperm = true
    []
    [pbot]
      type = PorousFlowPiecewiseLinearSink
      # allow fluid to flow out or in of the top boundary
      # based on pliquid - Pe
      variable = pliquid
      boundary = 'bottom'
      pt_vals = '1e-9 1e9'
      multipliers = '1e-9 1e9'
      PT_shift = 19721350
      flux_function = 1
      save_in = 'ptop'
      fluid_phase = 0
      use_mobility = true
      use_relperm = true
  []
  [pbot_gas]
      type = PorousFlowPiecewiseLinearSink
      # allow fluid to flow out or in of the top boundary
      # based on pliquid - Pe
      variable = pliquid
      boundary = 'bottom'
      pt_vals = '1e-9 1e9'
      multipliers = '1e-9 1e9'
      PT_shift = 19721350
      flux_function = 1
      fluid_phase = 1
      use_mobility = true
      use_relperm = true
  []
  [hright]
    type = GeothermalBC
    # custom function by aikubo
    # enthalpy is temperature and pressure dependent
    # far field temperature is constant 

    porepressure = pliquid
    fp = water_tab
    function = tfunc
    variable = h
    boundary = 'right top bottom'
    temperature_unit = Kelvin
    property = enthalpy
  []
  [pdike]
        type = NeumannBC
        # no liquid can flow out the left boundary because the dike is impermeable
        variable = pliquid
        boundary = 'dike_left '
        value = 0
  []
  [hdike]
    type = FunctionDirichletBC
    # enthalpy ramps up slowly
    variable = h
    boundary = 'dike_left'
    function = edikefunc
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

      temperature_min=274
      temperature_max=1000
      pressure_min=1e5
      pressure_max=1e8
      error_on_out_of_bounds = false


      save_file = true
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
        porosity = poro_aux
        block = 'wallrock'
      []
      [permeability_wallrock]
        type = PorousFlowPermeabilityTensorFromVar
        perm = perm_aux
        block = 'wallrock'
      []
      [porosity_dike]
        type = PorousFlowPorosityConst
        porosity = 0.1
        block = 'dike'
      []
      [permeability_dike]
        type = PorousFlowPermeabilityTensorFromVar
        perm = 1e-15
        block = 'dike'
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
    end_time = 5e6
    nl_abs_tol = 1e-7
    line_search = none
    nl_max_its = 25
    [TimeStepper]
      type = IterationAdaptiveDT
      dt = 5
    []
  []
  
  [Postprocessors]
    [max_gassat] #check boundary behaves as expected
        type = ElementExtremeValue
        variable = gas_sat
        execute_on = 'initial timestep_end'
    []
    [bcleft_pp] #check boundary behaves as expected
        type = SideAverageValue
        variable = pliquid
        boundary = 'left'
        execute_on = 'initial timestep_end'
    []
    [bcleft_h] #check boundary behaves as expected
        type = SideAverageValue
        variable = h
        boundary = 'left'
        execute_on = 'initial timestep_end'
    []
    [bcleft_t] #check boundary behaves as expected
        type = SideAverageValue
        variable = temperature
        boundary = 'left'
        execute_on = 'initial timestep_end'
    []
    [bcbottom_t] #check boundary behaves as expected
        type = SideAverageValue
        variable = temperature
        boundary = 'bottom'
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