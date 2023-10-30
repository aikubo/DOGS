#include "dikesApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
dikesApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

dikesApp::dikesApp(InputParameters parameters) : MooseApp(parameters)
{
  dikesApp::registerAll(_factory, _action_factory, _syntax);
}

dikesApp::~dikesApp() {}

void 
dikesApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<dikesApp>(f, af, s);
  Registry::registerObjectsTo(f, {"dikesApp"});
  Registry::registerActionsTo(af, {"dikesApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
dikesApp::registerApps()
{
  registerApp(dikesApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
dikesApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  dikesApp::registerAll(f, af, s);
}
extern "C" void
dikesApp__registerApps()
{
  dikesApp::registerApps();
}
