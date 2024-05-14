//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PorousFlowReynoldsNumber.h"

registerMooseObject("dikesApp", PorousFlowReynoldsNumber);


InputParameters
PorousFlowReynoldsNumber::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addClassDescription("Computes the PorousFlow Reynolds number: Re ~ rho*v*L/mu .");
  params.addRequiredParam<RealVectorValue>("gravity",
                                           "Gravitational acceleration vector downwards (m/s^2)");
  params.addRequiredParam<UserObjectName>(
      "PorousFlowDictator", "The UserObject that holds the list of PorousFlow variable names");
  params.addParam<unsigned int>("fluid_phase", 0, "The index corresponding to the fluid phase");
  MooseEnum component("x=0 y=1 z=2");
  params.addRequiredParam<MooseEnum>(
      "component", component, "The spatial component of the Darcy flux to return");
  return params;
}

PorousFlowReynoldsNumber::PorousFlowReynoldsNumber(const InputParameters & parameters)
  : AuxKernel(parameters),
    _relative_permeability(getGenericMaterialProperty<std::vector<Real>, false>(
        "PorousFlow_relative_permeability_qp")),
    _fluid_viscosity(
        getGenericMaterialProperty<std::vector<Real>, false>("PorousFlow_viscosity_qp")),
    _permeability(getGenericMaterialProperty<RealTensorValue, false>("PorousFlow_permeability_qp")),
    _grad_p(getGenericMaterialProperty<std::vector<RealGradient>, false>(
        "PorousFlow_grad_porepressure_qp")),
    _fluid_density_qp(
        getGenericMaterialProperty<std::vector<Real>, false>("PorousFlow_fluid_phase_density_qp")),
    _dictator(getUserObject<PorousFlowDictator>("PorousFlowDictator")),
    _ph(getParam<unsigned int>("fluid_phase")),
    _porosity(getGenericMaterialProperty<Real, false>("porosity"))
{
}

Real
PorousFlowReynoldsNumber::computeVelocity()
{
  return -MetaPhysicL::raw_value(
      (_permeability[_qp] * (_grad_p[_qp][_ph] - _fluid_density_qp[_qp][_ph] * _gravity) *
       _relative_permeability[_qp][_ph] / _fluid_viscosity[_qp][_ph]).norm());

}

Real
PorousFlowReynoldsNumber::computeValue()
{
  return computeVelocity() * MetaPhysicL::raw_value(_fluid_density_qp[_qp][_ph] * std::sqrt(_permeability[_qp].norm()*_relative_permeability[_qp][_ph])/ (_fluid_viscosity[_qp][_ph]*_porosity[_qp]));
}
