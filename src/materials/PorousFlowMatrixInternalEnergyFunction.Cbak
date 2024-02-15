#include "PorousFlowMatrixInternalEnergyFunction.h"
#include "Function.h"

registerMooseObject("dikesApp", PorousFlowMatrixInternalEnergyFunction);

InputParameters
PorousFlowMatrixInternalEnergyFunction::validParams()
{
  InputParameters params = PorousFlowMaterialVectorBase::validParams();
  params.addRequiredParam<FunctionName>("specific_heat_capacity function",
                                "Specific heat capacity of the rock grains (J/kg/K).");
  params.addRequiredParam<Real>("density", "Density of the rock grains");
  params.set<bool>("at_nodes") = true;
  params.addPrivateParam<std::string>("pf_material_type", "matrix_internal_energy");
  params.addClassDescription("This Material calculates the internal energy of solid rock grains, "
                             "which is specific_heat_capacity * density * temperature.  Kernels "
                             "multiply this by (1 - porosity) to find the energy density of the "
                             "porous rock in a rock-fluid system");
  return params;
}

PorousFlowMatrixInternalEnergyFunction::PorousFlowMatrixInternalEnergyFunction(const InputParameters & parameters)
  : PorousFlowMaterialVectorBase(parameters),
    _cp(getFunction("specific_heat_capacity")),
    _density(getParam<Real>("density")),
    _temperature_nodal(getMaterialProperty<Real>("PorousFlow_temperature_nodal")),
    _dtemperature_nodal_dvar(
        getMaterialProperty<std::vector<Real>>("dPorousFlow_temperature_nodal_dvar")),
    _en_nodal(declareProperty<Real>("PorousFlow_matrix_internal_energy_nodal")),
    _den_nodal_dvar(
        declareProperty<std::vector<Real>>("dPorousFlow_matrix_internal_energy_nodal_dvar"))
{
  if (_nodal_material != true)
    mooseError("PorousFlowMatrixInternalEnergyFunction classes are only defined for at_nodes = true");
}

void
PorousFlowMatrixInternalEnergyFunction::initQpStatefulProperties()
{
  _en_nodal[_qp] = _cp.value(_temperature_nodal[_qp], Point(0,0,0)) * _density * _temperature_nodal[_qp];
}

void
PorousFlowMatrixInternalEnergyFunction::computeQpProperties()
{
  _en_nodal[_qp] = _cp.value(_temperature_nodal[_qp], Point(0,0,0)) * _density * _temperature_nodal[_qp];

  _den_nodal_dvar[_qp].assign(_num_var, 0.0);
  for (unsigned v = 0; v < _num_var; ++v)
    _den_nodal_dvar[_qp][v] = _cp.value(_temperature_nodal[_qp], Point(0,0,0)) * _density * _dtemperature_nodal_dvar[_qp][v];
}