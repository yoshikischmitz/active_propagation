require 'active_record'
require "active_propagation/version"
require "active_propagation/class_extensions"

module ActivePropagation
end

ActiveRecord::Base.send(:extend, ActivePropagation::ClassExtensions)
