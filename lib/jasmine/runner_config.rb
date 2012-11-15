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

    def reporters_path
      @config.reporters_path
    end
	
    def reporters_dir
      @config.reporters_dir
    end
	
    def reporters_files
      @config.reporters_files
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

    def port
      @config.port
    end

    def jasmine_server_url
      "#{@config.jasmine_host}:#{@config.port}/"
    end

    def src_mapper=(context)
      @config.src_mapper = context
    end

    def src_mapper
      @config.src_mapper
    end

    def result_batch_size
      ENV["JASMINE_RESULT_BATCH_SIZE"] ? ENV["JASMINE_RESULT_BATCH_SIZE"].to_i : 50
    end
  end
end
