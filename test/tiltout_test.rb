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
require "bundler/setup"
require "minitest/autorun"
require "mocha"
require "tiltout"

module ViewHelper
  def say_it; "YES"; end
end

describe Tiltout do
  before { @root = "/dolt/views" }

  it "reads template from file" do
    File.expects(:read).with("/dolt/views/file.erb").returns("")
    renderer = Tiltout.new("/dolt/views")
    renderer.render(:file)
  end

  it "renders template with locals" do
    File.stubs(:read).returns("<%= name %>!")
    renderer = Tiltout.new(@root)

    assert_equal "Chris!", renderer.render(:file, { :name => "Chris"})
  end

  it "caches template in memory" do
    renderer = Tiltout.new(@root)
    File.stubs(:read).returns("Original")
    renderer.render(:file)
    File.stubs(:read).returns("Updated")

    assert_equal "Original", renderer.render(:file)
  end

  it "does not cache template in memory when configured not to" do
    renderer = Tiltout.new(@root, :cache => false)
    File.stubs(:read).returns("Original")
    renderer.render(:file)
    File.stubs(:read).returns("Updated")

    assert_equal "Updated", renderer.render(:file)
  end

  it "renders template with layout" do
    renderer = Tiltout.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns("Template")
    File.stubs(:read).with("/layout.erb").returns("I give you: <%= yield %>")

    assert_equal "I give you: Template", renderer.render(:file)
  end

  it "renders template once without layout" do
    renderer = Tiltout.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns("Template")
    File.stubs(:read).with("/layout.erb").returns("I give you: <%= yield %>")

    assert_equal "Template", renderer.render(:file, {}, :layout => nil)
  end

  it "renders template once with different layout" do
    renderer = Tiltout.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns("Template")
    File.stubs(:read).with("/layout.erb").returns("I give you: <%= yield %>")
    File.stubs(:read).with("/layout2.erb").returns("I present you: <%= yield %>")

    html = renderer.render(:file, {}, :layout => "layout2")

    assert_equal "I present you: Template", html
  end

  it "renders templates of default type" do
    renderer = Tiltout.new("/", :default_type => :str)
    File.stubs(:read).with("/file.str").returns("Hey!")

    assert_equal "Hey!", renderer.render(:file)
  end

  it "renders templates of specific type" do
    renderer = Tiltout.new("/", :default_type => :lol)
    File.stubs(:read).with("/file.lol").returns("No!")
    File.stubs(:read).with("/file.erb").returns("Yes!")
    File.stubs(:exists?).with("/file.lol").returns(false)
    File.stubs(:exists?).with("/file.erb").returns(true)

    assert_equal "Yes!", renderer.render("file.erb")
  end

  it "renders with helper object" do
    renderer = Tiltout.new("/")
    renderer.helper(ViewHelper)
    File.stubs(:read).with("/file.erb").returns("Say it: <%= say_it %>")

    assert_equal "Say it: YES", renderer.render(:file)
  end

  it "does not leak state across render calls" do
    renderer = Tiltout.new("/")
    File.stubs(:read).with("/file.erb").returns(<<-TEMPLATE)
<%= @response %><% @response = "NO" %><%= @response %>
    TEMPLATE

    assert_equal "NO", renderer.render(:file)
    assert_equal "NO", renderer.render(:file)
  end

  it "shares state between template and layout" do
    renderer = Tiltout.new("/", :layout => "layout")
    File.stubs(:read).with("/file.erb").returns(<<-TEMPLATE)
<% @response = "NO" %><h1><%= @response %></h1>
    TEMPLATE
    tpl = "<title><%= @response %></title><%= yield %>"
    File.stubs(:read).with("/layout.erb").returns(tpl)

    assert_equal "<title>NO</title><h1>NO</h1>\n", renderer.render(:file)
  end
end
