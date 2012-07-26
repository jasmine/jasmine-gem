module Jasmine
  class RunnerConfig
    def initialize(config = Jasmine::Config.new)
      @config = config
    end

    def css_files
      @config.jasmine_stylesheets + @config.user_stylesheets
    end

    def jasmine_files
      @config.jasmine_javascripts
    end

    def js_files
      @config.js_files
    end

    def spec_files
      @config.spec_files
    end

    def spec_files_full_paths
      @config.spec_files_full_paths
    end

    def spec_path
      @config.spec_path
    end

    def spec_dir
      @config.spec_dir
    end

    def src_dir
      @config.src_dir
    end

    def project_root
      @config.project_root
    end

    def root_path
      @config.root_path
    end

    def browser
      ENV["JASMINE_BROWSER"] || 'firefox'
    end

    def jasmine_host
      ENV["JASMINE_HOST"] || 'http://localhost'
    end

    def port
      @port ||= ENV["JASMINE_PORT"] || Jasmine.find_unused_port
    end

  end
end
