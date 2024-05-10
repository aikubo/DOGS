[Mesh]
[gen]
type = GeneratedMeshGenerator
dim = 2
xmin = -200000
xmax = 200000
ymin = -150000
ymax = 0
elem_type = TRI6
nx = 100
ny = 75
[]
[lcrust]
type = SubdomainBoundingBoxGenerator
input = 'gen'
block_id = 1
bottom_left = '-200000 -40000 0'
top_right = '200000 -20000 0'
[]
[ucrust]
type = SubdomainBoundingBoxGenerator
input = 'lcrust'
block_id = 2
bottom_left = '-200000 -20000 0'
top_right = '200000 -10000 0'
[]
[unsat]
type = SubdomainBoundingBoxGenerator
input = 'ucrust'
block_id = 3
bottom_left = '-200000 -10000 0'
top_right = '200000 0 0'
[]
[rename]
type = RenameBlockGenerator
input = 'unsat'
old_block = '0 1 2 3'
new_block = 'mantle lcrust ucrust unsat'
[]
[topnopore]
type = SideSetsBetweenSubdomainsGenerator
input = 'rename'
new_boundary = 'top_nopore'
primary_block = 'mantle'
paired_block = 'lcrust'
[]
[]

[GlobalParams]
PorousFlowDictator = dictator
gravity = '0 -9.81 0' # make global, so no need to add it to the userobject requiring it
[]

[UserObjects]
[dictator]
type = PorousFlowDictator
porous_flow_vars = 'porepressure temperature'
number_fluid_phases = 1
number_fluid_components = 1
[]
[pp_KT_advectiveflux_onecomp_userobj]
type = PorousFlowAdvectiveFluxCalculatorSaturated # [1-phase, 1-comp, fully saturated] one kernel for each fluid component
block = 'lcrust ucrust unsat' # OPTIONAL, list of blocks that this object will be applied to
flux_limiter_type = superbee
multiply_by_density = true # default. Implies the advective flux is multiplied by density, so it is a mass flux
[]
[heat_KT_advectiveflux_userobj]
type = PorousFlowAdvectiveFluxCalculatorSaturatedHeat
block = 'lcrust ucrust unsat'
flux_limiter_type = superbee
multiply_by_density = true # default. Implies the advective flux is multiplied by density, so it is a mass flux
[]
[]

[Variables]
[porepressure]
block = 'lcrust ucrust unsat' # blocks where this variable exists
family = LAGRANGE
order = SECOND
[]
[temperature] # [K] parsed initial condition in the ICs block below
block = 'lcrust ucrust unsat' # blocks where this variable exists
family = LAGRANGE
order = SECOND
scaling = 1E-08 # this variable scaling brings the residual R_T to the same order of magnitude that the Pressure residual R_P
[]
[temperature_mantle] # [K] parsed initial condition in the ICs block below
block = 'mantle' # blocks where this variable exists
family = LAGRANGE
order = SECOND
scaling = 1E-08 # this variable scaling brings the residual R_T to the same order of magnitude that the Pressure residual R_P
[]
[]

[Kernels] # as added by the action [PorousFlowFullySaturated]
[pp_time_derivative] # one kernel for each fluid component
type = PorousFlowMassTimeDerivative # these kernels lump the fluid-component mass to the nodes to ensure superior numerical stabilization
block = 'lcrust ucrust unsat'
variable = porepressure
[]
[pp_KT_advectiveflux_kernel]
type = PorousFlowFluxLimitedTVDAdvection # one kernel for each fluid component
block = 'lcrust ucrust unsat'
advective_flux_calculator = pp_KT_advectiveflux_onecomp_userobj # PorousFlowAdvectiveFluxCalculator UserObjectName
variable = porepressure
[]
[heat_time_derivative]
type = PorousFlowEnergyTimeDerivative # this kernel lumps the heat energy-density to the nodes to ensure superior numerical stabilization
block = 'lcrust ucrust unsat'
variable = temperature
# save_in = # name of auxiliary variable to save this Kernel residual contributions to.
[]
[heat_conduction]
type = PorousFlowHeatConduction
block = 'lcrust ucrust unsat'
variable = temperature
[]
[heat_KT_advectiveflux_kernel]
type = PorousFlowFluxLimitedTVDAdvection # one kernel for each fluid component
block = "lcrust ucrust unsat"
advective_flux_calculator = heat_KT_advectiveflux_userobj # PorousFlowAdvectiveFluxCalculator UserObjectName
variable = temperature
[]
[heat_time_derivative_mantle]
type = SpecificHeatConductionTimeDerivative
block = 'mantle'
variable = temperature_mantle
lumping = true
density = density_mantle
specific_heat = specific_heat_mantle
[]
[heat_conduction_mantle]
type = HeatConduction
block = 'mantle'
variable = temperature_mantle
diffusion_coefficient = thermal_conductivity_mantle
[]
[]

