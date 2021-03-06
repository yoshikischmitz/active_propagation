module ActivePropagation::ClassExtensions
  def propagates_changes_to(association, only: [], async: false, nested_async: false, on: [:update, :destroy])
    props = if class_variable_defined?(:@@propagations)
      self.class_variable_get(:@@propagations) || {}
    else
      {}
    end
    self.class_variable_set(:@@propagations, props)
    before_save(:_save_active_propagation_changes, on: on) unless _commit_callbacks.map(&:filter).include?(:_save_active_propagation_changes)
    after_commit(:_run_active_propagation, on: on) unless _commit_callbacks.map(&:filter).include?(:_run_active_propagation)
    self.class_variable_get(:@@propagations)[association] = {only: only, async: async, nested_async: nested_async}
  end

  attr_accessor :_active_propagation_changes
end
