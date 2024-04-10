-- StandardLibrary_Containers_LinkedList.lua

-- [[ DoubleLinkNode class ]]

local DoubleLinkNode = {}
DoubleLinkNode.__index = DoubleLinkNode

-- Set the value of the node
function DoubleLinkNode:SetValue(value)
    if type(value) ~= self.type
    then
        error("DoubleLinkNode value assignment failed: '" .. type(value) .. "' is not a valid type for this node. Valid type is '" .. self.type .. "'.")
    end

    self.value = value
end

-- Get the value of the node
function DoubleLinkNode:GetValue()
    return self.value
end

-- Set the previous node
function DoubleLinkNode:SetPrevious(previous)
    if previous ~= nil and not (getmetatable(previous) == DoubleLinkNode)
    then
        error("DoubleLinkNode previous assignment failed: 'previous' is not a valid DoubleLinkNode.")
    end

    self.previous = previous
    if previous then
        previous.next = self
    end
end

-- Set the next node
function DoubleLinkNode:SetNext(next)
    if next ~= nil and not (getmetatable(next) == DoubleLinkNode)
    then
        error("DoubleLinkNode next assignment failed: 'next' is not a valid DoubleLinkNode.")
    end

    self.next = next
    if next then
        next.previous = self
    end
end

-- Get the previous node
function DoubleLinkNode:GetPrevious()
    return self.previous
end

-- Get the next node
function DoubleLinkNode:GetNext()
    return self.next
end

-- Constructor for the DoubleLinkNode class
function DoubleLinkNode.Create(elementType, value)
    local validTypes = {
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }

    if not validTypes[elementType]
    then
        error("DoubleLinkNode creation failed: '" .. elementType .. "' is not a valid type. Valid types are 'number', 'string', 'boolean', 'table', 'function'.")
    end

    if value == nil or type(value) ~= elementType
    then
        error("Initial value type does not match the node type.")
    end

    local self = setmetatable({}, DoubleLinkNode)
    self.type = elementType
    self.value = value or nil
    self.previous = nil
    self.next = nil

    return self
end

-- Destructor for the DoubleLinkNode class
function DoubleLinkNode:Destroy()
    if self.previous ~= nil
    then
        self.previous.next = nil
    end

    if self.next ~= nil
    then
        self.next.previous = nil
    end

    self.value = nil
    self.previous = nil
    self.next = nil
    self.type = nil
end

-- [[ LinkedList class ]]

local LinkedList = {}
LinkedList.__index = LinkedList

-- Check instance is LinkedList should be destroyed
function LinkedList:IsDestroyed()
    return self._elementType == nil and self._size == nil and self._head == nil and self._tail == nil
end

-- [[ Accessor for Linked List functionality ]]

-- Find the node at that position and set or replace its value
function LinkedList:Set(position, value)
    if self:IsDestroyed() then
        error("LinkedList Set failed: LinkedList is destroyed.")
    end
    if position < 1 or position > self._size then
        error("LinkedList Set failed: index out of bounds.")
    end
    if type(value) ~= self._elementType then
        error("LinkedList Set failed: value is not a valid type for this LinkedList. Expected " .. self._elementType .. ", got " .. type(value) .. ".")
    end

    local current = self._head
    for i = 1, position - 1 do
        current = current.next
    end
    current:SetValue(value)
end

-- Find the node at that position and get its value.
function LinkedList:Get(position)
    if self:IsDestroyed() then
        error("LinkedList GetNode failed: LinkedList is destroyed.")
    end
    if position < 1 or position > self._size then
        error("LinkedList GetNode failed: index out of bounds.")
    end

    local current = self._head
    for i = 1, position - 1 do
        current = current.next
    end
    return current:GetValue()
end

-- Access the first element
function LinkedList:Front()
    if self:IsDestroyed() then
        error("LinkedList GetFirst failed: LinkedList is destroyed.")
    end
    if self._head == nil then
        error("LinkedList GetFirst failed: LinkedList is empty.")
    end
    return self._head
end

-- Access the last element
function LinkedList:Back()
    if self:IsDestroyed() then
        error("LinkedList GetLast failed: LinkedList is destroyed.")
    end
    if self._tail == nil then
        error("LinkedList GetLast failed: LinkedList is empty.")
    end
    return self._tail
end

-- [[ Modifier for Dynamic Array functionality ]]

-- Find the node at that position and insert the new node at that position.
function LinkedList:InsertNode(position, node)
    if self:IsDestroyed() then
        error("LinkedList InsertNode failed: LinkedList is destroyed.")
    end
    if position < 1 or position > self._size + 1 then
        error("LinkedList InsertNode failed: position out of bounds.")
    end
    if not (getmetatable(node) == DoubleLinkNode) then
        error("LinkedList InsertNode failed: 'node' is not a valid DoubleLinkNode.")
    end
    if node.type ~= self._elementType then
        error("LinkedList InsertNode failed: 'node' is not a valid type for this LinkedList.")
    end

    if position == 1 then
        -- Inserting at the head
        node.next = self._head
        if self._head then
            self._head.previous = node
        end
        self._head = node
        if not self._tail then
            self._tail = node
        end
    elseif position == self._size + 1 then
        -- Inserting at the tail
        node.previous = self._tail
        if self._tail then
            self._tail.next = node
        end
        self._tail = node
        if not self._head then
            self._head = node
        end
    else
        -- Inserting in the middle
        local current = self._head
        for i = 1, position - 1 do
            current = current.next
        end
        node.next = current
        node.previous = current.previous
        current.previous.next = node
        current.previous = node
    end

    self._size = self._size + 1
end


