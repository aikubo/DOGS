[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    ymin = 0
    ymax = 300
    xmax = 100
    ny = 100
    nx = 50
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '100 35 0'
    block_name = dike
    input = gen
  []
  [rename]
    type = RenameBlockGenerator
    input = dike
    old_block = '0 dike'
    new_block = 'host dike'
  []
  [contact_area]
    type = SideSetsBetweenSubdomainsGenerator
    input = rename
    primary_block = 'host'
    paired_block = 'dike'
    new_boundary = 'contact'
  []
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
    pc= 0
  []
  [fs]
    type = PorousFlowWaterVapor
    water_fp = simp
    capillary_pressure = pc
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
[]

[Variables]
  [pliquid]
  []
  [h]
  []
[]

[AuxVariables]
  [temperature]
    order = CONSTANT
    family = MONOMIAL
  []
  [psteam]
    order = CONSTANT
    family = MONOMIAL
  []
  [bounds_dummy]
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
  [pgas]
    type=PorousFlowPropertyAux
    variable = psteam
    property = pressure
    phase = 1
    execute_on = 'initial timestep_end'
  []

[]


[Kernels]
  [mass_water_dot]
    type = PorousFlowMassTimeDerivative
    variable = pliquid
  []
  [flux_water]
    type = PorousFlowAdvectiveFlux
    variable = pliquid
  []
  [eng_time]
    type=PorousFlowEnergyTimeDerivative
    variable = h
  []
  [h_advect]
    type=PorousFlowHeatAdvection
    variable = h
  []
  [h_cond]
    type=PorousFlowHeatConduction
    variable = h
  []
[]

[FluidProperties]
  [simp]
    type = SimpleFluidProperties
    bulk_modulus = 2E9
    viscosity = 1.0E-3
    density0 = 1000.0
  []
  [true_water]
    type = Water97FluidProperties    # IAPWS-IF97
  []
  # [tab_water]                # tabulation is the only way to make this effective
  #   type = TabulatedBicubicFluidProperties  # the range 273.15 K <= T <= 1073.15 K for p <= 100 MPa
  #   fp = true_water
  #   interpolated_properties = 'density enthalpy internal_energy viscosity k cp cv entropy'
  #
  #   temperature_max = 1000
  #   temperature_min = 274
  #
  #   fluid_property_file = simp_IAPWS95_kubo.csv
  #   # fluid_property_file = fluid_properties.csv
  #   save_file = true
  #   construct_pT_from_ve = true
  #   construct_pT_from_vh = true
  #   error_on_out_of_bounds = false
  #
  #   # Newton parameters
  #   tolerance = 1e-8
  # []
[]

[Bounds]
  [u_upper_bound]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = pliquid
    bound_type = upper
    bound_value = 100000000 #100 Mpa, 100*1000000
  []
  [u_lower_bound]
    type = ConstantBoundsAux
    variable = bounds_dummy
    bounded_variable = pliquid
    bound_type = lower
    bound_value = 1
  []
[]

[Materials]
  [watervapor]
    type = PorousFlowFluidStateSingleComponent
    porepressure = pliquid
    enthalpy = h
    temperature_unit = Celsius
    capillary_pressure = pc
    fluid_state = fs
  []
  [permeability1]
    type = PorousFlowPermeabilityConst
    permeability = '1e-13 0 0 0 1e-13 0 0 0 1e-13'
    block='host'
  []
  [permeability2]
    type = PorousFlowPermeabilityConst
    permeability = '1e-13 0 0 0 1e-13 0 0 0 1e-13' #'1e-19 0 0 0 1e-19 0 0 0 1e-19'
    block='dike'
  []
  [relperm0]
    type = PorousFlowRelativePermeabilityCorey
    n = 2
    phase = 0
  []
  [relperm1]
    type = PorousFlowRelativePermeabilityCorey
    n = 3
    phase = 1
  []
  [porosity]
    type = PorousFlowPorosityConst
    porosity = 0.1
  []
  [internal_energy]
    type = PorousFlowMatrixInternalEnergy
    density = 2500
    specific_heat_capacity = 1200
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '2.5 0 0  0 2.5 0  0 0 2.5'
  []
[]


[ICs]
  [hic]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliquid
    property = enthalpy
    temperature = 170
    temperature_unit = Celsius
    fp = simp
    block='host'
  []
  [hic_dike]
    type = PorousFlowFluidPropertyIC
    variable = h
    porepressure = pliquid
    property = enthalpy
    temperature = 200
    temperature_unit = Celsius
    fp = simp
    block = 'dike'
  []
  [gradient]
    type= FunctionIC
    variable = pliquid
    function = '9.81*(300-y)*2500+101325'
  []
[]


[BCs]
    [pleft]
      type = DirichletBC
      variable = pliquid
      value = 5.05e6
      boundary = bottom
    []
    [pright]
      type = DirichletBC
      variable = pliquid
      value = 5e6
      boundary = top
    []
    [hleft]
      type = DirichletBC
      variable = h
      value = 678.52e3
      boundary = top
    []
    [hright]
      type = DirichletBC
      variable = h
      value = 721.4e3
      boundary = bottom
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
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 1e9
  nl_max_its = 50
  l_max_its = 100
  dtmax = 5e5
  nl_abs_tol = 1.5E-08       # solver parameter. Nonlinear absolute tolerance. Default to 1E-50
  nl_rel_tol = 1E-9          # solver parameter. Nonlinear Relative Tolerance. Default to 1E-08
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 100
  []
  line_search = 'none'
  automatic_scaling = true
[]


[Outputs]
  print_linear_residuals = true
  perf_graph = true
  exodus = true
[]
