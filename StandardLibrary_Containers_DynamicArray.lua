-- StandardLibrary_Containers_DynamicArray.lua

local DynamicArray = {}
DynamicArray.__index = DynamicArray

-- Check instance is DynamicArray should be destroyed
function DynamicArray:IsDestroyed()
    return self._elements == nil and self._elementType == nil and self._fixedSize == nil and self._capacity == nil
end

-- [[ Accessor for Dynamic Array functionality ]]

function DynamicArray:Set(index, element)
    if self:IsDestroyed()
    then
        error("DynamicArray Set failed: DynamicArray is destroyed.")
    end
    if type(element) ~= self._elementType or element == nil
    then
        error("Type mismatch: Attempted to insert '" .. type(element) .. "' into DynamicArray of type '" .. self._elementType .. "'.")
    end
    if index < 1 or index > self._size
    then
        error("Index out of bounds: '" .. index .. "'. Valid indices are from 1 to " .. self._size .. ".")
    end

    self._elements[index] = element
end

function DynamicArray:Get(index)
    if self:IsDestroyed()
    then
        error("DynamicArray Get failed: DynamicArray is destroyed.")
    end
    if index < 1 or index > self._size
    then
        warn("Index out of bounds: '" .. index .. "'. Valid indices are from 1 to " .. self._size .. "." .. "\n Returned is nil")
        return nil
    end
    return self._elements[index]
end

function DynamicArray:At(index)
    if self:IsDestroyed()
    then
        error("DynamicArray At failed: DynamicArray is destroyed.")
    end
    if index < 1 or index > self._size
    then
        error("Index out of bounds")
    end
    return self._elements[index]
end

function DynamicArray:Front()
    if self:IsDestroyed()
    then
        error("DynamicArray Front failed: DynamicArray is destroyed.")
    end
    return self:Get(1)
end

function DynamicArray:Back()
    if self:IsDestroyed()
    then
        error("DynamicArray Back failed: DynamicArray is destroyed.")
    end
    return self:Get(self._size)
end

-- [[ Modifier for Dynamic Array functionality ]]

function DynamicArray:PushBack(element)
    if self:IsDestroyed()
    then
        error("DynamicArray PushBack failed: DynamicArray is destroyed.")
    end
    if type(element) ~= self._elementType or element == nil
    then
        error("Type mismatch: Attempted to insert '" .. type(element) .. "' into DynamicArray of type '" .. self._elementType .. "'.")
    end
    self:Resize(self._size + 1, element)
end

function DynamicArray:PopBack()
    if self:IsDestroyed()
    then
        error("DynamicArray PopBack failed: DynamicArray is destroyed.")
    end
    if self._size > 0
    then
        self._elements[self._size] = nil
        self._size = self._size - 1
    end
end

function DynamicArray:Insert(index, element)
    if self:IsDestroyed()
    then
        error("DynamicArray Insert failed: DynamicArray is destroyed.")
    end
    if type(element) ~= self._elementType or element == nil
    then
        error("Type mismatch: Attempted to insert '" .. type(element) .. "' into DynamicArray of type '" .. self._elementType .. "'.")
    end
    if index < 1 or index > self._size + 1
    then
        error("Index out of bounds.")
    end
    table.insert(self._elements, index, element)
    self._size = self._size + 1
    if self._size > self._capacity
    then
        self._capacity = self._size
    end
end

function DynamicArray:Erase(index)
    if self:IsDestroyed()
    then
        error("DynamicArray Erase failed: DynamicArray is destroyed.")
    end
    if index < 1 or index > self._size
    then
        error("Index out of bounds.")
    end
    table.remove(self._elements, index)
    self._size = self._size - 1
end

function DynamicArray:InsertRange(index, range)
    if self:IsDestroyed()
    then
        error("DynamicArray InsertRange failed: DynamicArray is destroyed.")
    end
    if not range or type(range) ~= "table"
    then
        error("Invalid range: Expected a table, got " .. type(range))
    end

    if index < 1 or index > self._size + 1
    then
        error("Index out of bounds.")
    end

    local oldElements = {}
    for i = 1, self._size
    do
        oldElements[i] = self._elements[i]
    end

    local isSuccess, errorMsg = true, nil

    for i, element in ipairs(range)
    do
        if type(element) ~= self._elementType or element == nil then
            isSuccess = false
            errorMsg = "Type mismatch: Attempted to insert '" .. type(element) .. "' into DynamicArray of type '" .. self._elementType .. "'."
            break
        end
        table.insert(self._elements, index + i - 1, element)
    end

    if not isSuccess
    then
        self._elements = oldElements
        error(errorMsg)
    end

    self._size = self._size + #range
    if self._size > self._capacity
    then
        self._capacity = self._size
    end
end

function DynamicArray:EraseRange(startIndex, endIndex)
    if self:IsDestroyed()
    then
        error("DynamicArray EraseRange failed: DynamicArray is destroyed.")
    end
    if not startIndex or not endIndex
    then
        error("Invalid range: startIndex or endIndex is nil.")
    end

    if startIndex < 1 or endIndex > self._size or startIndex > endIndex
    then
        error("Invalid range.")
    end

    for i = endIndex, startIndex, -1
    do
        table.remove(self._elements, i)
    end

    self._size = self._size - (endIndex - startIndex + 1)
end

function DynamicArray:AppendRange(range)
    if self:IsDestroyed()
    then
        error("DynamicArray AppendRange failed: DynamicArray is destroyed.")
    end
    if not range or type(range) ~= "table"
    then
        error("Invalid range: Expected a table, got " .. type(range))
    end

    for _, element in ipairs(range)
    do
        if type(element) ~= self._elementType or element == nil
        then
            error("Type mismatch: Attempted to append '" .. type(element) .. "' into DynamicArray of type '" .. self._elementType .. "'.")
        end
        table.insert(self._elements, self._size + 1, element)
        self._size = self._size + 1
    end

    if self._size > self._capacity
    then
        self._capacity = self._size
    end
