[StochasticTools]
[]

[Distributions]
  [k]
    type = Uniform
    lower_bound = 10e-10
    upper_bound = 10e-15
  []
[]

[Samplers]
  [csv]
    type = CSVSampler
    samples_file = 'samples.csv'
    column_names = 'k'
    execute_on = 'initial timestep_end'
  []
[]

[MultiApps]
  [runner]
    type = SamplerFullSolveMultiApp
    sampler = csv
    input_files = 'constantpermAMRTest.i'
    mode = batch-restore
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
    from_reporter = 'T_host_avg/value T_dike_avg/value q_dike/value'
  []
[]

[Reporters]
  [results]
    type = StochasticReporter
  []
  [stats]
    type = StatisticsReporter
    reporters = 'results/results:T_host_avg:value results/results:T_dike_avg:value results/results:q_dike:value'
    compute = 'max mean stddev'
    ci_method = 'percentile'
    ci_levels = '0.05 0.95'
  []
[]

[Outputs]
  execute_on = 'FINAL'
  [out]
    type = JSON
  []
[]
