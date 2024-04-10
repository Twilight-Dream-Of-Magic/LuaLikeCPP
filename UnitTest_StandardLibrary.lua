local StandardLibrary = require("StandardLibrary")

-- Is printing already loaded with this library?
-- print(package.loaded["StandardLibrary"])

-- Is this library already loaded?
if package.loaded["StandardLibrary"] ~= nil
then
    print("StandardLibrary already loaded")
    -- Clear the record for this load of this library file so that it can be repeated the next time.
    package.loaded["StandardLibrary"] = nil
    return
end

local function TestStandardLibraryArray()
    
    local Array = StandardLibrary.Containers.Array
    
    -- Test Array Creation
    local function TestArrayCreateAndDestroy()
        local array = Array.Create("number", 5)
        assert(array ~= nil, "Array should be created")
        assert(array:Size() == 5, "Array size should be 5")
        array:Destroy()
        assert(array:IsDestroyed() == true, "Array should be destroyed")
        
        -- Test invalid type creation
        local success, err = pcall(function() Array.Create("invalidType", 5) end)
        assert(not success, "Should fail on invalid type creation")
    end

    -- Test Set and Get
    local function TestSetAndGet()
        local array = Array.Create("number", 3)
        array:Set(1, 1)
        assert(array:Get(1) == 1, "Get and Set failed")
        
        -- Test out of bounds
        local result = array:Get(4)
        assert(result == nil, "Should return nil on out of bounds get")

        -- Test type mismatch
        success, err = pcall(function() array:Set(1, "string") end)
        assert(not success, "Should fail on type mismatch")
    end

    -- Test Front and Back
    local function TestFrontAndBack()
        local array = Array.Create("number", 2)
        array:Set(1, 10)
        array:Set(2, 20)
        assert(array:Front() == 10, "Front failed")
        assert(array:Back() == 20, "Back failed")
    end

    -- Test Fill
    local function TestFill()
        local array = Array.Create("number", 3)
        array:Fill(5)
        for i = 1, array:Size() do
            assert(array:Get(i) == 5, "Fill failed at index " .. i)
        end
    end

    -- Test Swap
    local function TestSwap()
        local array1 = Array.Create("number", 2)
        local array2 = Array.Create("number", 2)
        array1:Fill(1)
        array2:Fill(2)
        array1:Swap(array2)
        assert(array1:Get(1) == 2 and array2:Get(1) == 1, "Swap failed")
    end

    -- Test Iterators
    local function TestIterators()
        local array = Array.Create("number", 3)
        array:Fill(3)
        -- Forward Iterator
        for index, value in array:ForwardIterator()
        do
            assert(value == 3, "ForwardIterator failed at index " .. index)
        end
        -- Backward Iterator
        for index, value in array:BackwardIterator()
        do
            assert(value == 3, "BackwardIterator failed at index " .. index)
        end
    end

    -- Run all tests
    TestArrayCreateAndDestroy()
    TestSetAndGet()
    TestFrontAndBack()
    TestFill()
    TestSwap()
    TestIterators()

    print("All tests passed for StandardLibrary Array")
end

