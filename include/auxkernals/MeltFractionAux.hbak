//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "FunctionAux.h"

class Function;

/**
 * Function auxiliary value
 */
class MeltFractionAux  : public FunctionAux
{
public:
  static InputParameters validParams();

  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  MeltFractionAux(const InputParameters & parameters);

protected:
  virtual Real computeValue() override;
  /// type of function to calculate moose enum 
  const enum class FunctionEnum { LINEAR, PIECEWISE, EXPONENTIAL } _function_enum;
//   /// check function is actually passed 
//   const bool _is_func;
//   /// check temperature is actually passed
//   const bool _has_temp;
  /// Function being used to compute the value of this kernel
  const Function & _func;
  /// Liquidus temperature
    const Real _tliq;
  /// Solidus temperature
    const Real _tsol;
  /// Temperature variable 
    const VariableValue & _temperature;
    /// Exponent for the exponential function
    const Real _beta;
};
