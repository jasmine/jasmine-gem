require 'nokogiri'

module Jasmine
  module Formatters
    class JUnitXml < BaseFormatter
      def format
        f = open(File.join(Jasmine.config.junit_xml_location, 'junit_results.xml'), 'w')
        f.puts summary
        f.close()
      end

      def summary
        doc = Nokogiri::XML '<testsuites></testsuites>', nil, 'UTF-8'

        testsuites = doc.at_css('testsuites')

        results.results.each do |result|
          suite_name = result.full_name.slice(0, result.full_name.size - result.description.size - 1)

          testsuite = Nokogiri::XML::Node.new 'testsuite', doc
          testsuite['tests'] = 1
          testsuite['failures'] = result.status == 'failed' ? 1 : 0
          testsuite['errors'] = 0
          testsuite['name'] = suite_name
          testsuite.parent = testsuites

          testcase = Nokogiri::XML::Node.new 'testcase', doc
          testcase['name'] = result.description

          if result.status == 'failed'
            result.failed_expectations.each do |failed_exp|
              failure = Nokogiri::XML::Node.new 'failure', doc
              failure['message'] = failed_exp.message
              failure['type'] = 'Failure'
              failure.content = failed_exp.stack
              failure.parent = testcase
            end
          end

          testcase.parent = testsuite
        end

        doc.to_xml(indent: 2)
      end
    end
  end
end