actions :cache
default_action :cache

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :conditions, :kind_of => [Hash, Mash], :default => {}
attribute :bypass, :kind_of => [TrueClass, FalseClass], :default => false

attr_accessor :exists, :updated_at, :resources

def resources(&block)
  set_or_return(:resources, block, :kind_of => Proc)
end
