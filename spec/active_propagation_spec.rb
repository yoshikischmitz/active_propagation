require 'spec_helper'

describe ActivePropagation do
  describe "activerecord extensions" do
    it "should respond to propgate_changes" do
      expect(Post).to respond_to(:propagates_changes_to)
    end
  end
end
