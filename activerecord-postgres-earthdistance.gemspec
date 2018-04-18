# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib/", __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = "activerecord-postgres-earthdistance"
  s.version = "0.7.0"

  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Diogo Biazus"]
  s.email       = "diogo@biazus.me"
  s.homepage    = "http://github.com/diogob/activerecord-postgres-earthdistance"
  s.summary     = "Check distances with latitude and longitude using PostgreSQL special indexes"
  s.description = "This gem enables your model to query the database using the earthdistance \
                  extension. This should be much faster than using trigonometry functions over\
                  standart indexs."
  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "activerecord", ">= 3.1"
  s.add_dependency "rake"
  s.add_dependency "pg"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rspec"
  s.add_development_dependency "pry"

  git_files            = begin
                           `git ls-files`.split("\n")
                         rescue
                           ""
                         end
  s.files              = git_files
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = []
  s.require_paths      = %w(lib)
end
