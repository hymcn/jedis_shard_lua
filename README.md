# jedis_shard_lua
Redis sharding is wildly used before redis 3.0 in our system.
Sharding function is implemented in client side(We use Jedis) based on MurmurHash(Default) or MD5. 
So when we use Lua + redis, There's a problem : which shard servers a specific key? That's the origin of this project.
This project is Lua version ShardedJedis implementation. YOU CAN USE THE SAME AS ShardedJedis In Jedis. 

# Guide
    1)  compile MurmurHash64A.c
         gcc -g -o libmurmur.so -fpic -shared MurmurHash64A.c

    2)  edit chash.lua : change path_to_murmur.so to its real path
        OR you can use LD_LIBRARY_PATH
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/conf/lua/lib/murmurhash/
        local mffi= ffi.load('murmur.so',true)

    3)  Demo code:

         local shards = require "chash"
         local redis_shards ={ "server1:port","server2:port","server3:port"}
         for i,e in ipairs(redis_shards) do
                 shards.add_upstream(e,1)
         end
         shards.init()
         print(shards.get_upstream("test_key"))


# Require
    1)luajit or ffi installed

# reference 
    [1]http://www.cnblogs.com/chenny7/p/3640990.html
    [2]https://github.com/jwerle/murmurhash.c
    [3]http://wiki.jikexueyuan.com/project/openresty/lua/FFI.html