[ICs]
[porepressure_IC]
type = FunctionIC
block = "lcrust ucrust unsat"
variable = porepressure # [Pa]
function = '9.81*(-y)*1000'
[]
[temperature_IC]
type = FunctionIC
block = "lcrust ucrust unsat"
variable = temperature
function = '273.15+5+(-y)600/150000' # => 878.15 = 273.15+5+600 at the bottom [273.15+5+600/15000040000]
[]
[temperature_mantle_IC]
type = FunctionIC
block = "mantle"
variable = temperature_mantle
function = '273.15+5+(-y)600/150000' # => 878.15 = 273.15+5+600 at the bottom [273.15+5+600/15000040000]
[]
[]

[BCs]
[Ptop]
type = DirichletBC # this is a NodalBC
variable = porepressure
value = 101325.0 # [Pa] 1 atm
boundary = top
[]
[Ttop]
type = DirichletBC
variable = temperature
value = 278.15 #
boundary = top
[]
[Tbot]
type = DirichletBC
variable = temperature
value = 438.15 # matching grad_T_y = 600/150000
boundary = top_nopore
[]
[Ttop_mantle]
type = DirichletBC
variable = temperature_mantle
value = 438.15 # matching grad_T_y = 600/150000
boundary = top_nopore
[]
[Tbot_mantle]
type = DirichletBC
variable = temperature_mantle
value = 878.15 # matching grad_T_y = 600/150000
boundary = bottom
[]
[]

[Modules]
[FluidProperties]
[the_simple_fluid]
type = SimpleFluidProperties
bulk_modulus = 2E9
viscosity = 1.0E-3
density0 = 1000.0
[]
[]
[]

