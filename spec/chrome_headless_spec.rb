require 'spec_helper'

describe Jasmine::Runners::ChromeHeadless do

  let(:config) {
    {
      show_console_log: nil,
      show_full_stack_trace: nil,
      chrome_cli_options: nil,
      chrome_binary: nil,
    }
  }

  it 'uses chrome_binary from config is set' do
    config[:chrome_binary] = "some_path"
    runner = Jasmine::Runners::ChromeHeadless.new(nil, nil, double(config))

    expect(runner.chrome_binary).to eq("some_path")
  end

  it 'uses chrome_binary from default chrome path if it exist' do
    allow(File).to receive(:file?).and_return(true)
    runner = Jasmine::Runners::ChromeHeadless.new(nil, nil, double(config))

    expect(runner.chrome_binary).to eq("/usr/bin/google-chrome")
  end

  it 'chrome_binary raise an exeption if nowhere to be found' do
    allow(File).to receive(:file?).and_return(false)
    runner = Jasmine::Runners::ChromeHeadless.new(nil, nil, double(config))

    expect {
      runner.chrome_binary
    }.to raise_error(RuntimeError)
  end

  describe "cli_options_string" do
    it "empty hash is empty result" do
      runner = Jasmine::Runners::ChromeHeadless.new(nil, nil, double(config))
      expect(runner.cli_options_string).to eq("")
    end

    it "formats hash properly" do
      config[:chrome_cli_options] = {"no-sandbox" => nil, "headless" => nil, "remote-debugging-port" => 9222}
      runner = Jasmine::Runners::ChromeHeadless.new(nil, nil, double(config))
      expect(runner.cli_options_string).to eq("--no-sandbox --headless --remote-debugging-port=9222")
    end
  end

end
