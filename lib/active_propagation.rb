require 'active_record'
require "active_propagation/version"
require "active_propagation/class_extensions"
require "active_propagation/instance_extensions"

module ActivePropagation
end

ActiveRecord::Base.send(:extend, ActivePropagation::ClassExtensions)
ActiveRecord::Base.send(:include, ActivePropagation::InstanceExtensions)
