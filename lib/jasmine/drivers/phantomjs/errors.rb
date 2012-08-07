 module Jasmine::Drivers
  class Phantomjs
    class Error < StandardError
    end

    class ClientError < Error
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end

    class JSErrorItem
      attr_reader :message, :stack

      def initialize(message, stack)
        @message = message
        @stack   = stack
      end

      def to_s
        stack
      end
    end

    class BrowserError < ClientError
      def name
        response['name']
      end

      def javascript_error
        JSErrorItem.new(*response['args'])
      end

      def message
        "There was an error inside the PhantomJS portion of Poltergeist:\n\n#{javascript_error}"
      end
    end

    class JavascriptError < ClientError
      def javascript_errors
        response['args'].first.map { |data| JSErrorItem.new(data['message'], data['stack']) }
      end

      def message
        "One or more errors were raised in the Javascript code on the page:\n\n" +
          javascript_errors.map(&:to_s).join("\n")
      end
    end

    class DeadClient < Error
      def initialize(message)
        @message = message
      end

      def message
        "The PhantomJS client died while processing #{@message}"
      end
    end

    class PhantomJSTooOld < Error
      attr_reader :version

      def initialize(version)
        @version = version
      end

      def message
        "PhantomJS version #{version} is too old. You must use at least version #{Client::PHANTOMJS_VERSION}"
      end
    end
  end
end