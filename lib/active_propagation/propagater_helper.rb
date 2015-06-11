module PropagaterHelper
  def propagated_attributes(model, only)
    only.map{|x| [x, model.attributes[x]]}.to_h
  end
end
