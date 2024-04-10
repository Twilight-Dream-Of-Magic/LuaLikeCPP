-- StandardLibrary_Containers_LinkedList.lua

-- [[ DoubleLinkNode class ]]

local DoubleLinkNode = {}
DoubleLinkNode.__index = DoubleLinkNode
DoubleLinkNode.__type = "DoubleLinkNode" -- 类型标识符

-- 元方法 __tostring 用于打印节点的值
function DoubleLinkNode:__tostring()
    return tostring(self.value)
end

-- 设置节点的值
function DoubleLinkNode:SetValue(value)
    if type(value) ~= self.type then
        error("DoubleLinkNode SetValue failed: '" .. type(value) .. "' is not a valid type for this node. Expected '" .. self.type .. "'.")
    end
    self.value = value
end

-- 获取节点的值
function DoubleLinkNode:GetValue()
    return self.value
end

-- 设置前驱节点
function DoubleLinkNode:SetPrevious(previous)
    if previous ~= nil then
        if getmetatable(previous) ~= DoubleLinkNode then
            error("DoubleLinkNode SetPrevious failed: 'previous' is not a valid DoubleLinkNode.")
        end
    end
    self.previous = previous
end

-- 设置后继节点
function DoubleLinkNode:SetNext(next)
    if next ~= nil then
        if getmetatable(next) ~= DoubleLinkNode then
            error("DoubleLinkNode SetNext failed: 'next' is not a valid DoubleLinkNode.")
        end
    end
    self.next = next
end

-- 获取前驱节点
function DoubleLinkNode:GetPrevious()
    return self.previous
end

-- 获取后继节点
function DoubleLinkNode:GetNext()
    return self.next
end

-- 构造函数
function DoubleLinkNode.Create(elementType, value)
    local validTypes = {
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }

    if not validTypes[elementType] then
        error("DoubleLinkNode creation failed: '" .. elementType .. "' is not a valid type. Valid types are 'number', 'string', 'boolean', 'table', 'function'.")
    end

    if value == nil or type(value) ~= elementType then
        error("DoubleLinkNode creation failed: Initial value type does not match the node type. Expected '" .. elementType .. "', got '" .. type(value) .. "'.")
    end

    local self = setmetatable({}, DoubleLinkNode)
    self.type = elementType
    self.value = value
    self.previous = nil
    self.next = nil

    return self
end

-- 析构函数
function DoubleLinkNode:Destroy()
    if self.previous then
        self.previous.next = nil
    end

    if self.next then
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
LinkedList.__type = "LinkedList" -- 类型标识符

-- 元方法 __tostring 用于打印链表内容
function LinkedList:__tostring()
    if self:IsDestroyed() then
        return "LinkedList (destroyed)"
    end

    local result = "{"
    local current = self._head
    while current ~= nil do
        local current_value = current:GetValue()
        if type(current_value) == "function" then
            result = result .. "function"
        else
            result = result .. tostring(current_value)
        end
        if current.next ~= nil then
            result = result .. ", "
        end
        current = current.next
    end
    result = result .. "}"
    return "LinkedList " .. result
end

-- 检查链表是否已被销毁
function LinkedList:IsDestroyed()
    return self._elementType == nil and self._size == nil and self._head == nil and self._tail == nil
end

-- 构造函数
function LinkedList.Create(elementType)
    local validTypes = {
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }

    if not validTypes[elementType] then
        error("LinkedList creation failed: '" .. elementType .. "' is not a valid type. Valid types are 'number', 'string', 'boolean', 'table', 'function'.")
    end

    local self = setmetatable({}, LinkedList)
    self._elementType = elementType
    self._size = 0
    self._head = nil
    self._tail = nil
    return self
end

-- 析构函数
function LinkedList:Destroy()
    self:Clear()
    self._elementType = nil
    self._size = nil
    self._head = nil
    self._tail = nil
end

