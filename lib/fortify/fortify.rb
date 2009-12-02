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
    
  class BlockArgumentError < ArgumentError; end
  
  
  def fortify(*args, &block)
    if block
      process_block(block)
    elsif passed_a_hash(args)
      process_hash(args.first)
    elsif passed_one_or_more_nonhash_parameters(args)
      process_symbols(args)
    end
  end
  
  def default_attributes
    @default_attributes ||= DefaultAttributes.new
  end
  
  private
  def process_hash(args)
    args.each do |attr_name, attr_value|
      default_attributes.send(
        (attr_name.to_s + '=').to_sym, 
        attr_value
      )
    end
  end
  
  def process_block(block)
    raise BlockArgumentError.new("the block you pass to fortify must accept one argument") unless block.arity == 1
    block.call default_attributes
  end
  
  def passed_a_hash(args)
    args.length == 1 && args.first.kind_of?(Hash)
  end
  
  def passed_one_or_more_nonhash_parameters(args)
    args.respond_to?(:length) && 
    (args.length > 1 || (args.length == 1 && args.first.kind_of?(Symbol)))
  end
  
  def process_symbols(args)
    raise ArgumentError.new("if you pass several parameters to fortify, they must all be symbols") unless args_are_symbols(args)
    args.map {|attribute| default_attributes.send attribute}
  end
  
  def args_are_symbols(args)
    args.inject(true) {|bool, current_arg| bool && current_arg.class == Symbol}    
  end
end

ActiveResource::Base.class_eval do
  def initialize_with_default_attributes(attributes={})
    initialize_without_default_attributes self.class.default_attributes.attributes.merge(attributes)
  end
    
  alias_method_chain :initialize, :default_attributes
end