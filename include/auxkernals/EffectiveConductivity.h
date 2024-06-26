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
#include "MaterialProperty.h"

/**
 * Computes a Reynolds number for porous flow
 */

class EffectiveConductivity : public AuxKernel
{
public:
  static InputParameters validParams();

  EffectiveConductivity(const InputParameters & parameters);

protected:
  virtual Real computeValue() override;

  /// enthalpy
  const GenericMaterialProperty<std::vector<Real>, is_ad> & _enthalpy;

  /// dH
  GenericMaterialProperty<std::vector<Real>> & _enthalpy_difference;

  // temperature gradient
  const VariableGradient & _temperature_grad;

  // length scale
  const VariableValue & _length;
};
