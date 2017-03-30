--[ShardedJedis for Lua version]
local ffi = require("ffi")
ffi.cdef[[
	int64_t MurmurHash64A ( const void * key, int len, uint64_t seed )
]]

local mffi= ffi.load('path_to_murmur.so',true)

local M = {}

local VIRTUAL_NODE = 160

local HASH_PEERS = {}
local CONTINUUM = {}

local function hash_fn(key)
    return tonumber(mffi.MurmurHash64A(key,string.len(key),0x1234abcd))
end

function quicksort(array,compareFunc)  
    quick(array,1,#array,compareFunc)  
end  

function quick(array,left,right,compareFunc)  
    if(left < right ) then  
        local index = partion(array,left,right,compareFunc)  
        quick(array,left,index-1,compareFunc)  
        quick(array,index+1,right,compareFunc)  
    end  
end  
  
function partion(array,left,right,compareFunc)  
    local key = array[left] 
    local index = left  
    array[index],array[right] = array[right],array[index]
    local i = left  
    while i< right do  
        if compareFunc( key,array[i]) then  
            array[index],array[i] = array[i],array[index]
            index = index + 1  
        end  
        i = i + 1  
    end  
    array[right],array[index] = array[index],array[right]
    return index;  
end  

local function chash_find(point)
    local mid, lo, hi = 1, 1, #CONTINUUM
    while 1 do
        if point <= CONTINUUM[lo][2] or point > CONTINUUM[hi][2] then
            return CONTINUUM[lo]
        end

        mid = lo + math.floor((hi-lo)/2)

        if point <= CONTINUUM[mid][2] and point > (mid > 1 and CONTINUUM[mid-1][2] or CONTINUUM[1][2] ) then
            return CONTINUUM[mid]
        end

        if CONTINUUM[mid][2] < point then
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
end

local function chash_init()
    local n = #HASH_PEERS
    if n == 0 then
        print("No backend servers")
        return
    end

    local C = {}
    for i,peer in ipairs(HASH_PEERS) do
        for k=1, math.floor(VIRTUAL_NODE * peer[1]) do
            local hash_data = "SHARD-" .. i-1 .. "-NODE-" .. (k - 1)
            table.insert(C, {peer[2] , hash_fn(hash_data)})
        end
    end

    quicksort(C, function(a,b) return a[2] > b[2] end)
    CONTINUUM = C
end

local function chash_get_upstream_crc32(point)
    return chash_find(point)[1]
end

local function chash_get_upstream(key)
    local hash_code = hash_fn(key)
    return chash_get_upstream_crc32(hash_code)
end

local function chash_add_upstream(upstream, weigth)
    weight = weight or 1
    table.insert(HASH_PEERS, {weight, upstream})
end

--export method
M.add_upstream = chash_add_upstream
M.init = chash_init
M.get_upstream = chash_get_upstream
return M

