-- StandardLibrary_Containers_SortedSet.lua

-- 导入 RedBlackTree 类
local RedBlackTree = require("StandardLibrary_Containers_RedBlackTree")

local SortedSet = {}
SortedSet.__index = SortedSet
SortedSet.__type = "SortedSet" -- 类型标识符

-- 元方法 __tostring 用于打印集合的内容
function SortedSet:__tostring()
    if self:IsDestroyed() then
        return "SortedSet (destroyed)"
    end

    local result = "{ "
    local iterator = self:Iterate()
    while true do
        local value = iterator()
        if value == nil then break end
        result = result .. tostring(value) .. " "
    end
    result = result .. "}"
    return "SortedSet " .. result
end

-- 构造函数
function SortedSet.Create(comparator)
    local self = setmetatable({}, SortedSet)
    self.tree = RedBlackTree.Create(comparator)
    self.count = 0 -- 记录集合中元素的数量
    self.destroyed = false
    return self
end

-- 检查集合是否已被销毁
function SortedSet:IsDestroyed()
    return self.destroyed or not self.tree or self.tree:IsDestroyed()
end

-- 清除 SortedSet 中的所有元素
function SortedSet:Clear()
    if self:IsDestroyed() then
        error("SortedSet Clear function failed: SortedSet is destroyed.")
    end
    self.tree:Clear()
    self.count = 0
end

-- 销毁 SortedSet 实例
function SortedSet:Destroy()
    if not self.destroyed then
        if self.tree and not self.tree:IsDestroyed() then
            self.tree:Destroy()
        end
        self.tree = nil
        self.count = 0
        self.destroyed = true
    end
end

-- [[ Capacity functions ]]

function SortedSet:Empty()
    if self:IsDestroyed() then
        error("SortedSet Empty function failed: SortedSet is destroyed.")
    end
    return self.count == 0
end

function SortedSet:Size()
    if self:IsDestroyed() then
        return 0
    end
    return self.count
end

function SortedSet:MaxSize()
    return math.huge -- 由于 Lua 的限制，这里返回一个非常大的值
end

-- [[ Accessor for SortedSet functionality ]]

-- Returns the number of elements with key that compares equivalent to the specified argument.
function SortedSet:Count(value)
    if self:IsDestroyed() then
        error("SortedSet Count function failed: SortedSet is destroyed.")
    end
    return self:Contains(value) and 1 or 0
end

-- Find a value in the SortedSet
function SortedSet:Find(value)
    if self:IsDestroyed() then
        error("SortedSet Find function failed: SortedSet is destroyed.")
    end
    return self.tree:Find(value)
end

-- Check if a value exists in the SortedSet
function SortedSet:Contains(value)
    if self:IsDestroyed() then
        error("SortedSet Contains function failed: SortedSet is destroyed.")
    end
    return self.tree:Contains(value)
end

-- Get the lower and upper bounds for a given value
function SortedSet:EqualRange(value)
    if self:IsDestroyed() then
        error("SortedSet EqualRange function failed: SortedSet is destroyed.")
    end
    local lower = self:LowerBound(value)
    local upper = self:UpperBound(value)
    return lower, upper
end

-- Find the first element not less than the given value
function SortedSet:LowerBound(value)
    if self:IsDestroyed() then
        error("SortedSet LowerBound function failed: SortedSet is destroyed.")
    end

    local result = nil
    self.tree:Traverse(function(nodeValue)
        if nodeValue >= value and (result == nil or nodeValue < result) then
            result = nodeValue
        end
    end)
    return result
end

-- Find the first element greater than the given value
function SortedSet:UpperBound(value)
    if self:IsDestroyed() then
        error("SortedSet UpperBound function failed: SortedSet is destroyed.")
    end

    local result = nil
    self.tree:Traverse(function(nodeValue)
        if nodeValue > value and (result == nil or nodeValue < result) then
            result = nodeValue
        end
    end)
    return result
end

-- [[ Modifier for SortedSet functionality ]]

-- Insert a value into the SortedSet
function SortedSet:Insert(value)
    if self:IsDestroyed() then
        error("SortedSet Insert function failed: SortedSet is destroyed.")
    end
    if not self.tree:Contains(value) then
        self.tree:Insert(value)
        self.count = self.count + 1
    end
end

-- Erase a value from the SortedSet
function SortedSet:Erase(value)
    if self:IsDestroyed() then
        error("SortedSet Erase function failed: SortedSet is destroyed.")
    end
    if self.tree:Contains(value) then
        self.tree:Erase(value)
        self.count = self.count - 1
    end
end

-- Swap two SortedSets
function SortedSet:Swap(other)
    if self:IsDestroyed() then
        error("SortedSet Swap function failed: This SortedSet is destroyed.")
    end

    if not other or other:IsDestroyed() then
        error("SortedSet Swap function failed: Other SortedSet is destroyed or invalid.")
    end

    self.tree, other.tree = other.tree, self.tree
    self.count, other.count = other.count, self.count
end

-- Merge another SortedSet into this one
function SortedSet:Merge(other)
    if self:IsDestroyed() then
        error("SortedSet Merge function failed: This SortedSet is destroyed.")
    end
    if not other or other:IsDestroyed() then
        error("SortedSet Merge function failed: Other SortedSet is destroyed or invalid.")
    end

    local iterator = other:Iterate()
    while true do
        local value = iterator()
        if value == nil then break end
        self:Insert(value)
    end
    other:Clear()
end

-- Forward iterator for the SortedSet
function SortedSet:ForwardIterator()
    if self:IsDestroyed() then
        error("SortedSet ForwardIterator function failed: SortedSet is destroyed.")
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
        local value = node.value
        node = node.right
        return value
    end
end

-- Backward iterator for the SortedSet
function SortedSet:BackwardIterator()
    if self:IsDestroyed() then
        error("SortedSet BackwardIterator function failed: SortedSet is destroyed.")
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
        local value = node.value
        node = node.left
        return value
    end
end

-- 遍历整个集合，按中序遍历顺序执行回调函数
function SortedSet:Traverse(callback)
    if self:IsDestroyed() then
        error("SortedSet Traverse function failed: SortedSet is destroyed.")
    end
    if not callback then
        error("SortedSet Traverse function requires a callback.")
    end
    self.tree:Traverse(callback)
end

-- 遍历整个集合，按中序遍历顺序执行回调函数
function SortedSet:Iterate()
    if self:IsDestroyed() then
        return function() return nil end
    end
    return self.tree:InOrderIterator()
end

return SortedSet
