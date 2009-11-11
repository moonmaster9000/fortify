ActiveResource::Base.instance_eval do
  class DefaultAttributes
    attr_accessor :attributes
    
    # Override method_missing to allow setting
    # the default attributes via undefined methods.
    # For example: 
    #   d = DefaultAttributes.new
    #   d.author = 'Anonymous'
    #   puts d.author # returns "Anonymous"
    #   puts d.attributes[:author] # returns "Anonymous"
    def method_missing(method, *args, &block)
      k = attribute_name(method)
      v = method.to_s[-1..-1] == '=' ? args[0] : nil
      attributes[k] = v
    end
    
    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end
    
    private
    # strip the trailing "=" from a missing_method call
    def attribute_name(attribute_method_call)
      name = attribute_method_call.to_s
      name[-1..-1] == '=' ? name[0..-2] : name
    end
  end
  
  class BlockRequiredError < ArgumentError; end
  
  class BlockArgumentError < ArgumentError; end
  
  
  def fortify(&block)
    raise BlockRequiredError.new("you must pass a block to fortify") unless block
    raise BlockArgumentError.new("the block you pass to fortify must accept one argument") unless block.arity == 1
    block.call default_attributes
  end
  
  def default_attributes
    @default_attributes ||= DefaultAttributes.new
  end
end

ActiveResource::Base.class_eval do
  def initialize_with_default_attributes(attributes={})
    initialize_without_default_attributes self.class.default_attributes.attributes.merge(attributes)
  end
    
  alias_method_chain :initialize, :default_attributes
end