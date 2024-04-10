-- StandardLibrary_Containers_DynamicArray.lua

local DynamicArray = {}
DynamicArray.__index = DynamicArray

-- 检查 DynamicArray 实例是否已被销毁
function DynamicArray:IsDestroyed()
    return self._elements == nil and self._elementType == nil and self._size == nil and self._capacity == nil
end

-- [[ Dynamic Array 功能的访问器 ]]

function DynamicArray:Set(index, element)
    if self:IsDestroyed() then
        error("DynamicArray Set 失败: DynamicArray 已被销毁。")
    end
    if type(element) ~= self._elementType or element == nil then
        error("类型不匹配: 尝试将 '" .. type(element) .. "' 插入到类型为 '" .. self._elementType .. "' 的 DynamicArray 中。")
    end
    if index < 1 or index > self._size then
        error("索引超出范围: '" .. index .. "'. 有效索引范围为 1 到 " .. self._size .. "。")
    end

    self._elements[index] = element
end

function DynamicArray:Get(index)
    if self:IsDestroyed() then
        error("DynamicArray Get 失败: DynamicArray 已被销毁。")
    end
    if index < 1 or index > self._size then
        print("警告: 索引超出范围: '" .. index .. "'. 有效索引范围为 1 到 " .. self._size .. "。返回 nil")
        return nil
    end
    return self._elements[index]
end

function DynamicArray:At(index)
    if self:IsDestroyed() then
        error("DynamicArray At 失败: DynamicArray 已被销毁。")
    end
    if index < 1 or index > self._size then
        error("索引超出范围")
    end
    return self._elements[index]
end

function DynamicArray:Front()
    if self:IsDestroyed() then
        error("DynamicArray Front 失败: DynamicArray 已被销毁。")
    end
    return self:Get(1)
end

function DynamicArray:Back()
    if self:IsDestroyed() then
        error("DynamicArray Back 失败: DynamicArray 已被销毁。")
    end
    return self:Get(self._size)
end

-- [[ Dynamic Array 功能的修改器 ]]

function DynamicArray:PushBack(element)
    if self:IsDestroyed() then
        error("DynamicArray PushBack 失败: DynamicArray 已被销毁。")
    end
    if type(element) ~= self._elementType or element == nil then
        error("类型不匹配: 尝试将 '" .. type(element) .. "' 插入到类型为 '" .. self._elementType .. "' 的 DynamicArray 中。")
    end
    self:Resize(self._size + 1, element)
end

function DynamicArray:PopBack()
    if self:IsDestroyed() then
        error("DynamicArray PopBack 失败: DynamicArray 已被销毁。")
    end
    if self._size > 0 then
        self._elements[self._size] = nil
        self._size = self._size - 1
    end
end

function DynamicArray:Insert(index, element)
    if self:IsDestroyed() then
        error("DynamicArray Insert 失败: DynamicArray 已被销毁。")
    end
    if type(element) ~= self._elementType or element == nil then
        error("类型不匹配: 尝试将 '" .. type(element) .. "' 插入到类型为 '" .. self._elementType .. "' 的 DynamicArray 中。")
    end
    if index < 1 or index > self._size + 1 then
        error("索引超出范围。")
    end
    table.insert(self._elements, index, element)
    self._size = self._size + 1
    if self._size > self._capacity then
        self._capacity = self._size
    end
end

function DynamicArray:Erase(index)
    if self:IsDestroyed() then
        error("DynamicArray Erase 失败: DynamicArray 已被销毁。")
    end
    if index < 1 or index > self._size then
        error("索引超出范围。")
    end
    table.remove(self._elements, index)
    self._size = self._size - 1
end

