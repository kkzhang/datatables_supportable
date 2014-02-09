# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datatables_supportable/version'

Gem::Specification.new do |spec|
  spec.name          = "datatables_supportable"
  spec.version       = DatatablesSupportable::VERSION
  spec.authors       = ["kkzhang"]
  spec.email         = [""]
  spec.summary       = %q{make activerecord support datatables ajax mode}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "activerecord"
  spec.add_runtime_dependency "actionpack"
end
