module ActivePropagation::InstanceExtensions
  def _run_active_propagation
    klass = self.class
    klass.class_variable_get(:@@propagations).each do |association, config|
      if config[:async]
        ActivePropagation::Worker.perform_async(self.class.to_s, self.id, association.to_s, only, nested_async)
      else
        ActivePropagation::PROPAGATERS[config[:nested_async]].new(self, association, only: config[:only]).run
      end
    end
  end
end
