-- StandardLibrary_Containers_Array.lua

-- ArrayPrivateData
local PrivateInstances = setmetatable({}, {__mode = "k"}) -- 使用弱引用表来防止内存泄漏

-- Make ArrayPrivateData
local function NewArrayPrivateData(elementType, fixedSize)
    local validTypes = {
        number = true, 
        string = true, 
        boolean = true, 
        table = true, 
        ["function"] = true
    }

    if not validTypes[elementType]
    then
        error("Array creation failed: '" .. elementType .. "' is not a valid type. Valid types are 'number', 'string', 'boolean', 'table', 'function'.")
    end
    
    local instance = {
        _ElementType = elementType,
        _FixedSize = fixedSize,
        _Elements = {}
    }

    local defaultValue = nil
    if elementType == "number"
    then
        defaultValue = 0
    elseif elementType == "string"
    then
        defaultValue = ""
    elseif elementType == "boolean"
    then
        defaultValue = false
    elseif elementType == "table"
    then
        defaultValue = {}
    elseif elementType == "function"
    then
        defaultValue = function() end
    end

    for i = 1, fixedSize
    do
        instance._Elements[i] = defaultValue
    end
    return instance
end

-- ArrayPrivateData access
local function AccessPrivate(instance)
    return PrivateInstances[instance]
end

-- Array object definition
local Array = {}
Array.__index = function(table, key)
    if Array[key] ~= nil
    then
        return Array[key]
    else
        local private = AccessPrivate(table)
        if private ~= nil
        then
            return private[key]
        end
    end
end

-- Modified IsDestroyed function
function Array:IsDestroyed()
    return PrivateInstances[self] == nil
end

-- Modified Set function
function Array:Set(index, element)
    local private = AccessPrivate(self)
    if self:IsDestroyed() then
        error("Array Set failed: Array is destroyed.")
    end

    if type(element) ~= private._ElementType or element == nil
    then
        error("Type mismatch: Attempted to insert '" .. type(element) .. "' into Array of type '" .. private._ElementType .. "'.")
    end
    if index < 1 or index > private._FixedSize
    then
        error("Index out of bounds: '" .. index .. "'. Valid indices are from 1 to " .. private._FixedSize .. ".")
    end

    private._Elements[index] = element
end

-- Modified Get function
function Array:Get(index)
    local private = AccessPrivate(self)
    if self:IsDestroyed()
    then
        error("Array Get failed: Array is destroyed.")
    end
    if index < 1 or index > private._FixedSize
    then
        warn("Index out of bounds: '" .. index .. "'. Valid indices are from 1 to " .. private._FixedSize .. "." .. "\n Returned is nil")
        return nil
    end
    return private._Elements[index]
end

-- Modified At function
function Array:At(index)
    local private = AccessPrivate(self)
    if self:IsDestroyed()
    then
        error("Array At failed: Array is destroyed.")
    end
    if index < 1 or index > private._FixedSize
    then
        error("Index out of bounds")
    end
    return private._Elements[index]
end

