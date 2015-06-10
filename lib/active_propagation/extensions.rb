module ActivePropagation::ClassExtensions
  def propagates_changes_to(association, only: [], async: false, nested_async: false, on: [:create, :update, :destroy])
  end
end

