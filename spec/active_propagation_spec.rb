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
      @post.instance_variable_set(:@_active_propagation_changes, {text: ""})
    end

    it "should instantiate a synchronous propagater with synchronous propagation by default" do
      expect_any_instance_of(ActivePropagation::Propagater).to receive(:run)
      @post._run_active_propagation
    end

    class PropagaterMock
      def run
      end
    end

    it "should run a synchronous updater with synchronous updates by default" do
      Post.send(:propagates_changes_to, :posts, only: [:text])
      allow(ActivePropagation::Updater).to receive(:run)
      @post._run_active_propagation
      expect(ActivePropagation::Updater).to have_received(:run).with("Post", @post.id, "posts", [:text])
    end

    it "should run an asynchronous updater with asynchronous propagation if set" do
      Post.send(:propagates_changes_to, :posts, only: [:text], async: true)
      allow(ActivePropagation::AsyncUpdater).to receive(:run)
      @post._run_active_propagation
      expect(ActivePropagation::AsyncUpdater).to have_received(:run).with("Post", @post.id, "posts", [:text])
    end

    it "should run an asynchronous deletor if set" do
      Post.send(:propagates_changes_to, :posts, only: [:text], async: true)
      @post.destroy
      allow(ActivePropagation::AsyncDeletor).to receive(:run)
      @post._run_active_propagation
      expect(ActivePropagation::AsyncDeletor).to have_received(:run).with("Post", @post.id, "posts", [:text])
    end

    it "should run a deletor if set" do
      Post.send(:propagates_changes_to, :posts, only: [:text])
      @post.destroy
      allow(ActivePropagation::Deletor).to receive(:run)
      @post._run_active_propagation
      expect(ActivePropagation::Deletor).to have_received(:run).with("Post", @post.id, "posts", [:text])
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
