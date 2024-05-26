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
  []
  [MC]
    type = MonteCarlo
    num_rows = 20
    distributions = 'k'
    execute_on = INITIAL # create random numbers on initial and use them for each timestep
  []
[]

[MultiApps]
  [runner]
    type = SamplerTransientMultiApp
    sampler = MC
    input_files = 'constantpermAMRTest.i'
    mode = normal
    ignore_solve_not_converge = true
  []
[]

[Transfers]
  [parameters]
    type = SamplerParameterTransfer
    to_multi_app = runner
    sampler = MC
    parameters = 'AuxKernels/perm/value'
  []
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = MC
    stochastic_reporter = results
    from_reporter = 'T_host_avg/value T_dike_avg/value q_dike/value perm/value T_vec_near/T T_vec_far/T'
  []
  [results2]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = MC
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
    outputs = none
  []
  [stats]
    type = StatisticsReporter
    reporters = 'results/results:T_host_avg:value results/results:T_dike_avg:value results/results:q_dike:value results/results:T_vec_near:T results/results:T_vec_far:T results/results:perm:value'
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

[Executioner]
  type = Transient
  end_time = 1e6
  dt = 1e6
[]

[Outputs]
  execute_on = 'FINAL'
  [out]
    type = JSON
  []
[]
