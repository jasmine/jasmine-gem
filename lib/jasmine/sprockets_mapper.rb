class Jasmine::SprocketsMapper
  def initialize(context, mount_point = 'assets')
    @context = context
    @mount_point = mount_point
  end

  def files(src_files)
    src_files.map do |src_file|
      filename = src_file.gsub(/^assets\//, '').gsub(/\.js$/, '')
      @context.find_asset(filename).to_a.map(&:logical_path).map(&:to_s)
    end.flatten.uniq.map{|path| File.join(@mount_point, path).to_s + "?body=true"}
  end
end
