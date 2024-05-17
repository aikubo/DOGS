//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "AuxKernel.h"
#include "SinglePhaseFluidProperties.h"

class SinglePhaseFluidProperties;

/**
 * Converts from Temperature to Enthalpy or vice versa
 */

class EnthalpyTemperatureConversionAux : public AuxKernel
{
public:
  static InputParameters validParams();

  EnthalpyTemperatureConversionAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  virtual Real computeProperty();

    /// Temperature variable
    const VariableValue & _property;

    /// Porepressure variable
    const VariableValue & _porepressure;

    /// Conversion to temperature or enthalpy
    const enum class PropertyEnum { ENTHALPY, TEMPERATURE } _conversion_to;

    /// Fluid properties user object
    const SinglePhaseFluidProperties & _fp;

};

  