-- Access the first element
function Array:Front()
    if self:IsDestroyed()
    then
        error("Array Front failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    return private and private._Elements[1]
end

-- Access the last element
function Array:Back()
    if self:IsDestroyed()
    then
        error("Array Back failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    return private and private._Elements[private._FixedSize]
end

-- Direct access to the underlying contiguous storage
function Array:Data()
    if self:IsDestroyed()
    then
        error("Array Data failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    return private and private._Elements
end

-- [[ Capacity functions ]]

function Array:Empty()
    if self:IsDestroyed()
    then
        error("Array Empty failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    return private._FixedSize == 0
end

function Array:Size()
    if self:IsDestroyed()
    then
        error("Array Size failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    return private._FixedSize
end

-- [[ Operations ]]

function Array:Fill(value)
    if self:IsDestroyed()
    then
        error("Array Fill failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    -- Check Type
    if type(value) ~= private._ElementType
    then
        error("Type mismatch: Attempted to fill Array of type '" .. private._ElementType .. "' with '" .. type(value) .. "'.")
    end
    
    for i = 1, private._FixedSize do
        private._Elements[i] = value
    end
end

function Array:Swap(otherArray)
    if getmetatable(otherArray) ~= Array
    then
        error("Invalid swap: the provided object is not an Array")
    end
    if self:IsDestroyed() or otherArray:IsDestroyed()
    then
        error("Array Swap failed: One of the Arrays is destroyed.")
    end
    local privateSelf = AccessPrivate(self)
    local privateOther = AccessPrivate(otherArray)
    privateSelf._Elements, privateOther._Elements = privateOther._Elements, privateSelf._Elements
end

-- [[ Iterator functions to mimic C++ style iterators ]]

function Array:Begin()
    local private = AccessPrivate(self)
    return 1
end

function Array:End()
    local private = AccessPrivate(self)
    return private._FixedSize + 1
end

function Array:Rbegin()
    local private = AccessPrivate(self)
    return private._FixedSize
end

function Array:Rend()
    return 0
end

-- Forward Iterator
function Array:ForwardIterator()
    if self:IsDestroyed()
    then
        error("Array ForwardIterator failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    assert(private._FixedSize > 0, "Array is empty")
    local index = 0  -- Start before the first element
    local endIndex = private._FixedSize  -- End at the last element
    return function()
        index = index + 1
        if index <= endIndex
        then
            return index, private._Elements[index] -- {key is index, value is element} pair
        else
            return nil
        end
    end
end

-- Backward Iterator
function Array:BackwardIterator()
    if self:IsDestroyed()
    then
        error("Array BackwardIterator failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    assert(private._FixedSize > 0, "Array is empty")
    local index = private._FixedSize + 1  -- Start after the last element
    local endIndex = 0  -- End at the first element
    return function()
        index = index - 1
        if index > endIndex
        then
            return index, private._Elements[index] -- {key is index, value is element} pair
        else
            return nil
        end
    end
end

-- Random Access Iterator
function Array:RandomAccessIterator(currentIndex, offset)
    if self:IsDestroyed()
    then
        error("Array RandomAccessIterator failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    assert(private._FixedSize > 0, "Array is empty")
    assert(type(currentIndex) == "number" and type(offset) == "number", "Both CurrentIndex and Offset must be numbers")
    local newIndex = currentIndex + offset
    if newIndex < 1 or newIndex > private._FixedSize
    then
        error("Random access out of bounds: Accessing index '" .. newIndex .. "' in an Array of size " .. private._FixedSize)
    end
    return private._Elements[newIndex]
end

-----

function Array:Print()
    if self:IsDestroyed()
    then
        error("Array Print failed: Array is destroyed.")
    end
    local private = AccessPrivate(self)
    local elementsTypeString = ""
    for i = 1, private._FixedSize
    do
        local element = private._Elements[i]
        local elementTypeString = type(element) == "function" and "function" or tostring(element)
        elementsTypeString = elementsTypeString .. elementTypeString .. (i < private._FixedSize and ", " or "")
    end
    print("Array [" .. elementsTypeString .. "]")
end

-- Constructor for the Array class
function Array.Create(elementType, fixedSize)
    -- Create private data instance
    local privateData = NewArrayPrivateData(elementType, fixedSize)
    local self = setmetatable({}, Array)

    -- Store the private data
    PrivateInstances[self] = privateData

    return self
end

function Array:Clear()
    if self:IsDestroyed()
    then
        error("Array Clear failed: Array is destroyed.")
    end
    -- Access private data
    local private = AccessPrivate(self)
    if not private then 
        return 
    end

    local defaultValue = nil
    if private._ElementType == "number"
    then
        defaultValue = 0
    elseif private._ElementType == "string"
    then
        defaultValue = ""
    elseif private._ElementType == "boolean"
    then
        defaultValue = false
    elseif private._ElementType == "table"
    then
        defaultValue = {}
    elseif private._ElementType == "function"
    then
        defaultValue = function() end
    end
    
    -- Reset elements to default value
    for i = 1, private._FixedSize do
        private._Elements[i] = defaultValue
    end
end

-- Destructor for the Array class
function Array:Destroy()
    self:Clear()

    -- Access and remove private data
    local private = AccessPrivate(self)
    if private
    then
        private._ElementType = nil
        private._Elements = nil
        private._FixedSize = nil
        PrivateInstances[self] = nil
    end
end

return Array