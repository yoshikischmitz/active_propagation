module ActivePropagation::InstanceExtensions
  def _run_active_propagation
    klass = self.class
    klass.class_variable_get(:@@propagations).each do |(association, only, async, nested_async)|
      if async
        ActivePropagation::Worker.perform_async(self.class.to_s, self.id, association.to_s, only, nested_async)
      else
        ActivePropagation::PROPAGATERS[nested_async].new(self, association, only: only).run
      end
    end
  end
end
