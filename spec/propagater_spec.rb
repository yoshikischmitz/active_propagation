require 'spec_helper'

RSpec.describe "Updaters" do
  before do
    @post = Post.create(text: "hello world")
    @remote1 = Post.create(post: @post)
    @remote2 = Post.create(post: @post)
  end

  describe "Synchronous Updater" do
    it "should update each of the associations with the same data" do
      ActivePropagation::Updater.run(@post.class.to_s, @post.id, :posts, [:text])
      expect(@remote1.reload.text).to eq("hello world")
      expect(@remote2.reload.text).to eq("hello world")
    end
  end

  describe "Async Updater" do
    it "should update each of the associations with the same data" do
      ActivePropagation::AsyncUpdater.new.perform(@post.class.to_s, @post.id, :posts, [:text])
      expect(@remote1.reload.text).to eq("hello world")
      expect(@remote2.reload.text).to eq("hello world")
    end
  end
end

RSpec.describe "Deletors" do
  before do
    @post = Post.create(text: "hello world")
    @remote1 = Post.create(post: @post)
    @remote2 = Post.create(post: @post)
  end

  describe "Synchronous Deletor" do
    it "should update each of the associations with the same data" do
      ActivePropagation::Deletor.run(@post.class.to_s, @post.id, :posts, [:text])
      expect(Post.exists?(@remote1.id)).to eq(false)
      expect(Post.exists?(@remote2.id)).to eq(false)
    end
  end

  describe "Async Updater" do
    it "should update each of the associations with the same data" do
      ActivePropagation::AsyncDeletor.new.perform(@post.class.to_s, @post.id, :posts, [:text])
      expect(Post.exists?(@remote1.id)).to eq(false)
      expect(Post.exists?(@remote2.id)).to eq(false)
    end
  end
end

RSpec.describe "propagater" do
  describe "It handles multiple classes" do
    before do
      @post = Post.create
      @other = OtherPost.create(post: @post)
    end
    
    it "should find all of the remotes for a different class" do
      ActivePropagation::Propagater.new(Post, :other_posts, @post.id).run do |a|
        expect(a).to eq(@other)
      end
    end
  end
end
