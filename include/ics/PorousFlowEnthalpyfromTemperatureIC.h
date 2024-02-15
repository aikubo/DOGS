//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "PorousFlowFluidPropertyIC.h"
#include "Function.h" 


/**
 * PorousFlowEnthalpyfromTemperatureIC calculates an initial value for a fluid property
 * (such as enthalpy) using pressure and temperature in the single phase regions.
 */
class PorousFlowEnthalpyfromTemperatureIC : public PorousFlowFluidPropertyIC
{
public:
  static InputParameters validParams();

  PorousFlowEnthalpyfromTemperatureIC(const InputParameters & parameters);


protected:
    /**
   * The value of the variable at a point.
   */
  virtual Real value(const Point & p) override;


};
