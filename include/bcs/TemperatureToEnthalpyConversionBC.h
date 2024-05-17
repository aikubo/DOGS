//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "DirichletBCBase.h"
#include "MooseEnum.h"

class Function;
class SinglePhaseFluidProperties;

/**
 * Defines a boundary condition that forces the value to be a user specified
 * function at the boundary.
 */
class TemperatureToEnthalpyConversionBC : public DirichletBCBase
{
public:
  static InputParameters validParams();

  TemperatureToEnthalpyConversionBC(const InputParameters & parameters);

protected:

  
  virtual Real computeQpValue() override;

    /// Porepressure (Pa)
  const VariableValue & _porepressure;

  /// fluid properties object
  const SinglePhaseFluidProperties & _fp;

  /// The function being used for evaluation
  const Function & _func;

  /// temperature or enthalpy function MooseEnum
  const enum class PropertyEnum { ENTHALPY, TEMPERATURE } _property_enum;

    /// Conversion from degrees Celsius to degrees Kelvin
  const Real _T_c2k;




};
