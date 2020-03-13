module Jasmine
  class CiRunner
    def initialize(config, options={})
      @config = config
      @thread = options.fetch(:thread, Thread)
      @application_factory = options.fetch(:application_factory, Jasmine::Application)
      @server_factory = options.fetch(:server_factory, Jasmine::Server)
      @outputter = options.fetch(:outputter, Kernel)
      @random = options.fetch(:random, config.random)
      @seed = options.has_key?(:seed) ? "&seed=#{options[:seed]}" : ''
    end

    def run
      formatters = build_formatters
      exit_code_formatter = Jasmine::Formatters::ExitCode.new
      formatters << exit_code_formatter

      url = "#{config.host}:#{config.port(:ci)}/?throwFailures=#{config.stop_spec_on_expectation_failure}&failFast=#{config.stop_on_spec_failure}&random=#{@random}#{@seed}"
      runner = config.runner.call(Jasmine::Formatters::Multi.new(formatters), url)

      if runner.respond_to?(:boot_js)
        config.runner_boot_dir = File.dirname(runner.boot_js)
        config.runner_boot_files = lambda { [runner.boot_js] }
      end

      server = @server_factory.new(config.port(:ci), app, config.rack_options)

      t = @thread.new do
        server.start
      end
      t.abort_on_exception = true

      Jasmine::wait_for_listener(config.port(:ci), config.host.sub(/\Ahttps?:\/\//, ''))
      @outputter.puts 'jasmine server started'

      runner.run

      exit_code_formatter.succeeded?
    end

    private

    attr_reader :config

    def app
      @application_factory.app(@config)
    end

    def build_formatters
      config.formatters.map do |formatter_class|
        meta_method = if formatter_class.class == Class
                        formatter_class.instance_method(:initialize)
                      else
                        formatter_class.method(:new)
                      end

        if meta_method.arity == 0 || meta_method.parameters[0][0] != :req
          formatter_class.new
        else
          formatter_class.new(config)
        end
      end
    end
  end
end
