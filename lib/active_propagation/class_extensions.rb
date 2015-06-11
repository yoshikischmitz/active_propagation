module ActivePropagation::ClassExtensions
  def propagates_changes_to(association, only: [], async: false, nested_async: false, on: [:update, :destroy])
    self.class_variable_set(:@@propagations, [])
    after_commit(:_run_active_propagation, on: on)
    self.class_variable_get(:@@propagations) << [association, only, async, nested_async]
  end
end
