# jedis_shard_lua
Redis sharding is wildly used before redis 3.0 in our system.
Sharding function is implemented in client side(We use Jedis) based on MurmurHash(Default) or MD5. 
So when we use Lua + redis, There's a problem : which shard servers a specific key? That's the origin of this project.
This project is Lua version ShardedJedis implementation. YOU CAN USE THE SAME AS ShardedJedis In Jedis. 


# reference 
[1]http://www.cnblogs.com/chenny7/p/3640990.html
[2]https://github.com/jwerle/murmurhash.c
