require 'rubygems'
require 'bundler'
require 'stringio'
require 'tmpdir'

envs = [:default, :development]
envs << :debug if ENV['DEBUG']
Bundler.setup(*envs)

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
require 'jasmine'

if Jasmine::Dependencies.rspec2?
  require 'rspec'
else
  require 'spec'
end

require 'support/fake_selenium_driver'

def create_rails(name)
  if Jasmine::Dependencies.rails3?
    `rails new #{name}`
  else
    `rails #{name}`
  end
end

def create_temp_dir
  tmp = File.join(Dir.tmpdir, "jasmine-gem-test_#{Time.now.to_f}")
  FileUtils.rm_r(tmp, :force => true)
  FileUtils.mkdir(tmp)
  tmp
end

def temp_dir_before
  @root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  @old_dir = Dir::pwd
  @tmp = create_temp_dir
end

def temp_dir_after
  Dir::chdir @old_dir
  FileUtils.rm_r @tmp
end

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end
end

def passing_raw_result
  raw_result('passed', {fullName: 'Passing test', description: 'Passing'})
end

def pending_raw_result
  raw_result('pending', {fullName: 'Passing test', description: 'Passing'})
end

def failing_raw_result
  raw_result('failed', {
      'id' => 124,
      'description' => 'a failing spec',
      'fullName' => 'a suite with a failing spec',
      'failedExpectations' => [
          {
              'message' => 'a failure message',
              'stack' => 'a stack trace'
          }
      ]
  })
end

def raw_result(status, options = {})
  {'status' => status}.merge(options)
end

