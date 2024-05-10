# issues with convergence
# pressure becomes too high (Pliquid > 1e8 Pa)
# if i increase the temperature too much the 
# same thing occurs 
# temperature is only set at a max of 450 k which is only 190 C
# tried increasing number of nodes and similar issues persist
# pressure too high and sometimes -enthalpy 

# added functions and ICs for porosity and perm
# so there's less water near the hot boundary 

# working on scaling the problem correctly 
# without scaling 

# Time Step 1, time = 5, dt = 5
#     |residual|_2 of individual variables:
#                     pliquid: 23400.7
#                     h:       8163.02

# residuals are the same order now
# I notice that residuals for pliquid just increase instead of going down
# h residuals just stay the same 
# might be pliquid bcs or ics 
# increasing the number of nodes in the x direction did not help
# i thought it would help the BCs since they are supposed to be the "far field"
# tried adding PorousFlowOutflowBC to the top and bottom boundaries
# didn't help

# lowering temperature at the boundary DOES HELP 
# but that's not really what we want long term

# changed scaling of h again to 1 after looking at initial residuals 
# now the pressure looks better but h residual doesn't go down 
# it's definitely the BCs that are the issue
# pliquid residual gets down to 1e-7 but h is still about 1 and stays there
# adding porousflowoutflow bc to h variable on top and bottom 
# maybe heled residual does get lower to 0.05 but still stalls out 
# added flux_type = heat to the hbc and R ~ 0.02

# added TopResidualDebugOutput to outputs
# looks like many of the issues in h residual are on the right side of the domain 
# 4000-6000m where the nodes get bigger
# maybe remove the bias_x value? it's also usuall at y = 1100- 2000,
# so it's mostly the top right side
# initially the residuals are highest on the left side then moves 
# to top right side

# tried changing nl_abs_tol to 2.0e-2
# simulation goes about 5115 seconds then seems to stall
# H resuduals are still high on the right side of the domain ~ 1e
# visualization look a bit odd
# the first block next to the left boundary is heats up 
# but it doesn't look like others do 
# the streamlines all point away from the block
# adding bias_x back in to see if it helps see what is going on there
# adding bias_x back in increases residuals and it does not converge
# increasing y for fun

# decreasing domain helped a lot 
# decreasing nl_abs_tol to  1e-2 seems to work although 
# it seems really high to me

# seems to be working 
# runs to 2.7e5 seconds
# then errors with temperature, pressure, enthalpy
# 
# *** ERROR ***
# The following error occurred in the object "wat", of type "Water97FluidProperties".

# temperature_from_ph() not implemented for region 5

# maybe a different enthalpy type function would be better
# it is a constant Temp function but it's not constant enthalpy 

# runs for quite a while up to 2.629950e+05 seconds but then looks like 
# there are issues with the 'h' in subdomain(s) {''} at node 93: (x,y,z)=(6.0792482526339,     1300,        0)
# right at the boundary
# i get this error *** ERROR ***
# The following error occurred in the object "wat", of type "Water97FluidProperties".

# temperature_from_ph() not implemented for region 5
# added meshrefinement 
# didn't seem to help at all 
# reimplemented porosity function and it iterated 1 timestep
# getting negative pressures

#trying to just have dike as part of the boundary (ie not to the surface)
# sort of helps but still getting negative pressures
# [DBG][0] 7381567884.17652 'h' in subdomain(s) {''} at node 345: (x,y,z)=(3.03962412631695,     1200,        0)
#  0 Nonlinear |R| = 2.682659e+10
#       0 Linear |R| = 2.682659e+10
#       1 Linear |R| = 9.808807e-06
# Pressure -4.25213e+06 is out of range in wat: inRegionPH()
# Nonlinear solve did not converge due to DIVERGED_LINE_SEARCH iterations 0
# it's always at that node specifically

# I've also been getting out of range errors for pressure in region 5 
# region 5 is high T lowish P 
# it shouldn't actually even be in region 5 i think
# i think it's because pressure is too low at the left boundary 
# might also be because of my enthalpy bc when you call h_from_t_p
# in FunctionTempEnthalpyBC

# set a dirichlet bc for pressure on the left boundary
# "magmatic pressures" ?? of 5e6 Pa
# this helps with the two phase zone 
# but now i'm getting enthalpy out of bounds at 1e7 
# tried damping it with BoundingValueNodalDamper
# but it says the min_damping is -19.3
# which I think isn't even reasonable 
# so i turned that off 

# added porousflowpiecewise linear sink boundaries 
# i also turned off all damping which seems to help
# now i'm getting enthalpy out of range but it's only 41490
# so that's a lot better than 1e7
# okay so the problem is that for a specific temperature and pressure
# there are MULTIPLE ENTHALPY VALUES for BUT DIFFERENT GAS SATURATIONS 
# seems like i need a "vaporPressureBC" or IC

