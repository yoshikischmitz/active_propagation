module ActivePropagation::ClassExtensions
  def propagates_changes_to(association, only: [], async: false, nested_async: false, on: [:update, :destroy])
    self.class_variable_set(:@@propagations, self.class_variable_get(:@@propagations) || {})
    after_commit(:_run_active_propagation, on: on) unless _commit_callbacks.map(&:filter).include?(:_run_active_propagation)
    self.class_variable_get(:@@propagations)[association] = {only: only, async: async, nested_async: nested_async}
  end
end
