//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "EnthalpyTemperatureConversionAux.h"
#include "SinglePhaseFluidProperties.h"


registerMooseObject("dikesApp", EnthalpyTemperatureConversionAux);


InputParameters
EnthalpyTemperatureConversionAux::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addClassDescription("Converts from temperature to enthalpy.");
  params.addRequiredCoupledVar("property", "The variable");
  params.addRequiredCoupledVar("porepressure", "The porepressure variable");
  MooseEnum convert_to("temperature entalpy");
  params.addRequiredParam<MooseEnum>(
      "conversion_to", convert_to, "which variable to convert to");
  params.addRequiredParam<UserObjectName>("fp", "The name of the user object for the fluid");
  return params;
}

EnthalpyTemperatureConversionAux::EnthalpyTemperatureConversionAux(const InputParameters & parameters)
  : AuxKernel(parameters),
    _property(coupledValue("property")),
    _porepressure(coupledValue("porepressure")),
    _conversion_to(getParam<MooseEnum>("conversion_to").getEnum<PropertyEnum>()),
    _fp(getUserObject<SinglePhaseFluidProperties>("fp"))
{
}

Real
EnthalpyTemperatureConversionAux::computeProperty()
{
  Real value = 0.0;
  switch (_conversion_to)
  {
    case PropertyEnum::ENTHALPY:
      value = _fp.h_from_p_T(_porepressure[_qp], _property[_qp]);
      break;

    case PropertyEnum::TEMPERATURE:
      value = _fp.T_from_p_h(_porepressure[_qp], _property[_qp]);
      break;
  }
  return value;

}

Real
EnthalpyTemperatureConversionAux::computeValue()
{
  return computeProperty();
}
