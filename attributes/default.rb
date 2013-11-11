require 'tmpdir'

# Should the cache be enabled or not?  When disabled, wrapped resources are always executed
default.resource_cache.enable = false

# Cache Time-to-live in minutes
default.resource_cache.ttl    = 0

# Cache directory
if Chef::Config[:file_cache_path]
  default.resource_cache.dir  = ::File.join(Chef::Config[:file_cache_path], 'resource_cache')
else
  default.resource_cache.dir  = ::File.join(::Dir.tmpdir, 'resource_cache')
end
