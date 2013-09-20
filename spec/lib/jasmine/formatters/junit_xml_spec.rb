require 'spec_helper'
require 'nokogiri'

describe Jasmine::Formatters::JUnitXml do

  class FakeFile
    def initialize
      @content = ''
    end

    attr_reader :content

    def puts(content)
      @content << content
    end
  end

  let(:file_stub) { FakeFile.new }

  let(:config) { double(:config, :junit_xml_location => '/junit_path/') }

  before do
    File.stub(:open).and_call_original
    File.stub(:open).with('/junit_path/junit_results.xml', 'w').and_yield(file_stub)
  end

  describe '#summary' do
    describe 'when the full suite passes' do
      it 'shows the spec counts' do
        results = [passing_result('fullName' => 'Passing test', 'description' => 'test')]
        subject = Jasmine::Formatters::JUnitXml.new(config)

        subject.format(results)
        subject.done
        xml = Nokogiri::XML(file_stub.content)

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
        results1 = [passing_result]
        results2 = [failing_result]
        subject = Jasmine::Formatters::JUnitXml.new(config)

        subject.format(results1)
        subject.format(results2)
        subject.done
        xml = Nokogiri::XML(file_stub.content)

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
    Jasmine::Result.new(failing_raw_result.merge(options))
  end

  def passing_result(options = {})
    Jasmine::Result.new(passing_raw_result.merge(options))
  end
end
