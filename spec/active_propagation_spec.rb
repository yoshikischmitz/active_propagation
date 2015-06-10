require 'spec_helper'

describe ActivePropagation do
  it 'has a version number' do
    expect(ActivePropagation::VERSION).not_to be nil
  end

  it 'does something useful' do
    Post.create()
  end
end