function DynamicArray:InsertRange(index, range)
    if self:IsDestroyed() then
        error("DynamicArray InsertRange 失败: DynamicArray 已被销毁。")
    end
    if type(range) ~= "table" then
        error("无效的范围: 期望一个表，但得到 '" .. type(range) .. "'")
    end

    if index < 1 or index > self._size + 1 then
        error("索引超出范围。")
    end

    local oldElements = {}
    for i = 1, self._size do
        oldElements[i] = self._elements[i]
    end

    for i, element in ipairs(range) do
        if type(element) ~= self._elementType or element == nil then
            self._elements = oldElements
            error("类型不匹配: 尝试将 '" .. type(element) .. "' 插入到类型为 '" .. self._elementType .. "' 的 DynamicArray 中。")
        end
        table.insert(self._elements, index + i - 1, element)
    end

    self._size = self._size + #range
    if self._size > self._capacity then
        self._capacity = self._size
    end
end

function DynamicArray:EraseRange(startIndex, endIndex)
    if self:IsDestroyed() then
        error("DynamicArray EraseRange 失败: DynamicArray 已被销毁。")
    end
    if not startIndex or not endIndex then
        error("无效的范围: startIndex 或 endIndex 为 nil。")
    end

    if startIndex < 1 or endIndex > self._size or startIndex > endIndex then
        error("无效的范围。")
    end

    for i = endIndex, startIndex, -1 do
        table.remove(self._elements, i)
    end

    self._size = self._size - (endIndex - startIndex + 1)
end

function DynamicArray:AppendRange(range)
    if self:IsDestroyed() then
        error("DynamicArray AppendRange 失败: DynamicArray 已被销毁。")
    end
    if type(range) ~= "table" then
        error("无效的范围: 期望一个表，但得到 '" .. type(range) .. "'")
    end

    for _, element in ipairs(range) do
        if type(element) ~= self._elementType or element == nil then
            error("类型不匹配: 尝试将 '" .. type(element) .. "' 插入到类型为 '" .. self._elementType .. "' 的 DynamicArray 中。")
        end
        table.insert(self._elements, element)
        self._size = self._size + 1
        if self._size > self._capacity then
            self._capacity = self._size
        end
    end
end

-- 直接访问底层连续存储
function DynamicArray:Data()
    if self:IsDestroyed() then
        error("DynamicArray Data 失败: DynamicArray 已被销毁。")
    end
    return self._elements
end

-- [[ 容量相关函数 ]]

function DynamicArray:Empty()
    if self:IsDestroyed() then
        error("DynamicArray Empty 失败: DynamicArray 已被销毁。")
    end
    return self._size == 0
end

function DynamicArray:Size()
    if self:IsDestroyed() then
        error("DynamicArray Size 失败: DynamicArray 已被销毁。")
    end
    return self._size
end

function DynamicArray:Capacity()
    if self:IsDestroyed() then
        error("DynamicArray Capacity 失败: DynamicArray 已被销毁。")
    end
    return self._capacity
end

function DynamicArray:Reserve(newCapacity)
    if self:IsDestroyed() then
        error("DynamicArray Reserve 失败: DynamicArray 已被销毁。")
    end
    if type(newCapacity) ~= "number" or newCapacity < 0 then
        error("无效的容量: 必须是非负数。")
    end
    if newCapacity > self._capacity then
        for i = self._capacity + 1, newCapacity do
            self._elements[i] = nil
        end
        self._capacity = newCapacity
    end
end

function DynamicArray:ShrinkToFit()
    if self:IsDestroyed() then
        error("DynamicArray ShrinkToFit 失败: DynamicArray 已被销毁。")
    end
    if self._size < self._capacity then
        for i = self._size + 1, self._capacity do
            self._elements[i] = nil
        end
        self._capacity = self._size
    end
end

