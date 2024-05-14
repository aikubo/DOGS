//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PorousFlowFluidPropertyFunctionIC.h"
#include "SinglePhaseFluidProperties.h"
#include "Function.h"

registerMooseObject("dikesApp", PorousFlowFluidPropertyFunctionIC);

InputParameters
PorousFlowFluidPropertyFunctionIC::validParams()
{
  InputParameters params = InitialCondition::validParams();
  params.addRequiredCoupledVar("porepressure", "Fluid porepressure");
  MooseEnum unit_choice("Kelvin=0 Celsius=1", "Kelvin");
  params.addParam<MooseEnum>(
      "temperature_unit", unit_choice, "The unit of the temperature variable");
  params.addRequiredParam<UserObjectName>("fp", "The name of the user object for the fluid");
  MooseEnum property_enum("enthalpy internal_energy density");
  params.addRequiredParam<MooseEnum>(
      "property", property_enum, "The fluid property that this initial condition is to calculate");
  params.addClassDescription("An initial condition to calculate one fluid property (such as "
                             "enthalpy) from pressure and temperature");

 params.addRequiredParam<FunctionName>("function", "The temperature function.");
 params.addClassDescription("An initial condition to calculate one fluid property (such as "
                             "enthalpy) from temperature function and pressure");

  return params;
}

PorousFlowFluidPropertyFunctionIC::PorousFlowFluidPropertyFunctionIC(const InputParameters & parameters)
  : InitialCondition(parameters),
    _porepressure(coupledValue("porepressure")),
    _property_enum(getParam<MooseEnum>("property").getEnum<PropertyEnum>()),
    _fp(getUserObject<SinglePhaseFluidProperties>("fp")),
    _T_c2k(getParam<MooseEnum>("temperature_unit") == 0 ? 0.0 : 273.15),
    _func(getFunction("function"))
{
}

Real
PorousFlowFluidPropertyFunctionIC::value(const Point & p)
{
  // The FluidProperties userobject uses temperature in K
  const Real Tk = _func.value(_t, p) + _T_c2k;

  // The fluid property
  Real property = 0.0;

  switch (_property_enum)
  {
    case PropertyEnum::ENTHALPY:
      property = _fp.h_from_p_T(_porepressure[_qp], Tk);
      break;

    case PropertyEnum::INTERNAL_ENERGY:
      property = _fp.e_from_p_T(_porepressure[_qp], Tk);
      break;

    case PropertyEnum::DENSITY:
      property = _fp.rho_from_p_T(_porepressure[_qp], Tk);
      break;
  }

  return property;
}

const FunctionName
PorousFlowFluidPropertyFunctionIC::functionName() const
{
  return _func.name();
}
