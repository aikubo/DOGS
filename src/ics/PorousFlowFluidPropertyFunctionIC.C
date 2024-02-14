
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

registerMooseObject("DikesApp", PorousFlowFluidPropertyFunctionIC);

InputParameters
PorousFlowFluidPropertyFunctionIC::validParams()
{
  InputParameters params = PorousFlowFluidPropertyIC::validParams();
  params.addClassDescription("PorousFlowFluidPropertyFunctionIC calculates an initial value for a fluid property "
                            "(such as enthalpy) using a temperature function in the single phase regions.");
  params.addRequiredParam<FunctionName>("tempfunction", "The initial temperature condition function.");

  return params;
}

PorousFlowFluidPropertyFunctionIC::PorousFlowFluidPropertyFunctionIC(const InputParameters & parameters)
  : PorousFlowFluidPropertyIC(parameters),
    _porepressure(coupledValue("porepressure")),
    _temperature(coupledValue("temperature")),
    _property_enum(getParam<MooseEnum>("property").getEnum<PropertyEnum>()),
    _fp(getUserObject<SinglePhaseFluidProperties>("fp")),
    _T_c2k(getParam<MooseEnum>("temperature_unit") == 0 ? 0.0 : 273.15),
    _func(getFunction("function"))
{
}

Real
PorousFlowFluidPropertyFunctionIC::value(const Point & p)
{
  // call temperature function  
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