end

-- Direct access to the underlying contiguous storage
function DynamicArray:Data()
    if self:IsDestroyed()
    then
        error("DynamicArray Data failed: DynamicArray is destroyed.")
    end
    return self._elements
end

-- [[ Capacity functions ]]

function DynamicArray:Empty()
    if self:IsDestroyed()
    then
        error("DynamicArray Empty failed: DynamicArray is destroyed.")
    end
    return self._size == 0
end

function DynamicArray:Size()
    if self:IsDestroyed()
    then
        error("DynamicArray Size failed: DynamicArray is destroyed.")
    end
    return self._size
end

function DynamicArray:Capacity()
    if self:IsDestroyed()
    then
        error("DynamicArray Capacity failed: DynamicArray is destroyed.")
    end
    return self._capacity
end

function DynamicArray:Reserve(newCapacity)
    if self:IsDestroyed()
    then
        error("DynamicArray Reserve failed: DynamicArray is destroyed.")
    end
    if newCapacity > self._capacity
    then
        for i = self._capacity + 1, newCapacity
        do
            self._elements[i] = nil
        end
        self._capacity = newCapacity
    end
end

function DynamicArray:ShrinkToFit()
    if self:IsDestroyed()
    then
        error("DynamicArray ShrinkToFit failed: DynamicArray is destroyed.")
    end
    if self._size < self._capacity
    then
        for i = self._size + 1, self._capacity
        do
            self._elements[i] = nil
        end
        self._capacity = self._size
    end
end

function DynamicArray:Resize(newSize, fillValue)
    if self:IsDestroyed()
    then
        error("DynamicArray Resize failed: DynamicArray is destroyed.")
    end
    if newSize < 0
    then
        error("Invalid size: Negative size is not allowed.")
    end
    if type(fillValue) ~= self._elementType or fillValue == nil
    then
        error("Type mismatch: Attempted to fill '" .. type(fillValue) .. "' into DynamicArray of type '" .. self._elementType .. "'.")
    end
    if newSize > self._size
    then
        for i = self._size + 1, newSize
        do
            self._elements[i] = fillValue or nil
        end
    elseif newSize < self._size
    then
        for i = newSize + 1, self._size
        do
            self._elements[i] = nil
        end
    end
    self._size = newSize
    if newSize > self._capacity
    then
        self._capacity = newSize
    end
end

-- [[ Iterator functions to mimic C++ style iterators ]]

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

-- Forward Iterator
function DynamicArray:ForwardIterator()
    if self:IsDestroyed()
    then
        error("DynamicArray ForwardIterator failed: Array is destroyed.")
    end
    assert(self._size > 0, "DynamicArray is empty")
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
function DynamicArray:BackwardIterator()
    if self:IsDestroyed()
    then
        error("DynamicArray BackwardIterator failed: Array is destroyed.")
    end
    assert(self._size > 0, "DynamicArray is empty")
    local index = self:Rbegin() + 1  -- Start after the last element
    local endIndex = self:Rend() + 1  -- End at the first element
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

-- Random Access Iterator
function DynamicArray:RandomAccessIterator(currentIndex, offset)
    if self:IsDestroyed()
    then
        error("DynamicArray RandomAccessIterator failed: Array is destroyed.")
    end
    assert(self._size > 0, "DynamicArray is empty")
    assert(type(currentIndex) == "number" and type(offset) == "number", "Both CurrentIndex and Offset must be numbers")
    local newIndex = currentIndex + offset
    if newIndex < 1 or newIndex > self._fixedSize
    then
        error("Random access out of bounds: Accessing index '" .. newIndex .. "' in an DynamicArray of size " .. self._fixedSize)
    end
    return self._elements[newIndex]
end

-----

function DynamicArray:Print()
    if self:IsDestroyed()
    then
        error("DynamicArray Print failed: Array is destroyed.")
    end
    local elementsTypeString = ""
    for i = 1, self._size
    do
        local element = self:Get(i)
        local elementTypeString = type(element) == "function" and "function" or tostring(element)
        elementsTypeString = elementsTypeString .. elementTypeString .. (i < self._size and ", " or "")
    end
    print("DynamicArray [" .. elementsTypeString .. "]")
end

-- Constructor for the DynamicArray class
function DynamicArray.Create(elementType)
    local validTypes = {
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }
    
    if not validTypes[elementType]
    then
        error("DynamicArray creation failed: '" .. elementType .. "' is not a valid type. Valid types are 'number', 'string', 'boolean', 'table', 'function'.")
    end

    local self = setmetatable({}, DynamicArray)
    self._elementType = elementType
    self._size = 0
    self._capacity = 0
    self._elements = {}
    return self
end

function DynamicArray:Clear()
    -- Get Type Default value
    local defaultValue = nil
    if self._elementType == "number"
    then
        defaultValue = 0
    elseif self._elementType == "string"
    then
        defaultValue = ""
    elseif self._elementType == "boolean"
    then
        defaultValue = false
    elseif self._elementType == "table"
    then
        defaultValue = {}
    elseif self._elementType == "function"
    then
        defaultValue = function() end
    end
    
    for i = 1, self._size
    do
        self._elements[i] = defaultValue
    end
    self._size = 0
end

-- Destructor for the DynamicArray class
function DynamicArray:Destroy()
    self:Clear()
    self._elementType = nil
    self._elements = nil
    self._size = nil
    self._capacity = nil
end

return DynamicArray