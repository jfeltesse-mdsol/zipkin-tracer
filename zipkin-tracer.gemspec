# -*- encoding: utf-8 -*-
# Copyright 2012 Twitter Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'zipkin-tracer/version'

Gem::Specification.new do |s|
  s.name                      = "zipkin-tracer"
  s.version                   = ZipkinTracer::VERSION
  s.authors                   = ["Franklin Hu", "R Tyler Croy"]
  s.email                     = ["franklin@twitter.com", 'tyler@monkeypox.org']
  s.homepage                  = 'https://github.com/openzipkin/zipkin-tracer'
  s.summary                   = "Ruby tracing via Zipkin"
  s.description               = "Adds tracing instrumentation for ruby applications"

  s.required_rubygems_version = ">= 1.3.5"

  s.files                     = Dir.glob("{bin,lib}/**/*")
  s.require_path              = 'lib'

  s.add_dependency "finagle-thrift", "~> 1.3.0"
  s.add_dependency "scribe", "~> 0.2.4"
  s.add_dependency "rack"

  s.add_development_dependency "rspec", "~> 3.0.0"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "rake"
  s.add_development_dependency "thin" # allow testing with thrift v0.9.1
end
