module Jasmine
  class CommandLineTool
    def root_dir
      File.expand_path('../../..', __FILE__)
    end

    def install_path
      File.join(root_dir, "lib", "jasmine", "command_line_install.txt")
    end

    def dest_path(filepath)
      File.join(Dir.pwd, filepath)
    end

    def copy_file_structure(generator)
      source_dir = File.join(root_dir, 'lib', 'generators', 'jasmine', generator, 'templates')
      dest_dir = Dir.pwd

      globber = File.join(source_dir, '**', '{*,.*}')
      source_files = Dir.glob(globber).reject { |path| File.directory?(path) }
      source_files.each do |source_path|
        relative_path = source_path.sub(source_dir, '')
        dest_path = File.join(dest_dir, relative_path).sub(/app[\/\\]assets/, 'public')
        unless File.exist?(dest_path)
          FileUtils.mkdir_p(File.dirname(dest_path))
          FileUtils.copy(source_path, dest_path)
          if File.basename(dest_path) == 'jasmine.yml'
            replaced = File.read(dest_path).gsub("assets/application.js", "public/javascripts/**/*.js")
            File.open(dest_path, 'w') do |file|
              file.write(replaced)
            end
          end
        end
      end
    end

    def process(argv)
      if argv[0] == 'init'
        require 'fileutils'

        force = false

        if argv.size > 1 && argv[1] == "--force"
          force = true
        end

        if File.exist?("Gemfile") && open("Gemfile", 'r').read.include?('rails') && !force
          puts <<-EOF

  You're attempting to run jasmine init in a Rails project. You probably want to use the Rails generator like so:
      rails g jasmine:init

  If you're not actually in a Rails application, just run this command again with --force
      jasmine init --force
          EOF
          exit 1
        end

        copy_file_structure('install')

        require 'rake'
        write_mode = 'w'
        if File.exist?(dest_path('Rakefile'))
          load dest_path('Rakefile')
          write_mode = 'a'
        end

        unless Rake::Task.task_defined?('jasmine')
          File.open(dest_path('Rakefile'), write_mode) do |f|
            f.write(<<-JASMINE_RAKE)
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'
JASMINE_RAKE
          end
        end
        puts File.read(install_path)
      elsif argv[0] == "examples"
        copy_file_structure('examples')

        puts "Jasmine has installed some examples."
      elsif argv[0] == "license"
        puts File.read(File.join(root_dir, "MIT.LICENSE"))
      else
        puts "unknown command #{argv}"
        puts "Usage: jasmine init"
        puts "               examples"
        puts "               license"
      end
    end
  end
end
