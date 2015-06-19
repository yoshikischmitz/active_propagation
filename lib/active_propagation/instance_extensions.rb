module ActivePropagation::InstanceExtensions
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
      elsif (previous_changes.keys & config[:only]).any?
        if config[:async]
          ActivePropagation::AsyncUpdater.run(*args)
        else
          ActivePropagation::Updater.run(*args)
        end
      end
    end
  end
end
