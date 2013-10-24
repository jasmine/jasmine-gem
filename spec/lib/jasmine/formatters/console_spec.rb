require 'spec_helper'

describe Jasmine::Formatters::Console do

  let(:outputter_output) { '' }
  let(:outputter) do
    double(:outputter).tap do |o|
      o.stub(:print) { |str| outputter_output << str }
      o.stub(:puts) { |str| outputter_output << "#{str}\n" }
    end
  end

  describe '#summary' do
    it 'shows the failure messages' do
      results = [failing_result, failing_result]
      formatter = Jasmine::Formatters::Console.new(outputter)
      formatter.format(results)
      formatter.done
      outputter_output.should match(/a suite with a failing spec/)
      outputter_output.should match(/a failure message/)
      outputter_output.should match(/a stack trace/)
    end

    describe 'when the full suite passes' do
      it 'shows the spec counts' do
        results = [passing_result]
        console = Jasmine::Formatters::Console.new(outputter)
        console.format(results)
        console.done

        outputter_output.should match(/1 spec/)
        outputter_output.should match(/0 failures/)
      end

      it 'shows the spec counts (pluralized)' do
        results = [passing_result, passing_result]
        console = Jasmine::Formatters::Console.new(outputter)
        console.format(results)
        console.done

        outputter_output.should match(/2 specs/)
        outputter_output.should match(/0 failures/)
      end
    end

    describe 'when there are failures' do
      it 'shows the spec counts' do
        results = [passing_result, failing_result]
        console = Jasmine::Formatters::Console.new(outputter)
        console.format(results)
        console.done

        outputter_output.should match(/2 specs/)
        outputter_output.should match(/1 failure/)
      end

      it 'shows the spec counts (pluralized)' do
        results = [failing_result, failing_result]
        console = Jasmine::Formatters::Console.new(outputter)
        console.format(results)
        console.done

        outputter_output.should match(/2 specs/)
        outputter_output.should match(/2 failures/)
      end
    end

    describe 'when there are pending specs' do
      it 'shows the spec counts' do
        results = [passing_result, pending_result]
        console = Jasmine::Formatters::Console.new(outputter)
        console.format(results)
        console.done

        outputter_output.should match(/1 pending spec/)
      end

      it 'shows the spec counts (pluralized)' do
        results = [pending_result, pending_result]
        console = Jasmine::Formatters::Console.new(outputter)
        console.format(results)
        console.done

        outputter_output.should match(/2 pending specs/)
      end
    end

    describe 'when there are no pending specs' do

      it 'should not mention pending specs' do
        results = [passing_result]
        console = Jasmine::Formatters::Console.new(outputter)
        console.format(results)
        console.done

        outputter_output.should_not match(/pending spec[s]/)
      end
    end
  end

  def failing_result
    Jasmine::Result.new(failing_raw_result)
  end

  def passing_result
    Jasmine::Result.new(passing_raw_result)
  end

  def pending_result
    Jasmine::Result.new(pending_raw_result)
  end
end
