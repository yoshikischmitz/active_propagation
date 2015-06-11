require 'spec_helper'

class AssociationMock
end

class ModelMock
  attr_accessor :association

  def attributes
    {stuff: :things}
  end
end

RSpec.describe ActivePropagation::Propagater do
  describe "#run" do
    before do 
    end

    it "should update each of the associations with the same data" do
      model = ModelMock.new
      association1 = double
      association2 = double
      allow(association1).to receive(:update)
      allow(association2).to receive(:update)
      model.association = [association1, association2]

      @propagater = ActivePropagation::Propagater.new(model, :association, only: [:stuff])
      @propagater.run
      expect(association1).to have_received(:update)
      expect(association2).to have_received(:update)
    end
  end
end
