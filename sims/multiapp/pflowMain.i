
!include pflow.i
[BCs]
  inactive = 'Matched_Single'
  [Matched_Multi]
    type = MatchedValueBC
    variable = T_parent
    boundary = interface
    v = T_cutout
  []
[]

[MultiApps]
  [./child_app]
    type = TransientMultiApp
    app_type = dikesApp
    input_files = 'nsdikeChild.i'
    execute_on = 'timestep_begin'
  [../]
[]

[Transfers]
  [./transfer_to_child]
    type =  MultiAppGeneralFieldShapeEvaluationTransfer
    from_multi_app = child_app
    source_variable = T_child
    variable = T_cutout
    bbox_factor = 1.2
  [../]
  [push_qx]
    # Transfer from this app to the sub-app
    # which variable from this app?
    # which variable in the sub app?
    type = MultiAppGeneralFieldNearestNodeTransfer
    to_multi_app = child_app
    source_variable = GradTx
    #bbox_factor = 1.2
    variable = GradTx_from_parent
  []
  [push_cond]
    type = MultiAppGeneralFieldNearestNodeTransfer
    to_multi_app = child_app
    source_variable = k
    variable = k_from_parent
  []
[]

[AuxVariables]
  [T_cutout]
  []
  [GradTx]
    family = MONOMIAL
    order = CONSTANT
  []
  [diffx]
    family = MONOMIAL
    order = CONSTANT
  []
  [k]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [GradTx]
    type = VariableGradientComponent
    variable = GradTx
    gradient_variable = T_parent
    component = x
    execute_on = 'initial timestep_end'
  []
  [diffx]
    type = ParsedAux
    variable = diffx
    coupled_variables = 'GradTx k'
    expression = 'k*GradTx'
    execute_on = 'initial timestep_end'
  []
  [k]
    type = ParsedAux
    variable = k
    expression = '5'
    execute_on = 'initial timestep_end'
  []
[]

[Executioner]
  fixed_point_max_its = 10
  fixed_point_abs_tol = 1e-5
  fixed_point_rel_tol = 1e-4
[]

[Postprocessors]
  [dtpost]
    type = TimestepSize
    execute_on = TIMESTEP_BEGIN
  []
[]

[Outputs]
  checkpoint = true
[]

##############################
#              Notes
#####################################


# testing cutout
# testing

# test 1:
# 1. Create a 10x10 mesh
# 2. Cut out a 3x7 block from the mesh
# 3. Rename the block to 'host dike'
# 4. Create a new boundary between the host and dike blocks
# 5. Delete the dike block
# 6. create cutout in mulitapp
# 7. transfer a constant aux variable from child to parent
# results: T_child is 0 across the entire domain, T_child_aux in sub set to 500
# test 2:
# add bbox_factor to parent of 1.2
# results: T_child has a value of 500 around the cutout and 0 elsewhere

# transfers back and forth worked for FE kernals
# but the q tranfer from FE to FV doesn't seem to be working
# MultiAppGeneralFieldShapeEvaluationTransfer does not work
# to transfer field variables from FE to FV
# MultiAppGeneralFieldNearestNodeTransfer works

# try with FixedPoints?
# withoutfixed points works fine
# with it fails to converge
# took out rel and abs tol and still no convergence

#adjusting tolerances got FixedPoints to converge
# based on
# https://github.com/idaholab/moose/discussions/24116

# fixed_point_abs_tol >> nl_abs_tol
# for FixedPoints to converge

# in the sub app, 1e-9 would not converger
# but added precond and automatic_scaling and it worked

# for some reason transfering parsed variable of k*gradT doesn't work
# just transfering k and gradT and doing the multiplication in the sub app works
# checked that changing the sub app resolution doesn't change the results

# added materials and porepressure for porousflow
# it fails completely

# works but not with fixed points
# trying to increase domain fails to converge
# when i increase the domain
# the nschild simulation does not solve at all????
#  child_app0: Pre-SMO residual: 0
# child_app0:
# child_app0: Performing automatic scaling calculation
# child_app0:
# child_app0:  0 Nonlinear |R| = 0.000000e+00
# child_app0:  Solve Converged!
# increasing the domain made the change in temperature across the domain of the sub app
# much smaller so it was approx zero
# added a source term to the sub app and added execute on initial and it worked
# also added line search = none to main app

# it works but I'm getting non physical results. negative temperatures!
# changing back to NEWTON worked and the results look better
# added permeability Temperature dependence and it actually speeds up convergence
# doesn't change the results too much

# added physics into childfv and it works
# very high cp means that temp doesn't change much in the sub app (at all)
# but it still appears to be solving

# added subcycling and it works
