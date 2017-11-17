require 'spec_helper'

describe Jasmine::Formatters::ExitCode do
  subject(:formatter) { Jasmine::Formatters::ExitCode.new }

  it 'is successful with an overall status of "passed"' do
    formatter.done({
      'overallStatus' => 'passed'
    })
    expect(formatter).to be_succeeded
  end

  it 'is successful with any other overall status' do
    formatter.done({
      'overallStatus' => 'incomplete'
    })
    expect(formatter).not_to be_succeeded
  end
end
