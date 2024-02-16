# simple 1 phase convection model with a dike
# works fine but velocity field is a bit weird at times 
# seems like it "draws" water from the top boundary down to base
# the water is well mixed outside the plume associated with the dike 
# due to this draw down
# this is due to the BC at the top boundary which implies an "infinite well"

[Mesh]
    [gen]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 20
      ny = 20
      xmin = 0
      xmax = 2000
      ymax = 0
      ymin = -2000
    []
    [heater]
      type = ParsedGenerateSideset
      input = gen
      combinatorial_geometry = 'y <= -200 & x = 0'
      new_sideset_name = dike
    []
    uniform_refine = 1
  []
  
  [Variables]
    [porepressure]
    []
    [T]
    []
  []
  
  [AuxVariables]
    [density]
      family = MONOMIAL
      order = CONSTANT
    []
  []
  
  [AuxKernels]
    [density]
      type = PorousFlowPropertyAux
      variable = density
      property = density
      execute_on = TIMESTEP_END
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
      density = 2500
      specific_heat_capacity = 0
    []
    [thermal_conductivity]
      type = PorousFlowThermalConductivityIdeal
      dry_thermal_conductivity = '1.5 0 0  0 1.5 0  0 0 0'
    []
  []
  
  [BCs]
    [t_dike]
      type = DirichletBC
      variable = T
      value = 350
      boundary = 'dike'
    []
    [t_top]
      type = DirichletBC
      variable = T
      value = 285
      boundary = 'top'
    []
    [p_top]
      type = DirichletBC
      variable = porepressure
      value = 1e5
      boundary = top
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
    end_time = 63072000
    dtmax = 1e6
    nl_rel_tol = 1e-6
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
    exodus = true
  []
  
  # If you uncomment this it will print out all the kernels and materials that the PorousFlowFullySaturated action generates
  #[Problem]
  #  type = DumpObjectsProblem
  #  dump_path = PorousFlowFullySaturated
  #[]
  