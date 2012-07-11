module Jasmine
  class RunnerConfig
    def initialize(user_config)
      @user_config = user_config
    end

    def css_files
      @user_config.jasmine_stylesheets + @user_config.user_stylesheets
    end

    def jasmine_files
      @user_config.jasmine_javascripts
    end

    def js_files
      @user_config.js_files
    end

    def spec_files
      @user_config.spec_files
    end

    def spec_files_full_paths
      @user_config.spec_files_full_paths
    end

    def spec_path
      @user_config.spec_path
    end

    def spec_dir
      @user_config.spec_dir
    end

    def src_dir
      @user_config.src_dir
    end

    def project_root
      @user_config.project_root
    end

    def root_path
      @user_config.root_path
    end
  end
end