[Materials]
[materials_mantle]
type = GenericConstantMaterial
block = mantle
prop_names = 'thermal_conductivity_mantle specific_heat_mantle density_mantle'
prop_values = '3.3 1200.0 3360.0'
[]
[porosity_lcrust]
type = PorousFlowPorosity
block = lcrust
porosity_zero = 0.05
thermal = true
thermal_expansion_coeff = 3.66E-05
reference_temperature = 273.15
fluid = true
solid_bulk = 10.E09
biot_coefficient = 0.8
biot_coefficient_prime = 0.8
mechanical = false
[]
[porosity_ucrust]
type = PorousFlowPorosity
block = ucrust
porosity_zero = 0.05
thermal = true
thermal_expansion_coeff = 3.38E-05
reference_temperature = 273.15
fluid = true
solid_bulk = 10.E09
biot_coefficient = 0.8
biot_coefficient_prime = 0.8
mechanical = false
[]
[porosity_unsat]
type = PorousFlowPorosity
block = unsat
porosity_zero = 0.05
thermal = true
thermal_expansion_coeff = 3.38E-05
reference_temperature = 273.15
fluid = true
solid_bulk = 10.E09
biot_coefficient = 0.8
biot_coefficient_prime = 0.8
mechanical = false
[]
[permeability_lcrust]
type = PorousFlowPermeabilityKozenyCarman
block = lcrust
n = 3
m = 2
phi0 = 0.05
k0 = 9.0E-16
poroperm_function = 'kozeny_carman_phi0'
[]
[permeability_ucrust]
type = PorousFlowPermeabilityKozenyCarman
block = ucrust
n = 3
m = 2
phi0 = 0.05
k0 = 1.0E-15
poroperm_function = 'kozeny_carman_phi0'
[]
[permeability_unsat]
type = PorousFlowPermeabilityKozenyCarman
block = unsat
n = 3
m = 2
phi0 = 0.05
k0 = 1.0E-22
poroperm_function = 'kozeny_carman_phi0'
[]
[internal_energy_lcrust]
type = PorousFlowMatrixInternalEnergy
block = lcrust
density = 2850.0 # [kg.m-3] density of rock grains
specific_heat_capacity = 1200.0 # [J.kg-1.K-1] specific heat capacity of rock grains
[]
[internal_energy_ucrust]
type = PorousFlowMatrixInternalEnergy
density = 2700.0
specific_heat_capacity = 1200.0
[]
[internal_energy_unsat]
type = PorousFlowMatrixInternalEnergy
block = unsat
density = 2700.0
specific_heat_capacity = 1200.0
[]
[lambda_lcrust]
type = PorousFlowThermalConductivityFromPorosity
block = lcrust
lambda_f = '0.56 0 0 0 0.56 0 0 0 0.56'
lambda_s = '2.5 0 0 0 2.5 0 0 0 2.5'
[]
[lambda_ucrust]
type = PorousFlowThermalConductivityFromPorosity
block = ucrust
lambda_f = '0.56 0 0 0 0.56 0 0 0 0.56'
lambda_s = '2.3 0 0 0 2.3 0 0 0 2.3'
[]
[lambda_unsat]
type = PorousFlowThermalConductivityFromPorosity # rock-fluid combined thermal conductivity by weighted sum of rock and fluid conductivities
block = unsat
lambda_f = '0.56 0 0 0 0.56 0 0 0 0.56'
lambda_s = '2.3 0 0 0 2.3 0 0 0 2.3'
[]
[porepressure_material]
type = PorousFlow1PhaseFullySaturated # at_nodes=false by default
block = 'lcrust ucrust unsat'
porepressure = porepressure
[]
[temperature_material]
type = PorousFlowTemperature # at_nodes=false by default
block = 'lcrust ucrust unsat' # I think I would not need this here, as temperature exists in all blocks
temperature = temperature
[]
[massfrac]
type = PorousFlowMassFraction # at_nodes=false by default
block = 'lcrust ucrust unsat' # list of blocks where this object applies to
[]
[simple_fluid]
type = PorousFlowSingleComponentFluid # see documentation for this material regarding the choice of units
block = 'lcrust ucrust unsat'
fp = the_simple_fluid # this Material is at_nodes=false by default
phase = 0
[]
[effective_fluid_pressure] # create effective fluid pressure [is requested by PorousFlowPorosity even it has not mechanical coupling]
block = 'lcrust ucrust unsat'
type = PorousFlowEffectiveFluidPressure
[]
[nearest_qp]
type = PorousFlowNearestQp # atNodes=false by default
block = 'lcrust ucrust unsat' # should mantle be neglected here?
[]
[relperm] # required by PorousFlowDarcyVelocityComponent AuxKernels
type = PorousFlowRelativePermeabilityConst # atNodes=false by default
block = 'lcrust ucrust unsat' # ERROR when mantle not specified
phase = 0
kr = 1 # default, anyway
[]
[]

[Preconditioning]
active = smp_lu_mumps
[smp_lu_mumps]
type = SMP
full = true
petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
petsc_options_value = 'lu mumps'
[]
[]

[Executioner]
type = Transient
solve_type = Newton
end_time = 315576000000 # [s] 10000 year
#end_time = 1E6 # [s] ~[12 days]
dtmax = 3.2E10 # [s] ~1000 year. advanced parameter. Maximum timestep size in an adaptive run. Default to 1E30
nl_max_its = 25 # solver parameter. Max Nonlinear Iterations. Default to 50
l_max_its = 100 # solver parameter. Max Linear Iterations. Default to 10000
nl_abs_tol = 1E-06 # solver parameter. Nonlinear absolute tolerance. Default to 1E-50
nl_rel_tol = 1E-08 # solver parameter. Nonlinear Relative Tolerance. Default to 1E-08
scheme = 'implicit-euler' # the default TimeIntegrator
[TimeStepper] # TimeStepper subsystem [block always nested within the Executioner block]
type = IterationAdaptiveDT # adjust the timestep based on the number of iterations
optimal_iterations = 10 # target number of nonlinear iterations
dt = 1E5 # ~[27 h]
growth_factor = 2
cutback_factor = 0.5
[]
[]

[Outputs]
[ou]
type = Exodus
#output_material_properties = true
[]
[]
