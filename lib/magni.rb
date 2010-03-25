class MagniAttributeError < Exception; end

class Magni
  class << self
    attr_accessor :mappings
    attr_accessor :keywords
    
    # Maps a flag to a argument type. Flags are then put into the
    # <tt>options</tt> instance variable. You can map two types:
    #
    # Literal Double Dash Flags:
    #
    #     map "--maxerrors" => :integer
    #
    # These can be one of four types: <tt>:integer</tt>, <tt>:string</tt>, 
    # <tt>:array</tt> and <tt>:boolean</tt>.
    #
    #     :integer #=> --count=2
    #     :string  #=> --word=bird
    #     :array   #=> --ravens=huginn,munnin
    #     :boolean #=> --all
    #
    #
    # Special Keywords are used to pull out a non-flag argument. This is
    # useful when the first or last argument needs to be the target of
    # your script; a file for example.
    #
    # Special keywords map to an instance variable on the instance your 
    # class. The following example will pull out the last argument from
    # the list and put it in the <tt>@file</tt> instance variable.
    # Currently there are only two keyword mappings, <tt>:first</tt> and
    # <tt>last</tt>:
    #
    #     map :first => :foo
    #     map :last  => :bar
    # 
    #
    # Parameters
    #     mapping: Hash[ Flag/Keyword => Type/iVar ]
    #
    def map(mapping={})
      @mappings ||= {}
      @keywords ||= {}
      
      mapping.each do |flag, type|
        if is_map_keyword?(flag)
          @keywords[flag] = type
        else
          @mappings[flag.gsub(/[-]+/, "")] = type
        end
      end
    end

    # Tells Magni where to send the processed flags and arguments.
    #
    #    # runner.rb
    #    class Runner < Magni
    #      map "--help" => :boolean
    #
    #      def start
    #        ...
    #      end
    #    end
    #
    #    # bin_script.rb
    #    Magni.delegate_to(Runner, :start)
    #
    # Parameters
    #
    #    klass:  Your "runner" class
    #    method: The method you want executed after flags are processed
    #
    def delegate_to(klass, method)
      klass.new(ARGV).send(method)
    end
    
  private
    
    def is_map_keyword?(flag)
      [:first, :last].include?(flag)
    end
  end
  
  attr_accessor :options
  
  def initialize(options=[])
    self.class.mappings ||= {}
    @options            ||= {}
    
    options = extract_keywords(options)
    options.each do |opt|
      flag, *values = opt.gsub(/[-]+/, "").split(/[=,]/)
      process(flag, values)
    end
  end
  
  # Pulls the keyworded flags out of the ARGV array and puts them
  # in the mapped instance variables.
  #
  def extract_keywords(opts=[])
    self.class.keywords.each do |keyword, ivar|
      Magni.class_eval { attr_accessor ivar }
      instance_variable_set("@#{ ivar }", opts.delete(opts.send(keyword)))
    end
    opts
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
    raise MagniAttributeError, "Expected boolean." unless values.empty?
    true
  end
  
  def to_integer(values=[])
    raise MagniAttributeError, "Expected integer." unless values[0] =~ /\d/
    values.pop.to_i
  end

  def to_array(values=[])
    if values.empty? || values.size <= 1
      raise MagniAttributeError, "Expected integer."
    end
    values.map { |value| (value.to_i if value =~ /\d/) || value }
  end

  def to_string(values=[])
    raise MagniAttributeError, "Expected string." if values.size > 1
    values.pop.to_s
  end

end
