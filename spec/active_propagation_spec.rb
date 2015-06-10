require 'spec_helper'
require 'pry'
describe ActivePropagation do
  describe "activerecord extensions" do
    it "should register propgate_changes_to as a class method" do
      expect(Post).to respond_to(:propagates_changes_to)
    end
  end

  describe "it should register callbacks" do
    class Post
      propagates_changes_to :posts, only: [:text]
    end

    it "should register the correct callback" do
      expect(Post._commit_callbacks.map(&:filter)).to include(:_run_active_propagation)
    end
  end
end
