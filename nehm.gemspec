# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nehm/version'

Gem::Specification.new do |spec|
  spec.name    = 'nehm'
  spec.version = Nehm::VERSION
  spec.authors = ['Albert Nigmatzianov']
  spec.email   = ['albertnigma@gmail.com']

  spec.summary     = 'Convenient way to download tracks (and add them to iTunes) from SoundCloud via terminal'
  spec.description = 'nehm is a console tool, which downloads, sets IDv3 tags (and adds to your iTunes library) your SoundCloud posts or likes in convenient way. See homepage for instructions'
  spec.homepage    = 'http://www.github.com/bogem/nehm'
  spec.license     = 'MIT'

  spec.files                 = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(Pictures|Rakefile)/}) }
  spec.bindir                = 'bin'
  spec.executables           = 'nehm'
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 1.9.3'
  spec.post_install_message  = "Don't forget to install Taglib from OS' package manager!"

  spec.add_dependency 'certifi'
  spec.add_dependency 'colored'
  spec.add_dependency 'taglib-ruby', '>= 0.7.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
