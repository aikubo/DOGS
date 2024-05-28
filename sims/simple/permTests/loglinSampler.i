[StochasticTools]
[]

[Distributions]
  [klow]
    type = Uniform
    lower_bound = -25
    upper_bound = -18
  []
  [khigh]
    type = Uniform
    lower_bound = -16
    upper_bound = -11
  []
  [Tlow]
    type = Uniform
    lower_bound = 200
    upper_bound = 500
  []
  [Thigh]
    type = Uniform
    lower_bound = 650
    upper_bound = 1400
  []
[]

[Samplers]
    [MC]
      type = InputMatrix
      # klow khigh Tlow Thigh
      matrix = '-18 -13 300 1000
                -18 -13 600 1000
                -20 -15 300 1000
                -20 -15 600 1000
                -18 -13 800 1000
                -18 -13 300 1200'
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
    parameters = 'AuxKernels/klow/value AuxKernels/khigh/value AuxKernels/Tlow/value AuxKernels/Thigh/value'
  []
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = MC
    stochastic_reporter = results
    from_reporter = 'T_host_avg/value T_dike_avg/value q_dike/value perm/value T_vec_near/T T_vec_far/T'
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
  dt = 1e6
[]

[Outputs]
  execute_on = 'timestep_end'
  interval = 1
  [out]
    type = JSON
  []
[]