-- Find the node at that position and erase the old node after that position.
function LinkedList:EraseNode(position)
    if self:IsDestroyed() then
        error("LinkedList EraseNode failed: LinkedList is destroyed.")
    end
    if position < 1 or position > self._size then
        error("LinkedList EraseNode failed: position out of bounds.")
    end

    local current = self._head
    for i = 1, position - 1 do
        current = current.next
    end

    if current.previous then
        current.previous.next = current.next
    else
        -- Removing the head
        self._head = current.next
    end

    if current.next then
        current.next.previous = current.previous
    else
        -- Removing the tail
        self._tail = current.previous
    end

    current:Destroy()
    self._size = self._size - 1
end

function LinkedList:PushBack(value)
    if self:IsDestroyed()
    then
        error("LinkedList PushBack failed: LinkedList is destroyed.")
    end
    
    -- existing error checking
    local newNode = DoubleLinkNode.Create(self._elementType, value)
    if self._size == 0 then
        self._head = newNode
        self._tail = newNode
    else
        self._tail:SetNext(newNode)
        newNode:SetPrevious(self._tail)
        self._tail = newNode
    end
    self._size = self._size + 1
end

function LinkedList:PopBack()
    if self:IsDestroyed()
    then
        error("LinkedList PopBack failed: LinkedList is destroyed.")
    end
    
    if self._size == 0 then
        error("LinkedList PopBack failed: list is empty.")
    end
    -- Destroy tail node

    local removedNode = self._tail
    if self._size == 1 then
        -- If there's only one element
        self._head = nil
        self._tail = nil
    else
        -- More than one element
        self._tail = self._tail.previous
        self._tail.next = nil
    end

    removedNode:Destroy()
    self._size = self._size - 1
end

function LinkedList:PushFront(value)
    if self:IsDestroyed()
    then
        error("LinkedList PushFront failed: LinkedList is destroyed.")
    end
    
    -- existing error checking
    local newNode = DoubleLinkNode.Create(self._elementType, value)
    if self._size == 0 then
        self._head = newNode
        self._tail = newNode
    else
        self._head:SetPrevious(newNode)
        newNode:SetNext(self._head)
        self._head = newNode
    end
    self._size = self._size + 1
end

function LinkedList:PopFront()
    if self:IsDestroyed()
    then
        error("LinkedList PopFront failed: LinkedList is destroyed.")
    end
    
    if self._size == 0 then
        error("LinkedList PopFront failed: list is empty.")
    end

    local removedNode = self._head
    if self._size == 1 then
        -- If there's only one element
        self._head = nil
        self._tail = nil
    else
        -- More than one element
        self._head = self._head.next
        self._head.previous = nil
    end

    removedNode:Destroy()
    self._size = self._size - 1
end

-- [[ Capacity functions ]]

function LinkedList:Empty()
    if self:IsDestroyed()
    then
        error("LinkedList Empty failed: LinkedList is destroyed.")
    end
    
    return self._size == 0
end

function LinkedList:Size()
    if self:IsDestroyed()
    then
        error("LinkedList Size failed: LinkedList is destroyed.")
    end
    
    return self._size
end

-- [[ Iterator functions to mimic C++ style iterators ]]

function LinkedList:Begin()
    return 1
end

function LinkedList:End()
    return self._size + 1
end

function LinkedList:Rbegin()
    return self._size
end

function LinkedList:Rend()
    return 0
end

-- Forward Iterator
function LinkedList:ForwardIterator()
    if self:IsDestroyed()
    then
        error("LinkedLis ForwardIterator failed: Array is destroyed.")
    end
    assert(self._size > 0, "LinkedLis is empty")
    local index = self:Begin() - 1  -- Start before the first element
    local endIndex = self:End() - 1  -- End at the last element
    return function()
        index = index + 1
        if index <= endIndex
        then
            return index, self._elements[index] -- {key is index, value is element} pair
        else
            return nil
        end
    end
end

-- Backward Iterator
function LinkedList:BackwardIterator()
    if self:IsDestroyed()
    then
        error("LinkedLis BackwardIterator failed: Array is destroyed.")
    end
    assert(self._size > 0, "LinkedLis is empty")
    local index = self:Rbegin() + 1  -- Start after the last element
    local endIndex = self:Rend() + 1  -- End at the firstelement
    return function()
        index = index - 1
        if index >= endIndex
        then
            return index, self._elements[index] -- {key is index, value is element} pair
        else
            return nil
        end
    end
end

-----

function LinkedList:Print()
    if self:IsDestroyed()
    then
        error("LinkedList Print failed: LinkedList is destroyed.")
    end
    
    --  Need Format  {x,x,x,x,x}
    -- if type us function then print "function" string else print value node element
    local result = "{"
    local current = self._head
    while current ~= nil
    do
        local current_value = current:GetValue()
        if type(current_value) == "function"
        then
            result = result .. "function"
        else
            result = result .. tostring(current_value)
        end
        if current.next ~= nil
        then
            result = result .. ","
        end
        current = current.next
    end
end

-- Constructor for the LinkedList class
function LinkedList.Create(elementType)
    local validTypes = {
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }

    if not validTypes[elementType]
    then
        error("LinkedList creation failed: '" .. elementType .. "' is not a valid type. Valid types are 'number', 'string', 'boolean', 'table', 'function'.")
    end
    local self = setmetatable({}, LinkedList)
    self._elementType = elementType
    self._size = 0
    self._head = nil
    self._tail = nil
    return self
end

function LinkedList:Clear()
    local currentNode = self._head
    while currentNode ~= nil
    do
        local nextNode = currentNode.next
        currentNode:Destroy()
        currentNode = nextNode
    end
    self._head = nil
    self._tail = nil
    self._size = 0
end

-- Destructor for the LinkedList class
function LinkedList:Destroy()
    self.Clear()
    self._elementType = nil
    self._size = nil
end

return DoubleLinkNode, LinkedList