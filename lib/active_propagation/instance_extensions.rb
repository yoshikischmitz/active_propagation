module ActivePropagation::InstanceExtensions

  attr_reader :_active_propagation_changes

  def _run_active_propagation
    klass = self.class
    klass.class_variable_get(:@@propagations).each do |association, config|
      args = [self.class.to_s, self.id, association.to_s, config[:only]]
      if self.destroyed?
        if config[:async]
          ActivePropagation::AsyncDeletor.run(*args)
        else
          ActivePropagation::Deletor.run(*args)
        end
      elsif (_active_propagation_changes.keys.map(&:to_s) & config[:only].map(&:to_s)).any?
        if config[:async]
          ActivePropagation::AsyncUpdater.run(*args)
        else
          ActivePropagation::Updater.run(*args)
        end
      end
    end
  end

  def _save_active_propagation_changes 
    @_active_propagation_changes ||= self.changes
  end
end
