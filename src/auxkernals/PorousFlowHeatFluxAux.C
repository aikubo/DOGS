//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PorousFlowHeatFluxAux.h"

registerMooseObject("dikesApp", PorousFlowHeatFluxAux);
registerMooseObject("dikesApp", ADPorousFlowHeatFluxAux);

template <bool is_ad>
InputParameters
PorousFlowHeatFluxAuxTempl<is_ad>::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addRequiredParam<RealVectorValue>("gravity",
                                           "Gravitational acceleration vector downwards (m/s^2)");
  params.addRequiredParam<UserObjectName>(
      "PorousFlowDictator", "The UserObject that holds the list of PorousFlow variable names");
  params.addParam<unsigned int>("fluid_phase", 0, "The index corresponding to the fluid phase");
  MooseEnum component("x=0 y=1 z=2");

  params.addClassDescription(
      "Caluculates the heat flux in porous media using the Darcy velocity with units of W/m"
      "then multipy by -1, so it is the heat flux out of the porous media");
  return params;
}

template <bool is_ad>
PorousFlowHeatFluxAuxTempl<is_ad>::PorousFlowHeatFluxAuxTempl(const InputParameters & parameters)
  : AuxKernel(parameters),
    _relative_permeability(getGenericMaterialProperty<std::vector<Real>, is_ad>(
        "PorousFlow_relative_permeability_qp")),
    _fluid_viscosity(
        getGenericMaterialProperty<std::vector<Real>, is_ad>("PorousFlow_viscosity_qp")),
    _permeability(getGenericMaterialProperty<RealTensorValue, is_ad>("PorousFlow_permeability_qp")),
    _grad_p(getGenericMaterialProperty<std::vector<RealGradient>, is_ad>(
        "PorousFlow_grad_porepressure_qp")),
    _fluid_density_qp(
        getGenericMaterialProperty<std::vector<Real>, is_ad>("PorousFlow_fluid_phase_density_qp")),
    _enthalpy(
        getGenericMaterialProperty<std::vector<Real>, is_ad>("PorousFlow_fluid_phase_enthalpy_qp")),
    _grad_T(getMaterialProperty<RealGradient>("PorousFlow_grad_temperature_qp")),
    _conductivity(
        getGenericMaterialProperty<RealTensorValue, is_ad>("PorousFlow_thermal_conductivity_qp")),
    _dictator(getUserObject<PorousFlowDictator>("PorousFlowDictator")),
    _ph(getParam<unsigned int>("fluid_phase")),
    _gravity(getParam<RealVectorValue>("gravity"))
{
  if (_ph >= _dictator.numPhases())
    paramError("fluid_phase",
               "The Dictator proclaims that the maximum phase index in this simulation is ",
               _dictator.numPhases() - 1,
               " whereas you have used ",
               _ph,
               ". Remember that indexing starts at 0. The Dictator is watching you, to "
               "ensure your wellbeing.");
}
template <bool is_ad>
Real
PorousFlowHeatFluxAuxTempl<is_ad>::computeVelocity()
{
  libMesh::VectorValue<Real> velocity = -MetaPhysicL::raw_value(
      (_permeability[_qp] * (_grad_p[_qp][_ph] - _fluid_density_qp[_qp][_ph] * _gravity) *
       _relative_permeability[_qp][_ph] / _fluid_viscosity[_qp][_ph]));
  return velocity.norm();
}

template <bool is_ad>
Real
PorousFlowHeatFluxAuxTempl<is_ad>::computeValue()
{
  Real velocity_magnitude = computeVelocity();

  Real heat_flux_conductive = MetaPhysicL::raw_value(_conductivity[_qp] * _grad_T[_qp]).norm();
  Real heat_flux_advective =
      MetaPhysicL::raw_value(_enthalpy[_qp][_ph] * _fluid_density_qp[_qp][_ph]) *
      velocity_magnitude;

  return -1 * (-1 * heat_flux_conductive + heat_flux_advective);
}

template class PorousFlowHeatFluxAuxTempl<false>;
template class PorousFlowHeatFluxAuxTempl<true>;
