require 'jasmine'

class JasmineSelfTestConfig < Jasmine::UserConfig
  def project_root
    File.expand_path(File.join(File.dirname(__FILE__), ".."))
  end

  def src_dir
    File.join(project_root, 'src')
  end

  def spec_dir
    Jasmine::Core.path
  end

  def spec_files
    Jasmine::Core.html_spec_files + Jasmine::Core.core_spec_files
  end
end
