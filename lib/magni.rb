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
    #    mappings: Hash where key is flag and value is the type
    #
    def map(mapping={})
      @mappings ||= {}
      mapping.each do |flag, type|
        @mappings[flag.gsub(/[-]+/, "")] = type
      end
    end

    # Tells Magni where to send the processed flags and arguments.
    #
    #    # runner.rb
    #    class Runner < Magni
    #      map "--help" => :boolean
    #
    #      def start
    #        show_usage if @options[:help]
    #      end
    #    end
    #
    #    # bin_script.rb
    #    Magni.delegate_to(Runner, :start)
    #
    # Parameters
    #
    #    klass:  Your "runner" class object
    #    method: The method you want executed after flags are processed
    #
    def delegate_to(klass, method)
      klass.new(ARGV).send(method)
    end
  end

  attr_accessor :options

  def initialize(options=[])
    self.class.mappings ||= {}
    @options            ||= {}

    options.each do |opt|
      next unless opt =~ /^--/
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
    raise AttributeError, "Expected boolean argument." unless values.empty?
    true
  end

  def to_integer(values=[])
    unless values[0] =~ /\d/
      raise AttributeError, "Expected integer argument."
    end
    values.pop.to_i
  end

  def to_array(values=[])
    if values.empty? || values.size <= 1
      raise AttributeError, "Expected integer argument."
    end
    values.map { |value| (value.to_i if value =~ /\d/) || value }
  end

  def to_string(values=[])
    raise AttributeError, "Expected string argument." if values.size > 1
    values.pop.to_s
  end

end
