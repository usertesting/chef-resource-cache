Chef Resource Cache
===================
This cookbook provides a `resource_cache` LWRP.  Its purpose is to save time
for cookbook authors.  It can cache expensive and time-consuming resource
invocations between chef runs.

Resource caching is disabled by default.  The goal is to make the LWRP easy
and safe to use for cookbook authors without surprising end-users.

Requirements
------------
None -- just Chef.

Version
-------
0.5

Usage
-----

###Quick Start

* Wrap resources in `resource_cache` blocks
* Set `resource_cache['enable'] = true`
* Set `resource_cache['ttl'] = <minutes>`
* __Cookbook authors: please do NOT set these attributes as part of a library
  cookbook you distribute.  Instead, set them locally for your
  development cycle.__

###Simple caching:
    # Cache until TTL expiration
    resource_cache do
      resources do
        execute 'apt-get update'
      end
    end

###Conditional caching:
    # Cache until TTL expiration or conditions change
    resource_cache do
      conditions ({ :prefix => '/opt/software', :version => '1.0' })
      resources do
        bash 'compile software' do
          # Expensive compilation...
        end
        bash 'install software' do
          # Expensive copying/installing
        end
      end
    end

*Note `conditions ({})` above.  Using `conditions {}` would be interpreted as
a block instead of a hash.*

How It Works
------------
The LWRP serializes state to json files under chef's cache directory. It
stores a timestamp and the cache conditions (if specified) when a wrapped
resource is updated.  On subsequent chef runs, the serialized state is loaded.
If the current cache conditions match the prior cache conditions and the
updated timestamp is within the TTL, the wrapped resources are skipped.

Cache Invalidation
------------------
Any of the following will disable cache entries:

* Setting `bypass true` for a cache entry
* Changing the `conditions ({})` for a cache entry
* Setting the resource_cache.ttl attribute to 0
* Setting the resource_cache.enable attribute to false
* Removing the cache files from the resource_cache.dir directory

Attributes
----------

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['resource_cache']['enable']</tt></td>
    <td>Boolean</td>
    <td>whether to enable the cache</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['resource_cache']['ttl']</tt></td>
    <td>Integer</td>
    <td>Time-to-live (expiration) in minutes</td>
    <td><tt>0</tt></td>
  </tr>
  <tr>
    <td><tt>['resource_cache']['dir']</tt></td>
    <td>String (path)</td>
    <td>Directory to store cache files</td>
    <td><tt>Chef::Config[:file_cache_path]/resource_cache, or
            [SYSTEM TMP]/resource_cache if :file_cache_path is unset</tt></td>
  </tr>
</table>

Gotchas
-------
If you use vagrant for Chef development (highly recommended), watch out for
conflict with vagrant cache plugins.  Some of these may store /var/chef/cache
outside of the VM, on the host filesystem.  If the contents of this directory
are retained after a VM is destroyed, the resource_cache might produce false
cache hits.  The solution is to set the resource_cache.dir attribute to
a directory that is kept within the VM (e.g. /var/chef-resource-cache).

Development TODO
----------------

1. Write tests.  Yes, I'm a horrible person for releasing this without tests...
2. Normalize cache file names by stripping/replacing characters that aren't
   shell friendly.

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_tests` -- *wink wink*)
3. Write your change
4. Submit a Pull Request using Github

License and Authors
-------------------
Copyright 2013, Bob Ziuchkovski <bob@bz-technology.com>

Copyright 2013, UserTesting.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
