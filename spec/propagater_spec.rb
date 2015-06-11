require 'spec_helper'

class AssociationMock
end

class ModelMock
  attr_accessor :association

  def id
    1
  end

  def attributes
    {stuff: :things}
  end
end

RSpec.describe ActivePropagation::Propagater do
  describe "#run" do
    it "should update each of the associations with the same data" do
      model = ModelMock.new
      association1 = double
      association2 = double
      allow(association1).to receive(:update)
      allow(association2).to receive(:update)
      model.association = [association1, association2]

      @propagater = ActivePropagation::Propagater.new(model, :association, only: [:stuff])
      @propagater.run
      expect(association1).to have_received(:update).with({stuff: :things})
      expect(association2).to have_received(:update).with({stuff: :things})
    end
  end
end

RSpec.describe ActivePropagation::AsyncPropagater do
  describe "#run" do
    it "should update each of the associations with the same data" do
      model = ModelMock.new
      association1 = double
      association2 = double
      allow(association1).to receive(:update)
      allow(association2).to receive(:update)
      allow(association1).to receive(:id).and_return 1
      allow(association2).to receive(:id).and_return 2
      model.association = [association1, association2]

      allow(ActivePropagation::LoopWorker).to receive(:perform_async)

      @propagater = ActivePropagation::AsyncPropagater.new(model, :association, only: [:stuff])
      @propagater.run
      expect(ActivePropagation::LoopWorker).to have_received(:perform_async).with("ModelMock", 1, 1, [:stuff])
      expect(ActivePropagation::LoopWorker).to have_received(:perform_async).with("ModelMock", 1, 2, [:stuff])
    end
  end
end
