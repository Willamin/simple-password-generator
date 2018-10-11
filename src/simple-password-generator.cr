require "stdimp/string/puts"

module SimplePasswordGenerator
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}
end

class Options
  property length : Int32 = 64
  property count : Int32 = 1
  property range : Range(Int32, Int32) = 33..126
end

require "option_parser"
o = Options.new
OptionParser.parse! do |parser|
  parser.banner = "usage: spg [password_length] [num_passwords]"
  parser.on("-h", "--help", "show this help") { puts parser; exit }

  # add more range options in the future
  parser.on("-a", "--ascii", "only use printable ASCII characters") { o.range = 33..126 }
  parser.on("-n", "--number", "only use numbers") { o.range = 48..57 }

  parser.unknown_args do |args|
    o.length = args[0]?.try(&.to_i) || 64
    o.count = args[1]?.try(&.to_i) || 1
  end
end

o.count.times do
  b = Bytes.new(o.length)
  Random::Secure.random_bytes(b)
  String.build do |builder|
    b.each do |byte|
      byte &= 0x7F
      byte = byte % (o.range.end - o.range.begin + 1) + o.range.begin
      builder << byte.chr
    end
  end.puts
end
