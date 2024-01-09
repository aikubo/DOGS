
[Mesh]
  [gen1]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 2
    ny = 10
    nz = 5
    ymin = 0 #m
    ymax = 2000 #m
    xmin = 0 
    xmax = 10 #m
    zmin = 0
    zmax= 100
    boundary_name_prefix = "dike"
  []
  [gen2]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 20
    nz = 5
    ymin = 0 #m
    ymax = 2000 #m
    xmin = 0
    xmax = 1000 #m
    zmin = 0
    zmax= 100
    boundary_name_prefix = "host"
  []
  [smg]
    type = StitchedMeshGenerator
    inputs = 'gen1 gen2'
    clear_stitched_boundary_ids = true
    stitch_boundaries_pairs = 'dike_right host_left'
  []
  [dike]
    type = SubdomainBoundingBoxGenerator
    input = smg
    top_right = '10 2000 100'
    bottom_left = '0 0 0'
    block_id = 1
  []    
  [rename]
    type = RenameBlockGenerator
    input = dike
    old_block = '0 1'
    new_block = 'wallrock dike'
  []
  final_generator = rename
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
  []
  [h]
    scaling = 1e-6
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
  [dikefunc]
    type = ParsedFunction
    expression = "if(t>a, 1173, 100)"
    a = 3000 # replace with the desired value of t
  []
[]


[ICs]
  [ppic]
    type = FunctionIC
    variable = pliquid
    function = ppfunc
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
    type = PorousFlowFluidPropertyFunctionIC
    porepressure = pliquid
    property = enthalpy
    fp = wat
    variable = h
    temperature = 500
    function = dikefunc
    temperature_unit = Kelvin
    block = 'dike'
  []
[]

[BCs]
  [ptop]
    type = FunctionDirichletBC
    variable = pliquid
    function = ppfunc
    boundary = top
  []
  [pbot]
    type = FunctionDirichletBC
    variable = pliquid
    function = ppfunc
    boundary = bottom
  []
  [hleft]
    type = DirichletBC
    variable = h
    porepressure = pliquid
    fp = wat
    function = dikefunc
    boundary = right
  []
  [hright]
    type = FunctionTempEnthalpyBC
    variable = h
    porepressure = pliquid
    fp = wat
    function = tfunc
    boundary = right
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
  [dike_heat]
    type = PorousFlowEnergyTimeDerivative
    variable = h
    block = 'dike'
  []
  [dike_cond]
    type = PorousFlowHeatConduction
    variable = h
    block = 'dike'
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
  [porosity_dike]
    type = PorousFlowPorosityConst
    porosity = 0.00
    block = 'dike'
  []
  [permeability_dike]
    type = PorousFlowPermeabilityConst
    permeability = '0 0 0 0 0 0 0 0 0'
    block = 'dike'
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
