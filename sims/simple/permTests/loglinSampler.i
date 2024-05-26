[StochasticTools]
[]

[Distributions]
  [klow]
    type = Uniform
    lower_bound = -22
    upper_bound = -18
  []
  [khigh]
    type = Uniform
    lower_bound = -16
    upper_bound = -11
  []
  [Tlow]
    type = Uniform
    lower_bound = 300
    upper_bound = 400
  []
  [Thigh]
    type = Uniform
    lower_bound = 800
    upper_bound = 900
  []
[]

[Samplers]
    [MC]
      type = MonteCarlo
      num_rows = 10
      distributions = 'klow khigh Tlow Thigh'
      execute_on = INITIAL # create random numbers on initial and use them for each timestep
    []
[]

[MultiApps]
  [runner]
    type = SamplerTransientMultiApp
    sampler = MC
    input_files = 'loglinTest.i'
    mode = normal
  []
[]

[Transfers]
  [parameters]
    type = SamplerParameterTransfer
    to_multi_app = runner
    sampler = MC
    parameters = 'klow khigh Tlow Thigh'
  []
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = MC
    stochastic_reporter = results
    from_reporter = 'T_host_avg/value T_dike_avg/value q_dike/value T_vec/T'
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