function DynamicArray:Resize(newSize, fillValue)
    if self:IsDestroyed() then
        error("DynamicArray Resize 失败: DynamicArray 已被销毁。")
    end
    if type(newSize) ~= "number" or newSize < 0 then
        error("无效的大小: 大小必须是非负数。")
    end
    if newSize > self._size then
        if fillValue ~= nil and type(fillValue) ~= self._elementType then
            error("类型不匹配: 尝试用 '" .. type(fillValue) .. "' 填充 DynamicArray。")
        end
        for i = self._size + 1, newSize do
            self._elements[i] = fillValue
        end
    elseif newSize < self._size then
        for i = newSize + 1, self._size do
            self._elements[i] = nil
        end
    end
    self._size = newSize
    if self._size > self._capacity then
        self._capacity = self._size
    end
end

-- [[ 模拟 C++ 风格的迭代器函数 ]]

function DynamicArray:Begin()
    return 1
end

function DynamicArray:End()
    return self._size + 1
end

function DynamicArray:Rbegin()
    return self._size
end

function DynamicArray:Rend()
    return 0
end

-- 前向迭代器
function DynamicArray:ForwardIterator()
    if self:IsDestroyed() then
        error("DynamicArray ForwardIterator 失败: DynamicArray 已被销毁。")
    end
    if self._size == 0 then
        return function() return nil end
    end
    local index = self:Begin() - 1
    local endIndex = self:End() - 1
    return function()
        index = index + 1
        if index <= endIndex then
            return index, self._elements[index]
        else
            return nil
        end
    end
end

-- 逆向迭代器
function DynamicArray:BackwardIterator()
    if self:IsDestroyed() then
        error("DynamicArray BackwardIterator 失败: DynamicArray 已被销毁。")
    end
    if self._size == 0 then
        return function() return nil end
    end
    local index = self:Rbegin() + 1
    local endIndex = self:Rend() + 1
    return function()
        index = index - 1
        if index >= endIndex then
            return index, self._elements[index]
        else
            return nil
        end
    end
end

-- 随机访问迭代器
function DynamicArray:RandomAccessIterator(currentIndex, offset)
    if self:IsDestroyed() then
        error("DynamicArray RandomAccessIterator 失败: DynamicArray 已被销毁。")
    end
    if type(currentIndex) ~= "number" or type(offset) ~= "number" then
        error("RandomAccessIterator 失败: currentIndex 和 offset 必须是数字。")
    end
    local newIndex = currentIndex + offset
    if newIndex < 1 or newIndex > self._size then
        error("随机访问超出范围: 访问索引 '" .. newIndex .. "' 在大小为 " .. self._size .. " 的 DynamicArray 中。")
    end
    return newIndex, self._elements[newIndex]
end

-- 打印 DynamicArray 内容
function DynamicArray:Print()
    if self:IsDestroyed() then
        error("DynamicArray Print 失败: DynamicArray 已被销毁。")
    end
    local elementsTypeString = ""
    for i = 1, self._size do
        local element = self:Get(i)
        local elementStr = tostring(element)
        elementsTypeString = elementsTypeString .. elementStr .. (i < self._size and ", " or "")
    end
    print("DynamicArray [" .. elementsTypeString .. "]")
end

-- 构造函数
function DynamicArray.Create(elementType)
    local validTypes = {
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }

    if not validTypes[elementType] then
        error("DynamicArray 创建失败: '" .. tostring(elementType) .. "' 不是有效的类型。有效类型包括 'number', 'string', 'boolean', 'table', 'function'。")
    end

    local self = setmetatable({}, DynamicArray)
    self._elementType = elementType
    self._size = 0
    self._capacity = 0
    self._elements = {}
    return self
end

-- 清空 DynamicArray
function DynamicArray:Clear()
    if self:IsDestroyed() then
        error("DynamicArray Clear 失败: DynamicArray 已被销毁。")
    end
    for i = 1, self._size do
        self._elements[i] = nil
    end
    self._size = 0
end

-- 析构函数
function DynamicArray:Destroy()
    self:Clear()
    self._elementType = nil
    self._elements = nil
    self._size = nil
    self._capacity = nil
end

return DynamicArray