local function TestStandardLibraryDynamicArray()
    
    local DynamicArray = StandardLibrary.Containers.DynamicArray

    -- Test creation
    local function TestCreateAndDestroy()
        for _, t in ipairs({"number", "string", "boolean", "table", "function"})
        do
            local array = DynamicArray.Create(t)
            assert(array ~= nil, "Failed to create DynamicArray of type '" .. t .. "'")
            assert(array:Size() == 0, "DynamicArray size should be 0")
            array:Destroy()
            assert(array:IsDestroyed() == true, "DynamicArray should be destroyed")
        end
        local status, _ = pcall(function() DynamicArray.Create("invalid_type") end)
        assert(not status, "Create should fail with an invalid type")
    end

    -- Test Set and Get
    local function TestSetAndGet()
        local array = DynamicArray.Create("number")
        array:PushBack(1)
        array:Set(1, 2)
        assert(array:Get(1) == 2, "Set or Get function failed")
        local status, _ = pcall(function() array:Set(1, "string") end)
        assert(not status, "Set should fail with incorrect type")
        assert(array:Get(2) == nil, "Get should fail with index out of bounds")
    end

    -- Test PushBack, PopBack, and Size
    local function TestPushPopAndSize()
        local array = DynamicArray.Create("number")
        array:PushBack(1)
        array:PushBack(2)
        assert(array:Size() == 2, "PushBack or Size failed")
        array:PopBack()
        assert(array:Size() == 1 and array:Get(1) == 1, "PopBack or Size failed")
        array:PopBack()
        assert(array:Empty(), "Empty function failed")
    end

    -- Test Clear
    local function TestClear()
        local array = DynamicArray.Create("number")
        array:PushBack(1)
        array:Clear()
        assert(array:Empty(), "Clear function failed")
    end

    -- Test Insert and Erase
    local function TestInsertAndErase()
        local array = DynamicArray.Create("number")
        array:Insert(1, 1)
        array:Insert(2, 2)
        assert(array:Get(1) == 1 and array:Get(2) == 2, "Insert function failed")
        array:Erase(1)
        assert(array:Get(1) == 2 and array:Size() == 1, "Erase function failed")
        local status, err = pcall(function() array:Insert(3, 3) end)
        assert(not status, "Insert should fail with index out of bounds")
    end

    -- Test Resize and Capacity
    local function TestResizeAndCapacity()
        local array = DynamicArray.Create("number")
        array:Resize(3, 0)
        assert(array:Size() == 3 and array:Capacity() >= 3, "Resize or Capacity failed")
        array:ShrinkToFit()
        assert(array:Capacity() == 3, "ShrinkToFit failed")
        array:Reserve(5)
        assert(array:Capacity() == 5, "Reserve failed")
    end

    -- Test Iterators
    local function TestIterators()
        local array = DynamicArray.Create("number")
        array:PushBack(1)
        array:PushBack(2)
        array:PushBack(3)

        local forward = {}
        for i, v in array:ForwardIterator()
        do
            table.insert(forward, v)
        end
        assert(#forward == 3 and forward[1] == 1 and forward[3] == 3, "ForwardIterator failed")

        local backward = {}
        for i, v in array:BackwardIterator()
        do
            table.insert(backward, v)
        end
        assert(#backward == 3 and backward[1] == 3 and backward[3] == 1, "BackwardIterator failed")
    end

    -- Test AppendRange, EraseRange, and InsertRange
    local function TestRangeOperations()
        local array = DynamicArray.Create("number")
        local array2 = DynamicArray.Create("number")
        local array3 = DynamicArray.Create("number")

        -- Test AppendRange
        print("Testing AppendRange:")
        -- 合法情况
        pcall(function() array:AppendRange({1, 2, 3}) end)
        print("After appending valid range:", array)
        -- 非法情况
        local status, err = pcall(function() array:AppendRange({1, "string", 3}) end)
        print("Trying to append invalid type:", err)

        -- Test EraseRange
        print("\nTesting EraseRange:")
        array2:AppendRange({1, 2, 3, 4, 5}) -- 添加一些初始元素
        -- 合法情况
        pcall(function() array2:EraseRange(2, 4) end)
        print("After erasing valid range:", array2)
        -- 非法情况
        status, err = pcall(function() array2:EraseRange(2, 6) end)
        print("Trying to erase invalid range:", err)

        -- Test InsertRange
        print("\nTesting InsertRange:")
        -- 合法情况
        pcall(function() array3:InsertRange(1, {1, 2, 3}) end)
        print("After inserting valid range:", array3)
        -- 非法位置
        status, err = pcall(function() array3:InsertRange(10, {4, 5, 6}) end)
        print("Trying to insert at invalid position:", err)
        -- 非法类型
        status, err = pcall(function() array3:InsertRange(2, {7, "string", 9}) end)
        print("Trying to insert invalid type:", err)
    end

    -- Run all tests
    TestCreateAndDestroy()
    TestSetAndGet()
    TestPushPopAndSize()
    TestClear()
    TestInsertAndErase()
    TestResizeAndCapacity()
    TestIterators()
    TestRangeOperations()

    print("All tests passed for StandardLibrary DynamicArray")
end

TestStandardLibraryArray()
TestStandardLibraryDynamicArray()