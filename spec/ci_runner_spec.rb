require 'spec_helper'

describe Jasmine::CiRunner do
  let(:runner) { double(:runner, :run => nil) }
  let(:runner_factory) { double(:runner_factory, :call => runner) }

  let(:config) do
    double(:configuration,
           :runner => runner_factory,
           :formatters => [],
           :host => 'http://foo.bar.com',
           :port => '1234',
           :rack_options => 'rack options',
           :stop_spec_on_expectation_failure => false,
           :stop_on_spec_failure => false,
           :random => false
          )
  end

  let(:thread_instance) { double(:thread, :abort_on_exception= => nil) }
  let(:fake_thread) do
    thread = double(:thread)
    allow(thread).to receive(:new) do |&block|
      @thread_block = block
      thread_instance
    end
    thread
  end
  let(:application_factory) { double(:application, :app => 'my fake app') }
  let(:fake_server) { double(:server, :start => nil) }
  let(:server_factory) { double(:server_factory, :new => fake_server) }
  let(:outputter) { double(:outputter, :puts => nil) }

  before do
    allow(Jasmine).to receive(:wait_for_listener)
  end

  it 'starts a server and runner' do
    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(config).to have_received(:port).with(:ci).at_least(:once)
    expect(config).not_to have_received(:port).with(:server)

    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\bthrowFailures=false\b/)
    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\bfailFast=false\b/)
    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\brandom=false\b/)

    expect(application_factory).to have_received(:app).with(config)
    expect(server_factory).to have_received(:new).with('1234', 'my fake app', 'rack options')

    expect(fake_thread).to have_received(:new)
    expect(thread_instance).to have_received(:abort_on_exception=).with(true)

    @thread_block.call
    expect(fake_server).to have_received(:start)

    expect(Jasmine).to have_received(:wait_for_listener).with('1234', 'foo.bar.com')

    expect(runner).to have_received(:run)
  end

  it 'instantiates all formatters' do
    class SimpleFormatter1
    end

    class SimpleFormatter2
    end

    expect(config).to receive(:formatters) { [SimpleFormatter1, SimpleFormatter2] }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(anything, anything) do |multi_formatter, url|
      expect_any_instance_of(SimpleFormatter1).to receive(:format)
      expect_any_instance_of(SimpleFormatter2).to receive(:format)

      multi_formatter.format([])
    end
  end

  it 'instantiates formatters with arguments' do
    class SimpleFormatter
      attr_reader :obj
      def initialize(obj)
        @obj = obj
      end
    end

    expect(config).to receive(:formatters) { [SimpleFormatter] }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(anything, anything) do |multi_formatter, url|
      expect_any_instance_of(SimpleFormatter).to receive(:format) do |formatter, results|
        expect(formatter.obj).to eq(config)
      end

      multi_formatter.format([])
    end
  end

  it 'works with formatters that are not classes' do
    class Factory1
      attr_reader :called
      def new
        @called = true
        nil
      end
    end

    class Factory2
      attr_reader :called
      attr_reader :obj
      def new(obj)
        @obj = obj
        @called = true
        nil
      end
    end

    factory1 = Factory1.new
    factory2 = Factory2.new

    expect(config).to receive(:formatters) { [factory1, factory2] }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(factory1.called).to eq(true)
    expect(factory2.called).to eq(true)
    expect(factory2.obj).to eq(config)
  end

  it 'handles optional arguments by only passing config when it is required' do
    class NoConfigFormatter
      attr_reader :optional
      def initialize(optional = {config: 'no'})
        @optional = optional
      end
    end

    class HasConfigFormatter
      attr_reader :obj, :optional
      def initialize(obj, optional = {config: 'no'})
        @obj = obj
        @optional = optional
      end
    end

    class NoConfigFactory
      def initialize(dummy_formatter)
        @dummy_formatter = dummy_formatter
      end
      attr_reader :optional
      def new(optional = {config: 'no'})
        @optional = optional
        @dummy_formatter
      end
    end

    class HasConfigFactory
      def initialize(dummy_formatter)
        @dummy_formatter = dummy_formatter
      end
      attr_reader :obj, :optional
      def new(obj, optional = {config: 'no'})
        @obj = obj
        @optional = optional
        @dummy_formatter
      end
    end

    no_config_factory = NoConfigFactory.new(double(:formatter, format: nil))
    has_config_factory = HasConfigFactory.new(double(:formatter, format: nil))

    expect(config).to receive(:formatters) { [NoConfigFormatter, HasConfigFormatter, no_config_factory, has_config_factory] }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(no_config_factory.optional).to eq({config: 'no'})
    expect(has_config_factory.optional).to eq({config: 'no'})
    expect(has_config_factory.obj).to eq(config)

    expect(runner_factory).to have_received(:call).with(anything, anything) do |multi_formatter, url|
      expect_any_instance_of(NoConfigFormatter).to receive(:format) do |formatter, results|
        expect(formatter.optional).to eq({config: 'no'})
      end

      expect_any_instance_of(HasConfigFormatter).to receive(:format) do |formatter, results|
        expect(formatter.optional).to eq({config: 'no'})
        expect(formatter.obj).to eq(config)
      end

      multi_formatter.format([])
    end
  end

  it 'adds runner boot files when necessary' do
    expect(runner).to receive(:boot_js).at_least(:once) { 'foo/bar/baz.js' }
    expect(config).to receive(:runner_boot_dir=).with('foo/bar')
    expect(config).to receive(:runner_boot_files=) do |proc|
      expect(proc.call).to eq ['foo/bar/baz.js']
    end

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run
  end

  it 'returns true for a successful run' do
    allow(Jasmine::Formatters::ExitCode).to receive(:new) { double(:exit_code, :succeeded? => true) }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    expect(ci_runner.run).to be(true)
  end

  it 'returns false for a failed run' do
    allow(Jasmine::Formatters::ExitCode).to receive(:new) { double(:exit_code, :succeeded? => false) }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    expect(ci_runner.run).to be(false)
  end

  it 'can tell the jasmine page to throw expectation failures' do
    allow(config).to receive(:stop_spec_on_expectation_failure) { true }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\bthrowFailures=true\b/)
  end

  it 'can tell the jasmine page to fail fast' do
    allow(config).to receive(:stop_on_spec_failure) { true }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\bfailFast=true\b/)
  end

  it 'can tell the jasmine page to randomize' do
    allow(config).to receive(:random) { true }

    ci_runner = Jasmine::CiRunner.new(config, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\brandom=true\b/)
  end

  it 'allows randomization to be turned on, overriding the config' do
    allow(config).to receive(:random) { false }

    ci_runner = Jasmine::CiRunner.new(config, random: true, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\brandom=true\b/)
  end

  it 'allows randomization to be turned off, overriding the config' do
    allow(config).to receive(:random) { true }

    ci_runner = Jasmine::CiRunner.new(config, random: false, thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\brandom=false\b/)
  end

  it 'allows a randomization seed to be specified' do
    ci_runner = Jasmine::CiRunner.new(config, seed: '4231', thread: fake_thread, application_factory: application_factory, server_factory: server_factory, outputter: outputter)

    ci_runner.run

    expect(runner_factory).to have_received(:call).with(instance_of(Jasmine::Formatters::Multi), /\bseed=4231\b/)
  end
end
