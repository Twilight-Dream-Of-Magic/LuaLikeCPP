-- 导入 RedBlackTree 类
local RedBlackTree = require("StandardLibrary_Containers_RedBlackTree")

local SortedSet = {}
SortedSet.__index = SortedSet

-- Check instance is SortedSe should be destroyed
function SortedSet:IsDestroyed()
    return self == nil or self.tree:IsDestroyed()
end

-- [[ Capacity functions ]]

function SortedSet:Empty()
    return self.count == 0
end

function SortedSet:Size()
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
    return self.tree:Find(value) ~= nil
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
    self.tree:Traverse(self.tree.root, function(nodeValue)
        if not result and nodeValue >= value then
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
    local found = false
    self.tree:Traverse(self.tree.root, function(nodeValue)
        if not found and nodeValue > value then
            result = nodeValue
            found = true
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
    if not self.tree:Find(value) then
        self.tree:Insert(value)
        self.count = self.count + 1
    end
end

-- Erase a value from the SortedSet
function SortedSet:Erase(value)
    if self:IsDestroyed() then
        error("SortedSet Erase function failed: SortedSet is destroyed.")
    end
    if self.tree:Find(value) then
        self.tree:Erase(value)
        self.count = self.count - 1
    end
end

function SortedSet:Swap(other)
    if self:IsDestroyed() then
        error("SortedSet Swap function failed: SortedSet is destroyed.")
    end

    if other:IsDestroyed() then
        error("SortedSet Swap function failed: Other SortedSet is destroyed.")
    end

    self.tree, other.tree = other.tree, self.tree
    self.count, other.count = other.count, self.count
end

-- Merge another SortedSet into this one
function SortedSet:Merge(other)
    if self:IsDestroyed() then
        error("SortedSet Merge function failed: SortedSet is destroyed.")
    end
    other:Traverse
    (
    function(value)
        self:Insert(value)
    end
    )
    other:Clear()
end

-- Forward iterator for the SortedSet
function SortedSet:ForwardIterator()
    if self:IsDestroyed() then
        error("SortedSet ForwardIterator function failed: SortedSet is destroyed.")
    end

    local current = self.tree:Front()
    return function()
        if not current then return nil end
        local value = current.value
        current = self.tree:NextNode(current)
        return value
    end
end

-- Backward iterator for the SortedSet
function SortedSet:BackwardIterator()
    if self:IsDestroyed() then
        error("SortedSet BackwardIterator function failed: SortedSet is destroyed.")
    end

    local current = self.tree:Back()
    return function()
        if not current then return nil end
        local value = current.value
        current = self.tree:PreviousNode(current)
        return value
    end
end

-- 创建 SortedSet 实例
function SortedSet.Create()
    local self = setmetatable({}, SortedSet)
    self.tree = RedBlackTree.Create() -- 使用红黑树
    self.count = 0 -- 记录集合中元素的数量
    return self
end

-- 清除 SortedSet 中的所有元素
function SortedSet:Clear()
    self.tree:Clear()
    self.count = 0
end

-- 销毁 SortedSet 实例
function SortedSet:Destroy()
    self.tree:Destroy()
    self.tree = nil
    self.count = 0
end

return SortedSet
