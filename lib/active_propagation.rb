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
        yield a
      end 
    end 

    def assocs
      klass.where(foreign_key => id) 
    end 

    def foreign_key
      klass.reflections[association.to_s].foreign_key
    end 

    private
    
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
    def perform(klass_str, assoc_id)
      klass = klass_str.constantize
      klass.find(assoc_id).destroy
    end 
  end

  class AsyncDeletor < AbstractPropagaterWorker
    def perform(klass_str, model_id, assoc, only)
      klass = klass_str.constantize
       Propagater.new(klass, assoc, model_id).run do |a| 
         AsyncLoopDeletor.perform_async(klass.to_s, a.id)
       end
    end
  end

  class AsyncLoopUpdater
    include Sidekiq::Worker
    include PropagaterHelper
    def perform(klass_str, model_id, assoc_id, only)
      klass = klass_str.constantize
      model = klass.find(model_id)
      klass.find(assoc_id).update(propagated_attributes(model, only))
    end 
  end

  class AsyncUpdater < AbstractPropagaterWorker
    def perform(klass_str, model_id, assoc, only)
      klass = klass_str.constantize
      Propagater.new(klass, assoc, model_id).run do |a| 
        AsyncLoopUpdater.perform_async(klass.to_s, model_id, a.id, only)
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