# added term to dikefunc for temperature to slowly ramp 
# from 273 to 500 K over 100 s
# this allows the simulation to run for a couple timesteps 
# but then it errors with negative pressures

# added damping for pressure and now I get enthalpy out of range
# so the convergence issues ocurr at t=75 s 
# which in the dikefunc is temperatures of 100 C 
# right at the phase change

# using DirichletBC for h at 250000 on the left 
# works great simulation converging well

# increased enthalpy bc to get to the right temps
# taking longer to converge but still works up 11 timesteps 
# so that's progress 


[Mesh]
    [mesh]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 30
        ny = 10
        bias_x = 1.1
        xmin = 0
        xmax = 2000 #units meters
        ymin = 1000
        ymax = 2000
    []
  []

  [Adaptivity]
    marker = errorfrac # this specifies which marker from 'Markers' subsection to use
    steps = 2 # run adaptivity 2 times, recomputing solution, indicators, and markers each time
  
    # Use an indicator to compute an error-estimate for each element:
    [./Indicators]
      # create an indicator computing an error metric for the convected variable
      [./error]
        # arbitrary, use-chosen name
        type = GradientJumpIndicator
        variable = pliquid
        outputs = none
      [../]
    [../]
  
    # Create a marker that determines which elements to refine/coarsen based on error estimates
    # from an indicator:
    [./Markers]
      [./errorfrac]
        # arbitrary, use-chosen name (must match 'marker=...' name above
        type = ErrorFractionMarker
        indicator = error # use the 'error' indicator specified above
        refine = 0.5 # split/refine elements in the upper half of the indicator error range
        coarsen = 0 # don't do any coarsening
        outputs = none
      [../]
    [../]
  []
  
  [Dampers]
    [./limit]
      type = BoundingValueNodalDamper
      variable = pliquid
      max_value = 1e8
      min_value = 1e1
      min_damping = 0.00001
    [../]
    # [./limit2]
    #     type = BoundingValueNodalDamper
    #     variable = h
    #     max_value = 1e6
    #     min_value = 1e2

    # [../]
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
    [pc]
      type = PorousFlowCapillaryPressureConst
      pc = 0 #for testing
    []
    [fs]
      type = PorousFlowWaterVapor
      water_fp = wat
      capillary_pressure = pc
    []
  []
  
  
  [AuxVariables]
    [temperature]
      order = CONSTANT
      family = MONOMIAL
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
        expression = 10e-10 #'if(x>20,1e-11,1e-15)' # permeability in m^2
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
        type = ParsedFunction
        expression = 100000 # enthalpy of dike on left boundary in J/kg
    []

  []
  

  
  [ICs]
    [ppic]
      type = FunctionIC # pressure is hydrostatic
      variable = pliquid
      function = ppfunc
    []
    [hic]
      type = PorousFlowFluidPropertyFunctionIC # custom function by aikubo
      porepressure = pliquid # enthalpy is temperature dependent
      property = enthalpy
      fp = wat
      variable = h
      function = tfunc
      temperature_unit = Kelvin
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
        boundary = 'top bottom'
        pt_vals = '1e-9 1e9'
        multipliers = '1e-9 1e9'
        PT_shift = 1e7
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
        boundary = 'top bottom'
        pt_vals = '1e-9 1e9'
        multipliers = '1e-9 1e9'
        PT_shift = 1e7
        flux_function = 1
        fluid_phase = 1
        use_mobility = true
        use_relperm = true
    []
    [pdike]
        type = NeumannBC
        # no liquid can flow out the left boundary because the dike is impermeable
        variable = pliquid
        boundary = 'left'
        value = 0
    []
    [hright]
        type = FunctionTempEnthalpyBC
        # custom function by aikubo
        # enthalpy is temperature and pressure dependent
        # far field temperature is constant 

        porepressure = pliquid
        fp = wat
        function = tfunc
        variable = h
        boundary = 'right top bottom'
        temperature_unit = Kelvin
    []
    [hleft]
        type = FunctionDirichletBC
        variable = h
        boundary = 'left'
        function = dikefunc2
    []
    # [hleft]
    #     type = FunctionTempEnthalpyBC
    #     # custom function by aikubo
    #     # enthalpy is temperature and pressure dependent
    #     # function of dike temperature over time

    #     porepressure = pliquid
    #     fp = wat
    #     function = dikefunc
    #     variable = h
    #     boundary = 'left'
    #     temperature_unit = Kelvin
    #     save_in = 'hleft'
    # []
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
    [wat]
      type = Water97FluidProperties    # IAPWS-IF97
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
      []
      [permeability_wallrock]
        type = PorousFlowPermeabilityTensorFromVar
        perm = perm_aux
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
    [bcleft_gassat] #check boundary behaves as expected
        type = SideAverageValue
        variable = gas_sat
        boundary = 'left'
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