require 'spec_helper'
require 'nokogiri'

describe Jasmine::Formatters::JUnitXml do
  describe '#summary' do
    describe 'when the full suite passes' do
      it 'shows the spec counts' do
        results = OpenStruct.new(:size => 1, :failures => [], :pending_specs => [],
                                 :results => [passing_result(fullName: 'Passing test', description: 'test')])
        subject = Jasmine::Formatters::JUnitXml.new(results)

        xml = Nokogiri::XML(subject.summary)

        testsuite = xml.xpath('/testsuites/testsuite').first
        testsuite['tests'].should == '1'
        testsuite['failures'].should == '0'
        testsuite['name'].should == 'Passing'

        xml.xpath('//testcase').size.should == 1
        xml.xpath('//testcase').first['name'].should == 'test'
      end
    end

    describe 'when there are failures' do
      it 'shows the spec counts' do
        results = OpenStruct.new(:size => 2, :failures => [failing_result], :pending_specs=> [],
                                 :results => [passing_result, failing_result])
        subject = Jasmine::Formatters::JUnitXml.new(results)

        xml = Nokogiri::XML(subject.summary)

        testsuite = xml.xpath('/testsuites/testsuite').first
        testsuite['tests'].should == '1'
        testsuite['failures'].should == '0'

        testsuite = xml.xpath('/testsuites/testsuite')[1]
        testsuite['tests'].should == '1'
        testsuite['failures'].should == '1'

        xml.xpath('//testcase').size.should == 2
        xml.xpath('//testcase/failure').size.should == 1
        xml.xpath('//testcase/failure').first['message'].should == 'a failure message'
        xml.xpath('//testcase/failure').first.content.should == 'a stack trace'
      end
    end
  end

  def failing_result(options = {})
    Jasmine::Results::Result.new(failing_raw_result.merge(options))
  end

  def passing_result(options = {})
    Jasmine::Results::Result.new(passing_raw_result.merge(options))
  end
end