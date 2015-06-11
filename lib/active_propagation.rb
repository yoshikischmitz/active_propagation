require 'active_record'
require 'sidekiq'
require "active_propagation/version"
require "active_propagation/class_extensions"
require "active_propagation/instance_extensions"

module ActivePropagation
  class AbstractPropagater
    def initialize(model, association, only: )
      @model, @association, @only = model, association, only
    end
    
    def run
      raise NotImplementedError
    end

    private

    attr_reader :model, :association, :only
  end

  class AsyncPropagater < AbstractPropagater
    def run
      model.send(association).each do |a|
        LoopWorker.perform_async(model.class.to_s, model.id, a.id, only)
      end
    end
  end

  class Propagater < AbstractPropagater
    def run
      model.send(association).each do |a|
        a.update propagated_attributes
      end
    end
  end

  class LoopWorker 
    include Sidekiq::Worker
    def perform(model_class_str, model_id, association_id, only_arr)
      klass = model_class_str.constantize
      model = klass.find(model_id)
      association = klass.find(association_id)
      association.update(propagated_attributes(model, only_arr))
    end
  end
  
  PROPAGATERS = {true => AsyncPropagater, false => Propagater}
  class Worker
    include Sidekiq::Worker
    def perform(klass_str, model_id, assoc_str, only_arr, nested_async)
      klass = klass_str.constantize
      model = klass.find(model_id)
      PROPAGATERS[async].new(model, assocation, only: only)
    end
  end

  def propagated_attributes(model, only)
    only.map{|x| [x, model.attributes[x]]}.to_h
  end
end

ActiveRecord::Base.send(:extend, ActivePropagation::ClassExtensions)
ActiveRecord::Base.send(:include, ActivePropagation::InstanceExtensions)
