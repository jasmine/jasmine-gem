require "spec/example/example_methods"
module Spec
  module Example
    module ExampleMethods
      def execute(run_options, instance_variables) # :nodoc:
        run_options.reporter.example_started(@_proxy)
        set_instance_variables_from_hash(instance_variables)

        execution_error = nil
        Timeout.timeout(run_options.timeout) do
          begin
            before_each_example
            instance_eval(&@_implementation)
          rescue Interrupt
            exit 1
          rescue Exception => e
            e.backtrace.unshift @_proxy.location  #Adding these 2 lines here to pre-pend the JS stack on top of the
            e.backtrace.flatten!
            e.backtrace.compact!                 #ruby stack trace
            execution_error ||= e
          end
          begin
            after_each_example
          rescue Interrupt
            exit 1
          rescue Exception => e
            execution_error ||= e
          end
        end

        run_options.reporter.example_finished(@_proxy.update(description), execution_error)
        success = execution_error.nil? || ExamplePendingError === execution_error
      end
    end
  end
end
