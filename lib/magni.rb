libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

class InvalidArgumentError < Exception; end

class Magni
  class << self
    attr_accessor :mappings
    # Maps a flag to a argument type
    #
    #   map "--maxerrors" => :integer
    #
    # Will later parse <tt>@options[:maxerrors]</tt> into the
    # integer value the user supplied via <tt>--maxerrors=8</tt>
    #
    # Parameters
    #
    #    Hash[String] => Symbol::
    #       String => name of the CLI flag, ie: "--maxerrors"
    #       Symbol => argument type (:boolean, :integer, :string, :array)
    #
    def map(mapping={})
      @mappings ||= {}
      mapping.each do |flag, type|
        @mappings[flag.gsub(/[-]+/, "")] = type
      end
    end
  end
  
  attr_accessor :options
  
  def initialize(options=[])
    self.class.mappings ||= {}
    @options ||= {}
    
    options.each do |opt|
      flag, *values = opt.gsub(/[-]+/, "").split(/[=,]/)
      process(flag, values)
    end
  end
  
  # Pulls the type of argument +flag+ is set to in +mappings+
  # then sets the +options+ key to value "coerced" to the
  # matching argument type.
  #
  def process(flag, values)
    type = self.class.mappings[flag]
    unless type.nil?
      @options[flag.to_sym] = send("to_#{ type }", values)
    end
  end
  
private
  
  def to_boolean(values=[])
    true
  end
  
  def to_integer(values=[])
    values.pop.to_i
  end
  
  def to_array(values=[])
    values.map { |value| (value.to_i if value =~ /\d/) || value }
  end
  
  def to_string(values=[])
    values.pop.to_s
  end
  
end