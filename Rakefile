# encoding: utf-8
# --
# The MIT License (MIT)
#
# Copyright (C) 2012 Gitorious AS
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++
require "rake/testtask"
require "ci/reporter/rake/minitest"
begin
  require "bundler/gem_tasks"
rescue LoadError => e
  # The bundler package in RHEL 6's ruby193 SCL will break when attempting to
  # load vendored thor. Tested on ruby193-rubygem-bundler-1.1.4-3.el6.noarch.
  if e.message != 'cannot load such file -- thor'
    raise
  end
end


Rake::TestTask.new("test") do |test|
  test.libs << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end

if RUBY_VERSION < "1.9"
  require "rcov/rcovtask"
  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.test_files = FileList["test/**/*_test.rb"]
    t.rcov_opts += %w{--exclude gems,ruby/1.}
  end
end

task :default => :test
