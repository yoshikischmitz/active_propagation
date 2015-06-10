Gem::Specification.new do |s|
  s.name        = 'active_propagation'
  s.version     = '0.0.0'
  s.date        = '2015-06-10'
  s.summary     = "propagate changes amongst ActiveRcord associations"
  s.description = "ActivePropagation provides classes and ActiveRecord extensions for propagating changes amongst models, optionally using Sidekiq to parallelize the process."
  s.authors     = ["Yoshiki Schmitz"]
  s.email       = 'yoshiki@masteryconnect.com'
  s.files       = ["lib/active_propagation.rb"]
end
