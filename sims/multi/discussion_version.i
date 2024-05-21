# try running multiphase with tabulated
# Time Step 1, time = 100, dt = 100
# Pre-SMO residual: 285312
#     |residual|_2 of individual variables:
#                     pliquid: 1198.99
#                     h:       6.05463
# [DBG][0] Max 1 residuals
# [DBG][0] 472.267260219461 'pliquid' in subdomain(s) {''} at node 3: (x,y,z)=(       0,    -1910,        0)
#  0 Nonlinear |R| = 1.199000e+03
#   Linear solve did not converge due to DIVERGED_PC_FAILED iterations 0
#                  PC failed due to FACTOR_NUMERIC_ZEROPIVOT

# Pressure -inf is out of range in water97: inRegionPH()
# To recover, the solution will fail and then be re-attempted with a reduced time step.


# A MooseException was raised during FEProblemBase::computeResidualTags
# Pressure -inf is out of range in water97: inRegionPH()
# To recover, the solution will fail and then be re-attempted with a reduced time step.

# Nonlinear solve did not converge due to DIVERGED_LINE_SEARCH iterations 0
#  Solve Did NOT Converge!
# Aborting as solve did not converge

# DIVERGED_PC_FAILED seems to be a preconditioner issue
# so I tried SVD

# SVD: condition number 1.457333038283e+22, 21 of 882 singular values are (nearly) zero
# SVD: smallest singular values: 6.861849513694e-23 8.703331127211e-22 1.655271549669e-21 2.841766630568e-21 3.565774777398e-21
# SVD: largest singular values : 1.000000000002e+00 1.000000000002e+00 1.000000000002e+00 1.000000000003e+00 1.000000000003e+00
# lots of singular values are zero, so not good maybe needs more bCS
# took out block restriction and BCs to see if condition number and singular values decrease
# weird it doesn't :C it actually makes it WORSE

# added porousflowfluidIC to set initial conditions
# tried test water_vapor_phasechange and had issues probably with the code i added but don't want to
# bother with that now
# updated moose, clobberall and recompiled everything
# watervaporphasechange works now
# removed tabulated fluid and trying again
#
#  0 Nonlinear |R| = 1.612859e+04
# SVD: condition number 5.226987228889e+00, 0 of 2142 singular values are (nearly) zero
# SVD: smallest singular values: 2.115946565401e-01 2.115946565401e-01 2.290590336902e-01 2.290590336902e-01 2.508870920923e-01
# SVD: largest singular values : 1.101408056002e+00 1.103121834759e+00 1.104462369154e+00 1.105423971887e+00 1.106002567436e+00
# much better condition number and singular values

[Mesh]
    [gen]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 50
      ny = 20
      xmin = 0
      xmax = 1500
      ymax = 1500
      ymin = 0
    []
    # [dike]
    #   type = SubdomainBoundingBoxGenerator
    #   input = gen
    #   block_id = 1
    #   bottom_left = ' 0 0 0'
    #   top_right = ' 50 1200 0'
    # []
    # [rename]
    #   type = RenameBlockGenerator
    #   input = dike
    #   old_block = '0 1'
    #   new_block = 'host dike'
    # []
    # [SideSetsBetweenSubdomainsGenerator]
    #   type = SideSetsBetweenSubdomainsGenerator
    #   input = rename
    #   primary_block= 'host'
    #   paired_block = 'dike'
    #   new_boundary = 'host_edge'
    # []

  []

  # [Dampers]
  #   [./limit]
  #     type = BoundingValueNodalDamper
  #     variable = pliquid
  #     max_value = 1e9
  #     min_value = 1
  #   [../]
  #   [./limit2]
  #       type = BoundingValueNodalDamper
  #       variable = h
  #       max_value = 1e8
  #       min_value = 1e1

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
    [pc] #from porousflow/test/tests/fluidstate/watervapor.i
      type = PorousFlowCapillaryPressureBC
      pe = 1e5
      lambda = 2
      pc_max = 1e6
    []
    [fs]
      type = PorousFlowWaterVapor
      water_fp = water # you can't use tabulated fluids here!
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
      expression ='1.0135e5+(1500)*9.81*1000+(1500-y)*1000*9.81' #1.0135e5-(y)*9.81*1000' #hydrostatic gradientose   + atmospheric pressure in Pa
    []
    [tfunc]
      type = ParsedFunction
      expression = '300+(1500-y)*10/1000' #285+(-y)*10/1000 # geothermal 10 C per kilometer in kelvin
    []
  []



  [ICs]
    [ppic]
      type = FunctionIC # pressure is hydrostatic
      variable = pliquid
      function = ppfunc
    []
    [hic]
      type = PorousFlowFluidPropertyIC
      variable = h
      porepressure = pliquid
      property = enthalpy
      temperature = 300
      temperature_unit = Celsius
      fp = water
    []

  []

  [BCs]
    [noFlow_heat]
      type = NeumannBC
      variable = h
      boundary = 'top bottom right'
      value = 0
    []
    [noFlow]
      type = NeumannBC
      variable = pliquid
      boundary = 'top left bottom right'
      value = 0
    []
    [leftHeat]
      type = DirichletBC
      variable = h
      boundary = 'left'
      value = 4e6
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
    [water]
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
    active = mumps
    [mumps]
      type = SMP
      full = true
      petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
      petsc_options_value = ' lu       mumps'
    []
    [svd]
      type = SMP
      petsc_options = '-pc_svd_monitor'
      petsc_options_iname = '-pc_type'
      petsc_options_value = 'svd'
    []
  []

  [Executioner]
    type = Transient
    solve_type = NEWTON
    end_time = 3.0e9
    line_search = none
    dtmin = 100
    automatic_scaling = true
    [TimeStepper]
      type = IterationAdaptiveDT
      dt = 1000
    []
  []

  [Postprocessors]
   [max_gassat] #check boundary behaves as expected
        type = ElementExtremeValue
        variable = gas_sat
        execute_on = 'initial timestep_end'
    []
[]

  [Outputs]
    perf_graph = true
    exodus = true
    [residuals]
        type = TopResidualDebugOutput
        num_residuals = 1
        execute_on = 'NONLINEAR TIMESTEP_END INITIAL'
    []
  []

  [Debug]
    show_var_residual_norms = true
  []

