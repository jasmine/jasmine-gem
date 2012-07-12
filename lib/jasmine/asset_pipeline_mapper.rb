class Jasmine::AssetPipelineMapper

  def self.context
    context = ::Rails.application.assets.context_class
    context.extend(::Sprockets::Helpers::IsolatedHelper)
    context.extend(::Sprockets::Helpers::RailsHelper)
  end

  def initialize(src_files, context = Jasmine::AssetPipelineMapper.context)
    @src_files = src_files
    @context = context
  end

  def files
    @src_files.map do |src_file|
    filename = src_file.gsub(/^assets\//, '').gsub(/\.js$/, '')
    @context.asset_paths.asset_for(filename, 'js').to_a.map { |p| @context.asset_path(p).gsub(/^\//, '') + "?body=true" }
    end.flatten.uniq
  end
end
