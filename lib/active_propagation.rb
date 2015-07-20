require 'active_record'
require 'sidekiq'
require "active_propagation/version"
require "active_propagation/class_extensions"
require "active_propagation/instance_extensions"
require "active_propagation/propagater_helper"

module ActivePropagation
  class Propagater
    def initialize(klass, association, id)
      @klass, @association, @id = klass, association, id
    end 

    def run 
      assocs.each do |a| 
        yield a, assoc_klass
      end 
    end 

    private

    def assoc_klass
      reflection.class_name.constantize
    end

    def reflection
      klass.reflections.with_indifferent_access[association]
    end

    def model
      klass.find(id)
    end

    def assocs
      model.send(association)
    end

    attr_reader :klass, :association, :id
  end

  class AbstractPropagaterWorker
    include PropagaterHelper
    include Sidekiq::Worker

    def self.run(klass_str, model_id, assoc, only)
      self.perform_async(klass_str, model_id, assoc, only)
    end
  end

  class AsyncLoopDeletor
    include PropagaterHelper
    include Sidekiq::Worker
    def perform(assoc_klass_str, assoc_id)
      assoc_klass_str.constantize.find(assoc_id).destroy
    end 
  end

  class AsyncDeletor < AbstractPropagaterWorker
    def perform(klass_str, model_id, assoc, only)
      klass = klass_str.constantize
       Propagater.new(klass, assoc, model_id).run do |a, assoc_klass| 
         AsyncLoopDeletor.perform_async(assoc_klass.to_s, a.id)
       end
    end
  end

  class AsyncLoopUpdater
    include Sidekiq::Worker
    include PropagaterHelper
    def perform(klass_str, model_id, assoc_id, only, assoc_klass_str)
      klass = klass_str.constantize
      model = klass.find(model_id)
      assoc_model = assoc_klass_str.constantize.find(assoc_id)
      assoc_model.update(propagated_attributes(model, only))
    end 
  end

  class AsyncUpdater < AbstractPropagaterWorker
    def perform(klass_str, model_id, assoc, only)
      klass = klass_str.constantize
      Propagater.new(klass, assoc, model_id).run do |a, assoc_klass| 
        AsyncLoopUpdater.perform_async(klass.to_s, model_id, a.id, only, assoc_klass.to_s)
      end 
    end 
  end

  class Updater
    extend PropagaterHelper
    def self.run(klass_str, model_id, assoc, only)
      klass = klass_str.constantize
      model = klass.find(model_id)
      Propagater.new(klass, assoc, model_id).run do |a| 
        a.update(propagated_attributes(model, only))
      end 
    end 
  end

  class Deletor
    extend PropagaterHelper
    def self.run(klass_str, model_id, assoc, only)
      klass = klass_str.constantize
      Propagater.new(klass, assoc, model_id).run do |a|
        a.destroy
      end
    end
  end
end

ActiveRecord::Base.send(:extend, ActivePropagation::ClassExtensions)
ActiveRecord::Base.send(:include, ActivePropagation::InstanceExtensions)
