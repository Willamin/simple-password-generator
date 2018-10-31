require "stdimp/string/puts"
require "option_parser"

class OptionParser
  def arg(option : String, description : String)
    append_flag(option, description)
  end
end

module SimplePasswordGenerator
  alias RangeSet = Set(Range(Int32, Int32))
  VERSION       = {{ `shards version #{__DIR__}`.chomp.stringify }}
  ASCII         = CharSet.new(33..126)
  UPPER_LETTERS = CharSet.new(65..90)
  LOWER_LETTERS = CharSet.new(99..122)
  NUMBERS       = CharSet.new(48..57)
  NONE          = CharSet.new

  class CharSet
    getter chars : Array(Char) = [] of Char

    def initialize; end

    def initialize(range : Range)
      range.each do |char|
        if (0..128).includes?(char)
          @chars << char.unsafe_chr
        end
      end
      @chars.uniq.sort!
    end

    def initialize(@chars : Array(Char)); end

    def |(other : CharSet)
      CharSet.new((@chars + other.chars).sort.uniq)
    end
  end

  class Options
    property length : Int32 = 64
    property count : Int32 = 1
    property ranges = NONE
  end

  def self.main
    o = handle_args
    o.count.times { generate_password(o) }
  end

  macro parse_range(short, long, desc, *ranges)
    parser.on({{short}}, {{long}}, {{desc}}) do
      {% for range in ranges %}
      o.ranges = o.ranges | {{range}}
      {% end %}
    end
  end

  def self.arg_try(args, arg_num, default) : Int32
    a = args[arg_num]?
    a.try do |a|
      return a.to_i
    end
    default
  rescue e : ArgumentError
    STDERR.puts("WARNING: #{a} ignored")
    default
  end

  def self.handle_args
    Options.new.tap do |o|
      OptionParser.parse! do |parser|
        parser.banner = "usage: spg [password_length] [num_passwords]"

        parser.arg("password_length", "the length of the passwords; defaults to 64 if left blank")
        parser.arg("num_passwords", "how many passwords to generate; defaults to 1 if left blank")

        parser.on("-h", "--help", "show this help") { puts parser; exit }

        parser.separator("character set options:")
        # add more range options in the future
        parse_range("-a", "--ascii", "add all printable ASCII characters to the set", ASCII)
        parse_range("-n", "--number", "add numbers to the set", NUMBERS)
        parse_range("-d", "--down", "add all lowercase letters to the set", LOWER_LETTERS)
        parse_range("-u", "--up", "add all uppercase letters to the set", UPPER_LETTERS)
        parse_range("-l", "--letter", "add all letters to the set (same as -d -u)", UPPER_LETTERS, LOWER_LETTERS)
        parse_range("-s", "--simple", "add all letters and numbers to the set (same as -n -d -u)", NUMBERS, UPPER_LETTERS, LOWER_LETTERS)

        parser.invalid_option { }

        parser.unknown_args do |args|
          o.length = arg_try(args, 0, 64)
          o.count = arg_try(args, 1, 1)
        end
      end

      if o.ranges.chars.size == 0
        o.ranges = ASCII
      end
    end
  end

  def self.generate_password(o : Options)
    b = Bytes.new(o.length)
    Random::Secure.random_bytes(b)
    String.build do |builder|
      b.each do |byte|
        builder << constrain_byte(byte, o.ranges)
      end
    end.puts
  end

  def self.constrain_byte(byte : UInt8, chars : CharSet)
    byte &= 0x7F
    size = chars.chars.size
    index = byte % size
    chars.chars[index]
  end
end

SimplePasswordGenerator.main
