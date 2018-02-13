
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sherpa/version"

Gem::Specification.new do |spec|
  spec.name          = "sherpa"
  spec.version       = Sherpa::VERSION
  spec.authors       = ["g.edera"]
  spec.email         = ["gab.edera@gmail.com"]

  spec.summary       = %q{Sherpa automatic tv series downloader}
  spec.description   = %q{Ruby script to fetch torrents from rss, after download feth the subtitles and copy in your media senter after. After all send a message to telegram}
  spec.homepage      = "https://github.com/gedera/sherpa"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_dependency "nori", "~> 2.6"
  spec.add_dependency "nokogiri", "~> 1.8"
  spec.add_dependency "sqlite3", "~> 1.3"
  spec.add_dependency "addic7ed", "~> 3.0"
end
