libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

class AttributeError < Exception; end

class Magni
  class << self
    attr_accessor :mappings
    # Maps a flag to a argument type
    #
    #    map "--maxerrors" => :integer
    #
    # Will later parse +@options[:maxerrors]+ into the
    # integer value the user supplied via +--maxerrors=8+
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
    
    # Delegates from the command line, when invoked, to the class
    # specified. This should go in your application's +bin+ script.
    #
    #    #!/usr/bin/env ruby
    #    require 'my_app'
    #    Magni.delegate(MyApp::Runner)
    #
    def delegate(klass)
      klass.new.invoke(ARGV)
    end
  end
  
  attr_accessor :options
  
  def invoke(options=[])
    self.class.mappings ||= {}
    @options ||= {}
    
    options.each do |opt|
      next unless opt =~ /^--/
      flag, *values = opt.gsub(/[-]+/, "").split(/[=,]/)
      process(flag, values)
    end
    self
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
    raise AttributeError unless values.empty?
    true
  end
  
  def to_integer(values=[])
    raise AttributeError unless values[0] =~ /\d/
    values.pop.to_i
  end
  
  def to_array(values=[])
    raise AttributeError if values.empty? || values.size <= 1
    values.map { |value| (value.to_i if value =~ /\d/) || value }
  end
  
  def to_string(values=[])
    raise AttributeError if values.size > 1
    values.pop.to_s
  end
  
end