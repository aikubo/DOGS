

[Mesh]
    [gen]
      type = GeneratedMeshGenerator
      dim = 2

    []
  []

  [GlobalParams]
    PorousFlowDictator = dictator
  []

  [AuxVariables]
    [pressure_gas]
      order = CONSTANT
      family = MONOMIAL
    []
    [pressure_water]
      order = CONSTANT
      family = MONOMIAL
    []
    [enthalpy_gas]
      order = CONSTANT
      family = MONOMIAL
    []
    [enthalpy_water]
      order = CONSTANT
      family = MONOMIAL
    []
    [saturation_gas]
      order = CONSTANT
      family = MONOMIAL
    []
    [saturation_water]
      order = CONSTANT
      family = MONOMIAL
    []
    [density_water]
      order = CONSTANT
      family = MONOMIAL
    []
    [density_gas]
      order = CONSTANT
      family = MONOMIAL
    []
    [viscosity_water]
      order = CONSTANT
      family = MONOMIAL
    []
    [viscosity_gas]
      order = CONSTANT
      family = MONOMIAL
    []
    # [temperature]
    #   order = CONSTANT
    #   family = MONOMIAL
    # []
  []

  [AuxKernels]
    [enthalpy_water]
      type = PorousFlowPropertyAux
      variable = enthalpy_water
      property = enthalpy
      phase = 0
      execute_on = 'initial timestep_end'
    []
    [enthalpy_gas]
      type = PorousFlowPropertyAux
      variable = enthalpy_gas
      property = enthalpy
      phase = 1
      execute_on = 'initial timestep_end'
    []
    [pressure_water]
      type = PorousFlowPropertyAux
      variable = pressure_water
      property = pressure
      phase = 0
      execute_on = 'initial timestep_end'
    []
    [pressure_gas]
      type = PorousFlowPropertyAux
      variable = pressure_gas
      property = pressure
      phase = 1
      execute_on = 'initial timestep_end'
    []
    [saturation_water]
      type = PorousFlowPropertyAux
      variable = saturation_water
      property = saturation
      phase = 0
      execute_on = 'initial timestep_end'
    []
    [saturation_gas]
      type = PorousFlowPropertyAux
      variable = saturation_gas
      property = saturation
      phase = 1
      execute_on = 'initial timestep_end'
    []
    [density_water]
      type = PorousFlowPropertyAux
      variable = density_water
      property = density
      phase = 0
      execute_on = 'initial timestep_end'
    []
    [density_gas]
      type = PorousFlowPropertyAux
      variable = density_gas
      property = density
      phase = 1
      execute_on = 'initial timestep_end'
    []
    [viscosity_water]
      type = PorousFlowPropertyAux
      variable = viscosity_water
      property = viscosity
      phase = 0
      execute_on = 'initial timestep_end'
    []
    [viscosity_gas]
      type = PorousFlowPropertyAux
      variable = viscosity_gas
      property = viscosity
      phase = 1
      execute_on = 'initial timestep_end'
    []
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
      water_fp = water_tab
      capillary_pressure = pc
    []
  []


  [Variables]
    [pliquid]
      initial_condition = 1e6
    []
    [h]
      initial_condition = 8e4
    []
  []


  [Kernels]
    [mass]
      type = PorousFlowMassTimeDerivative
      variable = pliquid
    []
    [heat]
      type = PorousFlowEnergyTimeDerivative
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
      fluid_property_file = 'water_extended.csv'
      p_h_variables = true
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
        permeability = '1E-13 0 0   0 1E-13 0   0 0 1E-13'
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
        density = 2500 # kg/m^3
        specific_heat_capacity = 1200 # J/kg/K
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
    end_time = 100
  []

