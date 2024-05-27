[StochasticTools]
[]

[Distributions]
  [k]
    type = Uniform
    lower_bound = 10e-17
    upper_bound = 10e-11
  []
[]

[Samplers]
  [csv]
    type = InputMatrix
    matrix = "10e-11; 10e-12; 10e-13; 10e-14; 10e-15; 10e-16"
  []
[]

[MultiApps]
  [runner]
    type = SamplerTransientMultiApp
    sampler = csv
    input_files = 'constantpermAMRTest.i'
    mode = normal
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
    from_reporter = 'T_host_avg/value T_dike_avg/value q_dike/value perm/value T_vec_near/T T_vec_far/T'
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
    from_reporters = 'T_vec_near/x T_vec_far/x'
    to_reporters = 'nearx/x farx/x'
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
  [nearx]
    type = ConstantReporter
    real_vector_names = 'x'
    real_vector_values = '0'
  []
  [farx]
    type = ConstantReporter
    real_vector_names = 'x'
    real_vector_values = '0'
  []

[]

[Executioner]
  type = Transient
  end_time = 3e9
  dt = 7.889e6
[]

[Outputs]
  execute_on = 'timestep_end'
  interval = 4
  [out]
    type = JSON
  []
  csv=true
[]
