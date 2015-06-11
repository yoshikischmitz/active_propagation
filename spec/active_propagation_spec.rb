require 'spec_helper'
require 'pry'

describe ActivePropagation do
  after(:each) do
    Post.class_variable_set(:@@propagations, nil)
  end

  describe "activerecord extensions" do
    it "should register propgate_changes_to as a class method" do
      expect(Post).to respond_to(:propagates_changes_to)
    end
  end

  describe "it should register callbacks" do
    before do
      Post.send(:propagates_changes_to, :posts, only: [:text])
    end

    it "should register the correct callback" do
      expect(Post._commit_callbacks.map(&:filter)).to include(:_run_active_propagation)
    end

    it "should register the callback once" do
      Post.send(:propagates_changes_to, :posts, only: [:text])
      Post.send(:propagates_changes_to, :posts, only: [:text])
      expect(Post._commit_callbacks.map(&:filter).select{|x| x == :_run_active_propagation}.size).to eq(1)
    end
  end

  describe "_run_active_propagation" do
    before do
      Post.send(:propagates_changes_to, :posts, only: [:text])
      @post = Post.create
    end

    it "should instantiate a synchronous propagater with synchronous propagation by default" do
      expect_any_instance_of(ActivePropagation::Propagater).to receive(:run)
      @post._run_active_propagation
    end

    class PropagaterMock
      def run
      end
    end

    it "should instantiate a synchronous propagater with synchronous propagation by default" do
      allow(ActivePropagation::Propagater).to receive(:new).and_return(PropagaterMock.new)
      @post._run_active_propagation
      expect(ActivePropagation::Propagater).to have_received(:new).with(@post, :posts, only: [:text])
    end

    it "only runs one job per key" do
      Post.send(:propagates_changes_to, :posts, only: [:text])
      Post.send(:propagates_changes_to, :posts, only: [:text])
      mock = PropagaterMock.new
      allow(ActivePropagation::Propagater).to receive(:new).and_return(mock)
      allow(mock).to receive(:run).and_return(true)
      @post._run_active_propagation
      expect(mock).to have_received(:run).once
    end
  end
end
