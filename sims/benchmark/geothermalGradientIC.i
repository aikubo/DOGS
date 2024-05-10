# set up geothermal gradient and porepresssure for simulation
# use "initial_from_file_var" in [Variable]
# to use this file as initial condition

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
[]
  
  [Variables]
    [porepressure]

    []
    [T]
        scaling = 1e-5

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
      function = temp_func
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
    [temp_func]
      type = ParsedFunction
      expression = '285-(y)*10/1000'
    []
    [ppfunc]
      type = ParsedFunction
      expression = '1.0135e5-9.81*1000*y'
    []
  []

  [BCs]
    [pp]
      type = FunctionDirichletBC
      variable = porepressure
      function = ppfunc
      boundary = 'top '
    []
    [temp]
      type = FunctionDirichletBC
      variable = T
      function = temp_func
      boundary = 'top '
    []
  []
  
  [Preconditioning]
    [basic]
      type = SMP
      full = true
      petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
      petsc_options_value = ' asm      lu           NONZERO                   2'
    []
  []
  
  [Executioner]
    type = Transient
    solve_type = 'NEWTON'
    end_time = 1.5e9  # 31536000= 1 year, 1.5e9 = 47.5 years
    nl_max_its = 30
    nl_abs_tol = 1e-12
    nl_rel_tol = 1e-6

    dtmin = 100
    steady_state_detection = true
    steady_state_tolerance = 1e-12

    [TimeStepper]
      type = IterationAdaptiveDT
      dt = 1000
      
    []
  []
  
[Outputs]
  execute_on = 'initial timestep_end'
  exodus = true
  perf_graph = true

[]