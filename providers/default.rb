require 'json'
require 'tmpdir'


def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::ResourceCache.new(@new_resource.name)
  @current_resource.name(@new_resource.name)

  state = deserialize
  unless state.empty?
    @current_resource.exists = true
    @current_resource.updated_at = state[:updated_at]
    @current_resource.conditions(state[:conditions])
  end
end

action :cache do
  if @new_resource.bypass
    converge_by("Cache bypassed for #{@new_resource} - updating resources") do
      update!
    end
  elsif cache_valid?
    converge_by("Cache valid for #{@new_resource} - nothing to do") {}
  else
    converge_by("Cache invalid for #{@new_resource} - updating resources") do
      update!
    end
  end
end

private

def update!
  instance_eval &@new_resource.resources
  @new_resource.updated_at = ::Time.now.to_i
  serialize({:updated_at => @new_resource.updated_at, :conditions => @new_resource.conditions})
end

def cache_valid?
  flags = @run_context.node.resource_cache
  unless @current_resource.exists and
      flags.enable and flags.ttl and
      normalize_hash(@current_resource.conditions) == normalize_hash(@new_resource.conditions)
    return false
  end
  expires = @current_resource.updated_at + (60 * flags.ttl)
  now = ::Time.now.to_i
  now < expires
end

def cache_dir
  @run_context.node.resource_cache.dir
end

def cache_file
  ::File.join(cache_dir, normalize_name + '.json')
end

def normalize_name
  # TODO: Replace/remove chars that aren't shell friendly
  @current_resource.name
end

def normalize_hash(hash)
  # TODO: Replace this with something that isn't a complete hack  :)
  JSON.parse(JSON.generate(hash))
end

def deserialize
  if ::File.exists? cache_file
    begin
      return JSON.parse(IO.read(cache_file), :symbolize_names => true)
    rescue
      Chef::Log.warn "Failed to load #{cache_file}"
    end
  else
    Chef::Log.debug "#{cache_file} does not exist"
  end
  {}
end

def serialize(state)
  begin
    ::Dir.mkdir cache_dir unless ::Dir.exists? cache_dir
    ::File.open(cache_file, 'w') do |file|
      file.print JSON.pretty_generate(state)
    end
    Chef::Log.debug "Wrote state to #{cache_file}"
  rescue
    Chef::Log.error "Failed to write #{cache_file}"
  end
end
