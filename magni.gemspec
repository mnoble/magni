Gem::Specification.new do |s|
  s.name = "magni"
  s.version = "0.1.1"
  
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matte Noble"]
  s.email = "me@mattenoble.com"
  s.homepage = "http://github.com/mnoble/magni"
  s.date = "2010-03-23"
  s.description = "Simple command line flag parser."
  s.summary = "Simple command line flag parser."
  
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "lib/magni.rb"]
  s.rdoc_options = ["--charset=UTF-8"]
  
  s.require_paths = ["lib"]
  s.test_files = ["spec/spec_helper.rb", "spec/magni_spec.rb"]
end