-- 清空链表
function LinkedList:Clear()
    if self:IsDestroyed() then
        error("LinkedList Clear failed: LinkedList is destroyed.")
    end

    local currentNode = self._head
    while currentNode ~= nil do
        local nextNode = currentNode:GetNext()
        currentNode:Destroy()
        currentNode = nextNode
    end
    self._head = nil
    self._tail = nil
    self._size = 0
end

-- 获取链表大小
function LinkedList:Size()
    if self:IsDestroyed() then
        error("LinkedList Size failed: LinkedList is destroyed.")
    end
    return self._size
end

-- 检查链表是否为空
function LinkedList:Empty()
    if self:IsDestroyed() then
        error("LinkedList Empty failed: LinkedList is destroyed.")
    end
    return self._size == 0
end

-- 获取第一个元素的值
function LinkedList:Front()
    if self:IsDestroyed() then
        error("LinkedList Front failed: LinkedList is destroyed.")
    end
    if self._head == nil then
        error("LinkedList Front failed: LinkedList is empty.")
    end
    return self._head:GetValue()
end

-- 获取最后一个元素的值
function LinkedList:Back()
    if self:IsDestroyed() then
        error("LinkedList Back failed: LinkedList is destroyed.")
    end
    if self._tail == nil then
        error("LinkedList Back failed: LinkedList is empty.")
    end
    return self._tail:GetValue()
end

-- 设置指定位置的节点值
function LinkedList:Set(position, value)
    if self:IsDestroyed() then
        error("LinkedList Set failed: LinkedList is destroyed.")
    end
    if type(position) ~= "number" or position < 1 or position > self._size then
        error("LinkedList Set failed: position out of bounds.")
    end
    if type(value) ~= self._elementType then
        error("LinkedList Set failed: value type mismatch. Expected '" .. self._elementType .. "', got '" .. type(value) .. "'.")
    end

    local current = self._head
    for i = 1, position - 1 do
        current = current:GetNext()
    end
    current:SetValue(value)
end

-- 获取指定位置的节点值
function LinkedList:Get(position)
    if self:IsDestroyed() then
        error("LinkedList Get failed: LinkedList is destroyed.")
    end
    if type(position) ~= "number" or position < 1 or position > self._size then
        error("LinkedList Get failed: position out of bounds.")
    end

    local current = self._head
    for i = 1, position - 1 do
        current = current:GetNext()
    end
    return current:GetValue()
end

-- 插入节点到指定位置
function LinkedList:InsertNode(position, node)
    if self:IsDestroyed() then
        error("LinkedList InsertNode failed: LinkedList is destroyed.")
    end
    if type(position) ~= "number" or position < 1 or position > self._size + 1 then
        error("LinkedList InsertNode failed: position out of bounds.")
    end
    if getmetatable(node) ~= DoubleLinkNode then
        error("LinkedList InsertNode failed: 'node' is not a valid DoubleLinkNode.")
    end
    if node.type ~= self._elementType then
        error("LinkedList InsertNode failed: node type mismatch. Expected '" .. self._elementType .. "', got '" .. node.type .. "'.")
    end

    if position == 1 then
        -- 插入到头部
        node:SetNext(self._head)
        if self._head then
            self._head:SetPrevious(node)
        end
        self._head = node
        if self._tail == nil then
            self._tail = node
        end
    elseif position == self._size + 1 then
        -- 插入到尾部
        node:SetPrevious(self._tail)
        if self._tail then
            self._tail:SetNext(node)
        end
        self._tail = node
        if self._head == nil then
            self._head = node
        end
    else
        -- 插入到中间
        local current = self._head
        for i = 1, position - 1 do
            current = current:GetNext()
        end
        local previous = current:GetPrevious()
        node:SetNext(current)
        node:SetPrevious(previous)
        if previous then
            previous:SetNext(node)
        end
        current:SetPrevious(node)
    end

    self._size = self._size + 1
end

