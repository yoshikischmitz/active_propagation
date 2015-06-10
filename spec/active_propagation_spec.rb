require 'spec_helper'
require 'pry'
describe ActivePropagation do
  describe "activerecord extensions" do
    it "should register propgate_changes_to as a class method" do
      expect(Post).to respond_to(:propagates_changes_to)
    end
  end
end
