source "http://rubygems.org"
gemspec

unless ENV["TRAVIS"]
  group :debug do
    # curl -OL http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem
    # curl -OL http://rubyforge.org/frs/download.php/75415/ruby-debug-base19-0.11.26.gem
    # # Replace with your ruby path if necessary
    # gem install linecache19-0.5.13.gem ruby-debug-base19-0.11.26.gem -- --with-ruby-include=$rvm_path/src/ruby-1.9.3-p125/
    # rm linecache19-0.5.13.gem ruby-debug-base19-0.11.26.gem
    gem 'linecache19', '0.5.13'
    gem 'ruby-debug-base19', '0.11.26'
    gem 'ruby-debug19', :require => 'ruby-debug'
  end
end