-- 在指定位置插入值（自动创建节点）
function LinkedList:Insert(position, value)
    if self:IsDestroyed() then
        error("LinkedList Insert failed: LinkedList is destroyed.")
    end
    if type(position) ~= "number" or position < 1 or position > self._size + 1 then
        error("LinkedList Insert failed: position out of bounds.")
    end
    if type(value) ~= self._elementType then
        error("LinkedList Insert failed: value type mismatch. Expected '" .. self._elementType .. "', got '" .. type(value) .. "'.")
    end

    local newNode = DoubleLinkNode.Create(self._elementType, value)
    self:InsertNode(position, newNode)
end

-- 移除指定位置的节点
function LinkedList:EraseNode(position)
    if self:IsDestroyed() then
        error("LinkedList EraseNode failed: LinkedList is destroyed.")
    end
    if type(position) ~= "number" or position < 1 or position > self._size then
        error("LinkedList EraseNode failed: position out of bounds.")
    end

    local current = self._head
    for i = 1, position - 1 do
        current = current:GetNext()
    end

    local previous = current:GetPrevious()
    local nextNode = current:GetNext()

    if previous then
        previous:SetNext(nextNode)
    else
        -- 移除头部
        self._head = nextNode
    end

    if nextNode then
        nextNode:SetPrevious(previous)
    else
        -- 移除尾部
        self._tail = previous
    end

    current:Destroy()
    self._size = self._size - 1
end

-- 添加元素到尾部
function LinkedList:PushBack(value)
    if self:IsDestroyed() then
        error("LinkedList PushBack failed: LinkedList is destroyed.")
    end
    if type(value) ~= self._elementType then
        error("LinkedList PushBack failed: value type mismatch. Expected '" .. self._elementType .. "', got '" .. type(value) .. "'.")
    end

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

-- 从尾部移除元素
function LinkedList:PopBack()
    if self:IsDestroyed() then
        error("LinkedList PopBack failed: LinkedList is destroyed.")
    end
    if self._size == 0 then
        error("LinkedList PopBack failed: list is empty.")
    end

    local removedNode = self._tail
    if self._size == 1 then
        self._head = nil
        self._tail = nil
    else
        self._tail = removedNode:GetPrevious()
        self._tail:SetNext(nil)
    end

    removedNode:Destroy()
    self._size = self._size - 1
end

-- 添加元素到头部
function LinkedList:PushFront(value)
    if self:IsDestroyed() then
        error("LinkedList PushFront failed: LinkedList is destroyed.")
    end
    if type(value) ~= self._elementType then
        error("LinkedList PushFront failed: value type mismatch. Expected '" .. self._elementType .. "', got '" .. type(value) .. "'.")
    end

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

-- 从头部移除元素
function LinkedList:PopFront()
    if self:IsDestroyed() then
        error("LinkedList PopFront failed: LinkedList is destroyed.")
    end
    if self._size == 0 then
        error("LinkedList PopFront failed: list is empty.")
    end

    local removedNode = self._head
    if self._size == 1 then
        self._head = nil
        self._tail = nil
    else
        self._head = removedNode:GetNext()
        self._head:SetPrevious(nil)
    end

    removedNode:Destroy()
    self._size = self._size - 1
end

-- 迭代器：正向遍历
function LinkedList:ForwardIterator()
    if self:IsDestroyed() then
        error("LinkedList ForwardIterator failed: LinkedList is destroyed.")
    end
    local current = self._head
    return function()
        if current then
            local value = current:GetValue()
            current = current:GetNext()
            return value
        else
            return nil
        end
    end
end

-- 迭代器：反向遍历
function LinkedList:BackwardIterator()
    if self:IsDestroyed() then
        error("LinkedList BackwardIterator failed: LinkedList is destroyed.")
    end
    local current = self._tail
    return function()
        if current then
            local value = current:GetValue()
            current = current:GetPrevious()
            return value
        else
            return nil
        end
    end
end

-- 打印链表内容
function LinkedList:Print()
    if self:IsDestroyed() then
        error("LinkedList Print failed: LinkedList is destroyed.")
    end

    print(tostring(self))
end

return {
    DoubleLinkNode = DoubleLinkNode,
    LinkedList = LinkedList
}
