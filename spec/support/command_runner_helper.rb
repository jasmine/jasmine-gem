module CommandRunnerHelper
  def run_command(command)
    puts "Running command: #{command}" if verbose?
    `#{command} #{("2>&1" unless verbose?)}`
  end

  def run_command!(command)
    output = run_command(command)
    puts output if verbose?
    $?.should be_success, "Command failed: #{command}"
    output
  end

  def verbose?
    !ENV["VERBOSE"].nil?
  end
end

RSpec.configure do |c|
  c.include CommandRunnerHelper
end
