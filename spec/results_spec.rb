require 'spec_helper'

describe Jasmine::Results do
  it "should be able to return suites" do
    suites = {}
    results = {}
    Jasmine::Results.new(results, suites).suites.should == suites
  end

  it "should return a result for a particular spec id" do
    suites = {}
    result1 = {:some => 'result'}
    result2 = {:some => 'other result'}
    raw_results = {'1' => result1, '2' => result2 }
    results = Jasmine::Results.new(raw_results, suites)
    results.for_spec_id('1').should == result1
    results.for_spec_id('2').should == result2
  end
end

