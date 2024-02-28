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
#include "PorousFlowDictator.h"

/**
 * Computes a Reynolds number for porous flow
 */

class PorousFlowReynoldsNumber : public AuxKernel
{
public:
  static InputParameters validParams();

  PorousFlowReynoldsNumber(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  virtual Real computeVelocity();

  /// Relative permeability of each phase
  const GenericMaterialProperty<std::vector<Real>, false> & _relative_permeability;

  /// Viscosity of each component in each phase
  const GenericMaterialProperty<std::vector<Real>, false> & _fluid_viscosity;

  /// Permeability of porous material
  const GenericMaterialProperty<RealTensorValue, false> & _permeability;

  /// Gradient of the pore pressure in each phase
  const GenericMaterialProperty<std::vector<RealGradient>, false> & _grad_p;

  /// Fluid density for each phase (at the qp)
  const GenericMaterialProperty<std::vector<Real>, false> & _fluid_density_qp;

  /// Porosity
  const GenericMaterialProperty<Real, false> & _porosity;

  /// PorousFlowDicatator UserObject
  const PorousFlowDictator & _dictator;


  /// Index of the fluid phase
  const unsigned int _ph;

  /// Gravitational acceleration
  const RealVectorValue _gravity;
};

  