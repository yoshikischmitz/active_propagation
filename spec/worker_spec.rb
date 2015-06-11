RSpec.describe ActivePropagation::Worker do
  describe "perform" do
    before do
      @model = Post.create
      @propagater_mock = double 
      allow(@propagater_mock).to receive(:run)
    end

    it "should instantiate a synchronous worker with the correct args" do
      allow(ActivePropagation::Propagater).to receive(:new).and_return(@propagater_mock)
      ActivePropagation::Worker.new.perform("Post", @model.id, :posts, [:text], false)
      expect(ActivePropagation::Propagater).to have_received(:new).with(@model, :posts, only: [:text])
      expect(@propagater_mock).to have_received(:run)
    end

    it "should instantiate an asynchronous worker with the correct args" do
      allow(ActivePropagation::AsyncPropagater).to receive(:new).and_return(@propagater_mock)
      ActivePropagation::Worker.new.perform("Post", @model.id, :posts, [:text], true)
      expect(ActivePropagation::AsyncPropagater).to have_received(:new).with(@model, :posts, only: [:text])
      expect(@propagater_mock).to have_received(:run)
    end
  end
end
