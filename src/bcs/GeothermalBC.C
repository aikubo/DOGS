//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GeothermalBC.h"
#include "Function.h"
#include "SinglePhaseFluidProperties.h"
#include "MooseEnum.h"



registerMooseObject("dikesApp", GeothermalBC);

InputParameters
GeothermalBC::validParams()
{
  InputParameters params = DirichletBCBase::validParams();
  params.addRequiredParam<FunctionName>("function", "The forcing temperature function.");
  params.addClassDescription(
      "Imposes the boundary condition for a geothermal gradient temperature function in the PorousFlow module using enthalpy as the main variable ");
  params.addRequiredParam<UserObjectName>("fp", "The name of the user object for the fluid");
  MooseEnum property_enum("enthalpy temperature");
  params.addRequiredParam<MooseEnum>(
      "property", property_enum, "The fluid property heat equation variable that this boundary condition is to calculate");
  MooseEnum unit_choice("Kelvin=0 Celsius=1", "Kelvin");
  params.addParam<MooseEnum>(
      "temperature_unit", unit_choice, "The unit of the temperature variable");
  params.addRequiredCoupledVar("porepressure", "Fluid porepressure");

  return params;
}

GeothermalBC::GeothermalBC(const InputParameters & parameters)
  : DirichletBCBase(parameters), 
  _func(getFunction("function")),
  _fp(getUserObject<SinglePhaseFluidProperties>("fp")),
  _property_enum(getParam<MooseEnum>("property").getEnum<PropertyEnum>()),
  _T_c2k(getParam<MooseEnum>("temperature_unit") == 0 ? 0.0 : 273.15),
  _porepressure(coupledValue("porepressure"))

{
}

Real
GeothermalBC::computeQpValue()
{
  const Real Tk =  _func.value(_t, *_current_node) + _T_c2k;
  // check if it's a temperature or enthalpy variable 
  switch (_property_enum)
  {
    case PropertyEnum::ENTHALPY:
      return _fp.h_from_p_T(_porepressure[_qp],Tk);
      break;

    case PropertyEnum::TEMPERATURE:
      return Tk;
      break;
  }
  return 0.0;
}
