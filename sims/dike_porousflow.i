
[Mesh]
  [mesh]
    type = CartesianMeshGenerator
    dim = 3
    ix = '5 10' 
    dx = '10 1000'
    iy = 20
    dy = 2000 
    iz = 5
    dz = 250
    subdomain_id = ' 0 1 '
    show_info = true
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = mesh
    primary_block = '1'
    paired_block = '0'
    new_boundary = 'interface'
    show_info = true
  []
  [rename]
    type = RenameBlockGenerator
    input = interface
    old_block = '0 1'
    new_block = 'dike wallrock'
    show_info = true
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
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 -9.81 0'
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
[]

[AuxKernels]
  [temperature]
    type = PorousFlowPropertyAux
    variable = temperature
    property = temperature
    execute_on = 'initial timestep_end'
    block = 'wallrock'
  []
  [darcy_vel_x_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = x
    variable = water_darcy_vel_x
    fluid_phase = 0                            
    execute_on = 'initial timestep_end'
    block = 'wallrock'
  []
  [darcy_vel_y_kernel]
    type = PorousFlowDarcyVelocityComponent
    component = y
    variable = water_darcy_vel_y
    fluid_phase = 0                             
    execute_on = 'initial timestep_end'
    block = 'wallrock'
  []
  [pressure_gas]
    type = PorousFlowPropertyAux
    variable = pgas
    property = pressure
    phase = 1
    execute_on = 'initial timestep_end'
    block = 'wallrock'
  []
[]

[Variables]
  [pliquid]
    order = SECOND
    family = LAGRANGE
    block = 'wallrock'
  []
  [h]
    order = SECOND
    family = LAGRANGE
    scaling = 1e-6
    block = 'wallrock'
  []
  [T_dike]
    order = CONSTANT
    family = MONOMIAL
    block = 'dike'
  []
[]

[Functions]
  [ppfunc]
    type = ParsedFunction
    expression = 1.0135e5+(2000-y)*9.81*1000 #hydrostatic gradient offset
  []
  [tfunc]
    type = ParsedFunction
    expression = 273+10+(2000-y)*20/1000 # geothermal 20 C per kilometer
  []
[]


[ICs]
  [ppic]
    type = FunctionIC
    variable = pliquid
    function = ppfunc
    block = 'wallrock'
  []
  [hic]
    type = PorousFlowFluidPropertyFunctionIC
    porepressure = pliquid
    property = enthalpy
    fp = wat
    variable = h
    temperature = 50
    function = tfunc
    temperature_unit = Kelvin
    block = 'wallrock'
  []
  [dike_hic]
    type = ConstantIC
    variable = T_dike
    value = 1173
    block = 'dike'
  []
[]

[BCs]
  [ptop]
    type = FunctionDirichletBC
    variable = pliquid
    function = ppfunc
    boundary = 'host_top host_right host_bottom'
  []
  [hright]
    type = EnthalpyTempVariableBC
    porepressure = pliquid
    h = h
    variable = h
    T_solid = T_dike
    boundary = 'interface'
    fp = wat
  []
  [hleft]
    type = NeumannBCm
    variable = T_dike
    value = 0
    boundary = 'dike_left dike_top dike_bottom'
  []

[]

[Kernels]
  [mass]
    type = PorousFlowMassTimeDerivative
    variable = pliquid
    block = 'wallrock'
  []
  [massflux]
    type = PorousFlowAdvectiveFlux
    variable = pliquid
    block = 'wallrock'
  []
  [heat]
    type = PorousFlowEnergyTimeDerivative
    variable = h
    block = 'wallrock'
  []
  [heatflux]
    type = PorousFlowHeatAdvection
    variable = h
    block = 'wallrock'
  []
  [heatcond]
    type = PorousFlowHeatConduction
    variable = h
    block = 'wallrock'
  []
  [dike_conduction]
    type = HeatConduction
    variable = T_dike
    block = 'dike'
  []
  [dike_time_derivative]
    type = HeatConductionTimeDerivative
    variable = T_dike
    block = 'dike'
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pliquid h'
    number_fluid_phases = 2
    number_fluid_components = 1
    block = 'wallrock'
  []
  [pc]
    type = PorousFlowCapillaryPressureVG
    pc_max = 1e6
    sat_lr = 0.1
    m = 0.5
    alpha = 1e-5
  []
  [fs]
    type = PorousFlowWaterVapor
    water_fp = wat
    capillary_pressure = pc
  []
[]

[FluidProperties]
  [wat]
    type = Water97FluidProperties    # IAPWS-IF97
  []
  [water]
    type = TabulatedBicubicFluidProperties
    fp = wat
    error_on_out_of_bounds = false
    #fluid_property_file = water_IAPWS95_kubo.csv
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
      block = 'wallrock'
    []
    [porosity_wallrock]
      type = PorousFlowPorosityConst
      porosity = 0.2
      block = 'wallrock'
    []
    [permeability_wallrock]
      type = PorousFlowPermeabilityConst
      permeability = '1.8e-11 0 0 0 1.8e-11 0 0 0 1.8e-11'
      block = 'wallrock'
    []
    [relperm_water]
      type = PorousFlowRelativePermeabilityCorey
      n = 2
      phase = 0
      s_res = 0.1
      sum_s_res = 0.1
    []
    [relperm_gas]
      type = PorousFlowRelativePermeabilityCorey
      n = 2
      phase = 1
      sum_s_res = 0.1
    []
    [internal_energy]
      type = PorousFlowMatrixInternalEnergy
      density = 2400
      specific_heat_capacity = 740
    []
    [rock_thermal_conductivity]
      type = PorousFlowThermalConductivityIdeal
      dry_thermal_conductivity = '4 0 0  0 4 0  0 0 4'
    []
    # dike materials
    [thermal]
      type = HeatConductionMaterial
      thermal_conductivity = 2.5 #W/mC
      specific_heat = 1100 #units: J/(kg*K)
    []
    [density]
      type = GenericConstantMaterial
      prop_names = 'density'
      prop_values = 2600 # units: kg/m^3
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
  end_time = 5e3
  nl_abs_tol = 1e-10
  line_search = none
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 5
  []
[]

[VectorPostprocessors]
  [line]
    type = ElementValueSampler
    sort_by = x
    variable = temperature
    execute_on = 'initial timestep_end'
  []
[]

[Outputs]
  perf_graph = true
  exodus = true
  execute_on = 'initial timestep_end failed'
[]
