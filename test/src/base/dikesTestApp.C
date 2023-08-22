//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "dikesTestApp.h"
#include "dikesApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
dikesTestApp::validParams()
{
  InputParameters params = dikesApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

dikesTestApp::dikesTestApp(InputParameters parameters) : MooseApp(parameters)
{
  dikesTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

dikesTestApp::~dikesTestApp() {}

void
dikesTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  dikesApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"dikesTestApp"});
    Registry::registerActionsTo(af, {"dikesTestApp"});
  }
}

void
dikesTestApp::registerApps()
{
  registerApp(dikesApp);
  registerApp(dikesTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
dikesTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  dikesTestApp::registerAll(f, af, s);
}
extern "C" void
dikesTestApp__registerApps()
{
  dikesTestApp::registerApps();
}
