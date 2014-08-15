puts $LOAD_PATH.inspect

$LOAD_PATH.clear
$LOAD_PATH << "/System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/lib/ruby/2.0.0"

=begin
module Kernel
  private
  alias emb_ruby_require require
  alias emb_ruby_laod load
  class << self
    alias emb_ruby_require require
    alias emb_ruby_load load
  end

  def require(name)
    if memory_require(name) == false

    end
  end

  def load(name, *rest, &block)

  module_function :require
  module_function :load
end
=end

puts load "#{$LOAD_PATH.first}/base64.rb"

File.open("toto")
