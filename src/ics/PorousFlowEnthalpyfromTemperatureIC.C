
//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "PorousFlowEnthalpyfromTemperatureIC.h"
#include "SinglePhaseFluidProperties.h"
#include "Function.h"

registerMooseObject("dikesApp", PorousFlowEnthalpyfromTemperatureIC);

InputParameters
PorousFlowEnthalpyfromTemperatureIC::validParams()
{
  InputParameters params = PorousFlowFluidPropertyIC::validParams();
  params.addClassDescription("PorousFlowEnthalpyfromTemperatureIC calculates an initial value of enthalpy from  "
                            "pressure and temperature. Temperature can be set in another IC as an AuxVariable.");
 
  return params;
}

PorousFlowEnthalpyfromTemperatureIC::PorousFlowEnthalpyfromTemperatureIC(const InputParameters & parameters)
  : PorousFlowFluidPropertyIC(parameters)
{
}

Real
PorousFlowEnthalpyfromTemperatureIC::value(const Point & p)
{
  Real property = 0.0;


  switch (_property_enum)
  {
    case PropertyEnum::ENTHALPY:
      
      property = _fp.h_from_p_T(_porepressure[_qp], _temperature[_qp]);
      break;

    case PropertyEnum::INTERNAL_ENERGY:
      property = _fp.e_from_p_T(_porepressure[_qp], _temperature[_qp]);
      break;

    case PropertyEnum::DENSITY:
      property = _fp.rho_from_p_T(_porepressure[_qp],  _temperature[_qp]);
      break;
  }

  return property;
}

