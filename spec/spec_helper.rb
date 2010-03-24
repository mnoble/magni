require File.dirname(__FILE__) + '/../lib/magni'

class Test < Magni
  map "--boolean" => :boolean
  map "--array"   => :array
  map "--integer" => :integer
  map "--string"  => :string
end

class LastKeywordTest < Magni
  map :last => :file
end