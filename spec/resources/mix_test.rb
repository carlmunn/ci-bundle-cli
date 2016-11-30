require "spec_helper"

describe 'simple test' do
  it 'test for testing' do
    raise 'raised exception'
  end

  it 'test for failture' do
    expect(1).to eql(2)
  end

  it 'test for success' do
    expect(1).to eql(1)
  end
end