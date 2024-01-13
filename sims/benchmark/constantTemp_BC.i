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

[Mesh]
    [mesh]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 25
        ny = 10
        bias_x = 1.05
        xmin = 0
        xmax = 1000 #units meters
        ymin = 1000
        ymax = 2000
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
    [pressure_gas]
      type = PorousFlowPropertyAux
      variable = pgas
      property = pressure
      phase = 1
      execute_on = 'initial timestep_end'
       
    []
  []
  
  [Variables]
    [pliquid]
      order = FIRST
      family = LAGRANGE
       
    []
    [h]
      order = FIRST
      family = LAGRANGE
      scaling = 1
    []
  []
  
  [Functions]
    [ppfunc]
      type = ParsedFunction
      expression = 1.0135e5+(2000-y)*9.81*1000 #hydrostatic gradient  + atmospheric pressure in Pa
    []
    [tfunc]
      type = ParsedFunction
      expression = 273+10+(2000-y)*10/1000 # geothermal 10 C per kilometer in kelvin
    []
    [dikefunc]
      type = ParsedFunction
      expression = 600 # temperature of dike on left boundary in K
    []
    [permfunc]
        type = ParsedFunction
        expression = 1e-11 #-1e-13*exp(-x/50)+1e-13 # permeability in m^2
    []
    [porofunc_exp]
        type = ParsedFunction
        expression = 0.1 #-0.2*exp(-x/50)+0.2 # porosity
    []
    [porofunc]
        type = PiecewiseConstant
        axis = x
        xy_data = '20 0
                   100 0.1
                   1000 0.1'
        direction = RIGHT_INCLUSIVE
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
        function = porofunc
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
    [hright]
        type = FunctionTempEnthalpyBC
        # custom function by aikubo
        # enthalpy is temperature and pressure dependent
        # far field temperature is constant 

        porepressure = pliquid
        fp = wat
        function = tfunc
        variable = h
        boundary = 'right'
        temperature_unit = Kelvin
    []
    [ptop]
        type = PorousFlowOutflowBC
        # allow fluid to flow out of the top and bottom boundary
        variable = pliquid
        boundary = 'top bottom'
        flux_type = fluid
    []
    [hbc]
        type = PorousFlowOutflowBC
        # allow heat to flow out of the top and bottom boundary
        variable = h
        boundary = 'top bottom'
        flux_type = heat
    []
    [pdike]
        type = NeumannBC
        # no liquid can flow out the left boundary because the dike is impermeable
        variable = pliquid
        boundary = 'left'
        value = 0
    []
    [hleft]
        type = FunctionTempEnthalpyBC
        # custom function by aikubo
        # enthalpy is temperature and pressure dependent
        # function of dike temperature over time

        porepressure = pliquid
        fp = wat
        function = dikefunc
        variable = h
        boundary = 'left'
        temperature_unit = Kelvin
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
    nl_abs_tol = 7.0e-2
    line_search = none
    [TimeStepper]
      type = IterationAdaptiveDT
      dt = 5
    []
  []
  
  [Postprocessors]
    [hpost]
      type = ElementAverageValue
      variable = h
      execute_on = 'initial timestep_end'
    []
    [ppost]
      type = ElementAverageValue
      variable = pliquid
      execute_on = 'initial timestep_end'
    []
    [tpost]
      type = ElementAverageValue
      variable = temperature
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