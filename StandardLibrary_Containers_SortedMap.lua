-- StandardLibrary_Containers_SortedMap.lua

-- Import RedBlackTree class
local RedBlackTree = require("StandardLibrary_Containers_RedBlackTree")

local SortedMap = {}
SortedMap.__index = SortedMap
SortedMap.__type = "SortedMap" -- Type identifier

-- Metamethod __tostring for printing the map's contents
function SortedMap:__tostring()
    if self:IsDestroyed() then
        return "SortedMap (destroyed)"
    end

    local result = "{ "
    local iterator = self:Iterate()
    while true do
        local key, value = iterator()
        if key == nil then break end
        result = result .. tostring(key) .. ": " .. tostring(value) .. ", "
    end
    -- Remove the trailing comma and space
    if result:sub(-2) == ", " then
        result = result:sub(1, -3)
    end
    result = result .. " }"
    return "SortedMap " .. result
end

-- Constructor
function SortedMap.Create(comparator)
    local self = setmetatable({}, SortedMap)
    -- The comparator should compare keys
    self.tree = RedBlackTree.Create(comparator)
    self.count = 0 -- Number of elements in the map
    self.destroyed = false
    return self
end

-- Destructor
function SortedMap:Destroy()
    if not self.destroyed then
        if self.tree and not self.tree:IsDestroyed() then
            self.tree:Destroy()
        end
        self.tree = nil
        self.count = 0
        self.destroyed = true
    end
end

-- Check if the map is destroyed
function SortedMap:IsDestroyed()
    return self.destroyed or not self.tree or self.tree:IsDestroyed()
end

-- Capacity functions

function SortedMap:Empty()
    if self:IsDestroyed() then
        error("SortedMap Empty function failed: SortedMap is destroyed.")
    end
    return self.count == 0
end

function SortedMap:Size()
    if self:IsDestroyed() then
        error("SortedMap Size function failed: SortedMap is destroyed.")
    end
    return self.count
end

function SortedMap:MaxSize()
    return math.huge -- Lua doesn't have a fixed maximum size
end

-- Accessor functions

-- Returns the number of elements with the specified key (0 or 1 for map)
function SortedMap:Count(key)
    if self:IsDestroyed() then
        error("SortedMap Count function failed: SortedMap is destroyed.")
    end
    return self:Contains(key) and 1 or 0
end

-- Finds the value associated with the key
function SortedMap:Find(key)
    if self:IsDestroyed() then
        error("SortedMap Find function failed: SortedMap is destroyed.")
    end
    local node = self.tree:Find(key)
    if node then
        return node.value
    else
        return nil
    end
end

-- Checks if the map contains the key
function SortedMap:Contains(key)
    if self:IsDestroyed() then
        error("SortedMap Contains function failed: SortedMap is destroyed.")
    end
    return self.tree:Contains(key)
end

-- Get the lower and upper bounds for a given key
function SortedMap:EqualRange(key)
    if self:IsDestroyed() then
        error("SortedMap EqualRange function failed: SortedMap is destroyed.")
    end
    local lower = self:LowerBound(key)
    local upper = self:UpperBound(key)
    return lower, upper
end

-- Find the first element not less than the given key
function SortedMap:LowerBound(key)
    if self:IsDestroyed() then
        error("SortedMap LowerBound function failed: SortedMap is destroyed.")
    end
    return self.tree:LowerBound(key)
end

-- Find the first element greater than the given key
function SortedMap:UpperBound(key)
    if self:IsDestroyed() then
        error("SortedMap UpperBound function failed: SortedMap is destroyed.")
    end
    return self.tree:UpperBound(key)
end

-- Modifier functions

-- Inserts a key-value pair into the map
function SortedMap:Insert(key, value)
    if self:IsDestroyed() then
        error("SortedMap Insert function failed: SortedMap is destroyed.")
    end
    if self.tree:Contains(key) then
        error("SortedMap Insert function failed: Key already exists.")
    end
    self.tree:Insert(key, value)
    self.count = self.count + 1
end

-- Erases a key-value pair from the map by key
function SortedMap:Erase(key)
    if self:IsDestroyed() then
        error("SortedMap Erase function failed: SortedMap is destroyed.")
    end
    if self.tree:Contains(key) then
        self.tree:Erase(key)
        self.count = self.count - 1
    else
        error("SortedMap Erase function failed: Key does not exist.")
    end
end

-- Swaps the contents of this map with another
function SortedMap:Swap(other)
    if self:IsDestroyed() then
        error("SortedMap Swap function failed: This SortedMap is destroyed.")
    end
    if not other or other:IsDestroyed() then
        error("SortedMap Swap function failed: Other SortedMap is destroyed or invalid.")
    end
    self.tree, other.tree = other.tree, self.tree
    self.count, other.count = other.count, self.count
end

-- Merges another SortedMap into this one
function SortedMap:Merge(other)
    if self:IsDestroyed() then
        error("SortedMap Merge function failed: This SortedMap is destroyed.")
    end
    if not other or other:IsDestroyed() then
        error("SortedMap Merge function failed: Other SortedMap is destroyed or invalid.")
    end
    local iterator = other:Iterate()
    while true do
        local key, value = iterator()
        if key == nil then break end
        self:Insert(key, value)
    end
    other:Clear()
end

-- Clears all elements from the map
function SortedMap:Clear()
    if self:IsDestroyed() then
        error("SortedMap Clear function failed: SortedMap is destroyed.")
    end
    self.tree:Clear()
    self.count = 0
end

-- Iterator functions

-- Forward iterator for the SortedMap
function SortedMap:ForwardIterator()
    if self:IsDestroyed() then
        error("SortedMap ForwardIterator function failed: SortedMap is destroyed.")
    end

    local node = self.tree.root
    local stack = {}
    local done = false

    return function()
        while node ~= nil do
            table.insert(stack, node)
            node = node.left
        end
        if #stack == 0 then
            return nil
        end
        node = table.remove(stack)
        local key = node.key
        local value = node.value
        node = node.right
        return key, value
    end
end

-- Backward iterator for the SortedMap
function SortedMap:BackwardIterator()
    if self:IsDestroyed() then
        error("SortedMap BackwardIterator function failed: SortedMap is destroyed.")
    end

    local node = self.tree.root
    local stack = {}
    local done = false

    return function()
        while node ~= nil do
            table.insert(stack, node)
            node = node.right
        end
        if #stack == 0 then
            return nil
        end
        node = table.remove(stack)
        local key = node.key
        local value = node.value
        node = node.left
        return key, value
    end
end

-- Iterate function for use in for loops
function SortedMap:Iterate()
    if self:IsDestroyed() then
        return function() return nil, nil end
    end
    return self.tree:InOrderIterator()
end

return SortedMap
