[StochasticTools]
[]

[Distributions]
  [k]
    type = Uniform
    lower_bound = 10e-16
    upper_bound = 10e-11
  []
[]

[Samplers]
  [csv]
    type = CSVSampler
    samples_file = 'samplescsv'
    column_names = 'k'
    execute_on = 'initial timestep_end'
  []
[]

[MultiApps]
  [runner]
    type = SamplerFullSolveMultiApp
    sampler = csv
    input_files = 'constantpermAMRTest.i'
    mode = normal
    ignore_solve_not_converge = true

  []
[]

[Transfers]
  [parameters]
    type = SamplerParameterTransfer
    to_multi_app = runner
    sampler = csv
    parameters = 'AuxKernels/perm/value'
  []
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = csv
    stochastic_reporter = results
    from_reporter = 'T_host_avg/value T_dike_avg/value q_dike/value T_vec/T'
  []
  [results2]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = csv
    stochastic_reporter = results2
    from_reporter = 'acc/T_host_avg:value acc/T_dike_avg:value acc/q_dike:value'
  []
  [x_transfer]
    type = MultiAppReporterTransfer
    from_multi_app = runner
    subapp_index = 0
    from_reporters = T_vec/x
    to_reporters = const/x
  []
[]

[Reporters]
  [results]
    type = StochasticReporter
  []
  [results2]
    type = StochasticReporter
    output = none
  []
  [stats]
    type = StatisticsReporter
    reporters = 'results/results:T_host_avg:value results/results:T_dike_avg:value results/results:q_dike:value results/results:T_vec:T'
    compute = 'max mean stddev'
    ci_method = 'percentile'
    ci_levels = '0.05 0.95'
  []
  [const]
    type = ConstantReporter
    real_vector_names = 'x'
    real_vector_values = '0'
  []

[]

[Outputs]
  execute_on = 'FINAL'
  [out]
    type = JSON
  []
[]
