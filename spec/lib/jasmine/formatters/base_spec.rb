require 'spec_helper'

describe Jasmine::Formatters::BaseFormatter do
  it 'raises an error on summary to teach people a lesson' do
    expect {
      Jasmine::Formatters::BaseFormatter.new.format
    }.to(raise_error(NotImplementedError))
  end
end