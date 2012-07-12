module Jasmine
  class Config
    require 'yaml'
    require 'erb'

    def match_files(dir, patterns)
      dir = File.expand_path(dir)
      negative, positive = patterns.partition {|pattern| /^!/ =~ pattern}
      chosen, negated = [positive, negative].collect do |patterns|
        patterns.collect do |pattern|
          matches = Dir.glob(File.join(dir, pattern.gsub(/^!/,'')))
          matches.empty? && !(pattern =~ /\*|^\!/) ? pattern : matches.collect {|f| f.sub("#{dir}/", "")}.sort
        end.flatten.uniq
      end
      chosen - negated
    end

    def simple_config
      config = File.exist?(simple_config_file) ? YAML::load(ERB.new(File.read(simple_config_file)).result(binding)) : false
      config || {}
    end


    def spec_path
      "/__spec__"
    end

    def root_path
      "/__root__"
    end

    def js_files(spec_filter = nil)
      spec_files_to_include = spec_filter.nil? ? spec_files : match_files(spec_dir, [spec_filter])
      src_files.collect {|f| "/" + f } + helpers.collect {|f| File.join(spec_path, f) } + spec_files_to_include.collect {|f| File.join(spec_path, f) }
    end

    def user_stylesheets
      stylesheets.collect {|f| "/" + f }
    end

    def spec_files_full_paths
      spec_files.collect {|spec_file| File.join(spec_dir, spec_file) }
    end

    def project_root
      Dir.pwd
    end

    def simple_config_file
      File.join(project_root, 'spec/javascripts/support/jasmine.yml')
    end

    def src_dir
      if simple_config['src_dir']
        File.join(project_root, simple_config['src_dir'])
      else
        project_root
      end
    end

    def spec_dir
      if simple_config['spec_dir']
        File.join(project_root, simple_config['spec_dir'])
      else
        File.join(project_root, 'spec/javascripts')
      end
    end

    def helpers
      if simple_config['helpers']
        match_files(spec_dir, simple_config['helpers'])
      else
        match_files(spec_dir, ["helpers/**/*.js"])
      end
    end

    def src_files
      if simple_config['src_files'] && Jasmine::Dependencies.rails_3_asset_pipeline?
        Jasmine::AssetPipelineMapper.new(simple_config['src_files']).files
      elsif simple_config['src_files']
        match_files(src_dir, simple_config['src_files'])
      else
        []
      end
    end

    def spec_files
      if simple_config['spec_files']
        match_files(spec_dir, simple_config['spec_files'])
      else
        match_files(spec_dir, ["**/*[sS]pec.js"])
      end
    end

    def stylesheets
      if simple_config['stylesheets']
        match_files(src_dir, simple_config['stylesheets'])
      else
        []
      end
    end

    def jasmine_stylesheets
      ::Jasmine::Core.css_files.map {|f| "/__JASMINE_ROOT__/#{f}"}
    end

    def jasmine_javascripts
      ::Jasmine::Core.js_files.map {|f| "/__JASMINE_ROOT__/#{f}" }
    end
  end
end
