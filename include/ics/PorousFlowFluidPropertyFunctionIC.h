//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html


#pragma once
#include "dikesApp.h"

#include "InitialCondition.h"
#include <string>

class Function;

class SinglePhaseFluidProperties;

/**
 * PorousFlowFluidPropertyIC calculates an initial value for a fluid property
 * (such as enthalpy) using pressure and temperature in the single phase regions.
 */
class PorousFlowFluidPropertyFunctionIC : public InitialCondition
{
public:
  static InputParameters validParams();

  PorousFlowFluidPropertyFunctionIC(const InputParameters & parameters);


    /**
     * @returns The function name
     */
  const FunctionName functionName() const;

  virtual Real value(const Point & p) override;

protected:
  /// Porepressure (Pa)
  const VariableValue & _porepressure;

  /// Enum of fluid properties that can be set using this IC
  const enum class PropertyEnum { ENTHALPY, INTERNAL_ENERGY, DENSITY } _property_enum;
  /// FluidProperties user object
  const SinglePhaseFluidProperties & _fp;
  /// Conversion from degrees Celsius to degrees Kelvin
  const Real _T_c2k;
  /// Function to evaluate to form the initial condition
  const Function & _func;

};
