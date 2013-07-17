class FakeSeleniumDriver
  attr_reader :results

  def initialize
    @state = :stopped
    @results = [ {'id' => 1}, {'id' => 2}, {'id' => 3}, {'id' => 4} ]
  end

  def eval_js(str)

    case str
      when Jasmine::Reporters::ApiReporter::STARTED_JS
        @state == :started
      when Jasmine::Reporters::ApiReporter::FINISHED_JS
        @state == :finished
      else
        # TODO: When we drop support for Ruby < 1.9, USE NAMED CAPTURES HEYAH
        if matches = /specResults\((\d+), (\d+)\)/.match(str)
          length = matches[1]
          index = matches[2]
          slice = @results.slice(length.to_i, length.to_i + index.to_i)

          slice.nil? ? [] : slice
        end
    end
  end

  def start
    @state = :started
  end

  def finish
    @state = :finished
  end
end
