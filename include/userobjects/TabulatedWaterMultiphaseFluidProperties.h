//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "TabulatedBicubicFluidProperties.h"
#include "Water97FluidProperties.h"

class SinglePhaseFluidProperties;
class BicubicInterpolation;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Woverloaded-virtual"

class TabulatedWaterMultiphaseFluidProperties : public TabulatedBicubicFluidProperties, public Water97FluidProperties
{
public:
  static InputParameters validParams();

  TabulatedWaterMultiphaseFluidProperties(const InputParameters & parameters);

};