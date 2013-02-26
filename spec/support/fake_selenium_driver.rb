class FakeSeleniumDriver
  def initialize
    @state = :stopped
    @results = [ {'id' => 1}, {'id' => 2}, {'id' => 3}, {'id' => 4} ]
  end

  def eval_js(str)

    case str
      when Jasmine::Runners::ApiReporter::STARTED_JS
        @state == :started
      when Jasmine::Runners::ApiReporter::FINISHED_JS
        @state == :finished
      else
        if matches = /specResults\((?<index>\d+), (?<length>\d+)\)/.match(str)
          slice = @results.slice(matches[:index].to_i, matches[:index].to_i + matches[:length].to_i)

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
