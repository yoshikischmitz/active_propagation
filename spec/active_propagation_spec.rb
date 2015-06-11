require 'spec_helper'
require 'pry'

describe ActivePropagation do
  describe "activerecord extensions" do
    it "should register propgate_changes_to as a class method" do
      expect(Post).to respond_to(:propagates_changes_to)
    end
  end

  describe "it should register callbacks" do
    it "should register the correct callback" do
      expect(Post._commit_callbacks.map(&:filter)).to include(:_run_active_propagation)
    end
  end

  class Post
    propagates_changes_to :posts, only: [:text]
  end

  describe "_run_active_propagation" do
    before do
      @post = Post.create
    end
    it "should instantiate a synchronous propagater with synchronous propagation by default" do
      expect_any_instance_of(ActivePropagation::Propagater).to receive(:run)
      @post._run_active_propagation
    end
  end
end
