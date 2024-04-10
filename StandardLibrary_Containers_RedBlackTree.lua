-- StandardLibrary_Containers_RedBlackTree.lua

-- [[ RedBlackTreeNode class ]]

local RedBlackTreeNode = {}
RedBlackTreeNode.__index = RedBlackTreeNode
RedBlackTreeNode.__type = "RedBlackTreeNode" -- Type identifier

-- Metamethod __tostring for printing the node's key and value
function RedBlackTreeNode:__tostring()
    return tostring(self.key) .. ": " .. tostring(self.value) .. "(" .. self.color:sub(1,1):upper() .. ")"
end

-- Set the node's key and value
function RedBlackTreeNode:Set(key, value)
    if type(key) ~= self.keyType then
        error("RedBlackTreeNode Set function failed: Key type '" .. type(key) .. "' does not match expected type '" .. self.keyType .. "'.")
    end
    -- Value type can be 'any' or a specific type
    if self.valueType ~= "any" and type(value) ~= self.valueType then
        error("RedBlackTreeNode Set function failed: Value type '" .. type(value) .. "' does not match expected type '" .. self.valueType .. "'.")
    end
    self.key = key
    self.value = value
end

-- Get the node's key
function RedBlackTreeNode:GetKey()
    return self.key
end

-- Get the node's value
function RedBlackTreeNode:GetValue()
    return self.value
end

-- Constructor
function RedBlackTreeNode.Create(keyType, valueType, key, value)
    local validKeyTypes = {
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }

    local validValueTypes = {
        any = true,
        number = true,
        string = true,
        boolean = true,
        table = true,
        ["function"] = true
    }

    if not validKeyTypes[keyType] then
        error("RedBlackTreeNode creation failed: Key type '" .. keyType .. "' is not valid. Valid key types are 'number', 'string', 'boolean', 'table', 'function'.")
    end

    if not validValueTypes[valueType] then
        error("RedBlackTreeNode creation failed: Value type '" .. valueType .. "' is not valid. Valid value types are 'any', 'number', 'string', 'boolean', 'table', 'function'.")
    end

    if key == nil or type(key) ~= keyType then
        error("RedBlackTreeNode creation failed: Key type mismatch. Expected '" .. keyType .. "', got '" .. type(key) .. "'.")
    end

    if value == nil or (valueType ~= "any" and type(value) ~= valueType) then
        error("RedBlackTreeNode creation failed: Value type mismatch. Expected '" .. valueType .. "', got '" .. type(value) .. "'.")
    end

    local self = setmetatable({}, RedBlackTreeNode)
    self.keyType = keyType
    self.valueType = valueType
    self.key = key
    self.value = value
    self.color = "red" -- Default color is red
    self.parent = nil
    self.left = nil
    self.right = nil

    return self
end

-- Destroy the node
function RedBlackTreeNode:Destroy()
    self.key = nil
    self.value = nil
    self.color = nil
    self.parent = nil
    self.left = nil
    self.right = nil
    self.keyType = nil
    self.valueType = nil
end

-- Check if the node is destroyed
function RedBlackTreeNode:IsDestroyed()
    return self.key == nil
end

-- [[ RedBlackTree class ]]

local RedBlackTree = {}
RedBlackTree.__index = RedBlackTree
RedBlackTree.__type = "RedBlackTree" -- Type identifier

-- Metamethod __tostring for printing the tree's contents
function RedBlackTree:__tostring()
    if self:IsDestroyed() then
        return "RedBlackTree (destroyed)"
    end

    local result = "{ "
    local iterator = self:InOrderIterator()
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
    return "RedBlackTree " .. result
end

-- Constructor
function RedBlackTree.Create(comparator, keyType, valueType)
    local self = setmetatable({}, RedBlackTree)
    self.root = nil
    self.size = 0 -- Initialize size
    self.keyType = keyType or "any" -- Default key type is 'any'
    self.valueType = valueType or "any" -- Default value type is 'any'
    -- Comparator is a function that compares two keys
    if comparator and type(comparator) == "function" then
        self.compare = comparator
    else
        self.compare = function(a, b)
            return a < b
        end
    end
    return self
end

-- Check if the tree is destroyed
function RedBlackTree:IsDestroyed()
    return self.root == nil
end

-- Clear the tree
function RedBlackTree:Clear()
    local function destroySubtree(node)
        if node ~= nil then
            destroySubtree(node.left)
            destroySubtree(node.right)
            node:Destroy()
        end
    end
    destroySubtree(self.root)
    self.root = nil
    self.size = 0
end

-- Destroy the tree
function RedBlackTree:Destroy()
    self:Clear()
    self.compare = nil
    self.keyType = nil
    self.valueType = nil
end

-- Get the color of a node, nil nodes are considered black
function RedBlackTree:GetColor(node)
    if node == nil then
        return "black"
    else
        return node.color
    end
end

-- Left rotate
local function RotateLeft(self, node)
    local y = node.right
    node.right = y.left
    if y.left ~= nil then
        y.left.parent = node
    end
    y.parent = node.parent
    if node.parent == nil then
        self.root = y
    elseif node == node.parent.left then
        node.parent.left = y
    else
        node.parent.right = y
    end
    y.left = node
    node.parent = y
end

-- Right rotate
local function RotateRight(self, node)
    local y = node.left
    node.left = y.right
    if y.right ~= nil then
        y.right.parent = node
    end
    y.parent = node.parent
    if node.parent == nil then
        self.root = y
    elseif node == node.parent.right then
        node.parent.right = y
    else
        node.parent.left = y
    end
    y.right = node
    node.parent = y
end

-- Fix insertion
local function FixInsertion(self, node)
    while node.parent and node.parent.color == "red" do
        if node.parent == node.parent.parent.left then
            local uncle = node.parent.parent.right
            if uncle and uncle.color == "red" then
                -- Case 1: Uncle is red
                node.parent.color = "black"
                uncle.color = "black"
                node.parent.parent.color = "red"
                node = node.parent.parent
            else
                if node == node.parent.right then
                    -- Case 2: Uncle is black and node is right child
                    node = node.parent
                    RotateLeft(self, node)
                end
                -- Case 3: Uncle is black and node is left child
                node.parent.color = "black"
                node.parent.parent.color = "red"
                RotateRight(self, node.parent.parent)
            end
        else
            -- Mirror image of above
            local uncle = node.parent.parent.left
            if uncle and uncle.color == "red" then
                -- Case 1
                node.parent.color = "black"
                uncle.color = "black"
                node.parent.parent.color = "red"
                node = node.parent.parent
            else
                if node == node.parent.left then
                    -- Case 2
                    node = node.parent
                    RotateRight(self, node)
                end
                -- Case 3
                node.parent.color = "black"
                node.parent.parent.color = "red"
                RotateLeft(self, node.parent.parent)
            end
        end
    end
    self.root.color = "black"
end

-- Fix deletion
local function FixDeletion(self, node)
    while node ~= self.root and (node == nil or node.color == "black") do
        if node == node.parent.left then
            local sibling = node.parent.right
            if sibling and sibling.color == "red" then
                -- Case 1
                sibling.color = "black"
                node.parent.color = "red"
                RotateLeft(self, node.parent)
                sibling = node.parent.right
            end
            if (not sibling.left or sibling.left.color == "black") and (not sibling.right or sibling.right.color == "black") then
                -- Case 2
                if sibling then
                    sibling.color = "red"
                end
                node = node.parent
            else
                if not sibling.right or sibling.right.color == "black" then
                    -- Case 3
                    if sibling.left then
                        sibling.left.color = "black"
                    end
                    sibling.color = "red"
                    RotateRight(self, sibling)
                    sibling = node.parent.right
                end
                -- Case 4
                if sibling then
                    sibling.color = node.parent.color
                    node.parent.color = "black"
                    if sibling.right then
                        sibling.right.color = "black"
                    end
                end
                RotateLeft(self, node.parent)
                node = self.root
            end
        else
            -- Mirror image of above
            local sibling = node.parent.left
            if sibling and sibling.color == "red" then
                -- Case 1
                sibling.color = "black"
                node.parent.color = "red"
                RotateRight(self, node.parent)
                sibling = node.parent.left
            end
            if (not sibling.left or sibling.left.color == "black") and (not sibling.right or sibling.right.color == "black") then
                -- Case 2
                if sibling then
                    sibling.color = "red"
                end
                node = node.parent
            else
                if not sibling.left or sibling.left.color == "black" then
                    -- Case 3
                    if sibling.right then
                        sibling.right.color = "black"
                    end
                    sibling.color = "red"
                    RotateLeft(self, sibling)
                    sibling = node.parent.left
                end
                -- Case 4
                if sibling then
                    sibling.color = node.parent.color
                    node.parent.color = "black"
                    if sibling.left then
                        sibling.left.color = "black"
                    end
                end
                RotateRight(self, node.parent)
                node = self.root
            end
        end
    end
    if node then
        node.color = "black"
    end
end

-- Transplant subtree u with subtree v
function RedBlackTree:Transplant(u, v)
    if u.parent == nil then
        self.root = v
    elseif u == u.parent.left then
        u.parent.left = v
    else
        u.parent.right = v
    end
    if v ~= nil then
        v.parent = u.parent
    end
end

-- Find the minimum node starting from a given node
function RedBlackTree:MinimumNode(node)
    while node.left ~= nil do
        node = node.left
    end
    return node
end

-- Find the maximum node starting from a given node
function RedBlackTree:MaximumNode(node)
    while node.right ~= nil do
        node = node.right
    end
    return node
end

-- Insert a key-value pair into the tree
function RedBlackTree:Insert(key, value)
    -- Create a new node
    local newNode = RedBlackTreeNode.Create(self.keyType, self.valueType, key, value)

    local y = nil
    local x = self.root

    while x ~= nil do
        y = x
        if self.compare(newNode.key, x.key) then
            x = x.left
        else
            x = x.right
        end
    end

    newNode.parent = y
    if y == nil then
        self.root = newNode
    elseif self.compare(newNode.key, y.key) then
        y.left = newNode
    else
        y.right = newNode
    end

    -- Initialize left and right children to nil and color to red
    newNode.left = nil
    newNode.right = nil
    newNode.color = "red"

    -- Increment size
    self.size = self.size + 1

    -- Fix the red-black tree properties
    FixInsertion(self, newNode)
end

-- Erase a key from the tree
function RedBlackTree:Erase(key)
    local z = self:FindNode(key)
    if z == nil then
        return -- Key not found
    end

    local y = z
    local yOriginalColor = y.color
    local x

    if z.left == nil then
        x = z.right
        self:Transplant(z, z.right)
    elseif z.right == nil then
        x = z.left
        self:Transplant(z, z.left)
    else
        y = self:MinimumNode(z.right)
        yOriginalColor = y.color
        x = y.right
        if y.parent == z then
            if x ~= nil then
                x.parent = y
            end
        else
            self:Transplant(y, y.right)
            y.right = z.right
            if y.right ~= nil then
                y.right.parent = y
            end
        end
        self:Transplant(z, y)
        y.left = z.left
        if y.left ~= nil then
            y.left.parent = y
        end
        y.color = z.color
    end

    -- Decrement size
    self.size = self.size - 1

    if yOriginalColor == "black" then
        FixDeletion(self, x)
    end

    -- Destroy the removed node
    z:Destroy()
end

-- Find a node by key
function RedBlackTree:FindNode(key)
    local current = self.root
    while current ~= nil do
        if key == current.key then
            return current
        elseif self.compare(key, current.key) then
            current = current.left
        else
            current = current.right
        end
    end
    return nil
end

-- Check if the tree contains a key
function RedBlackTree:Contains(key)
    return self:FindNode(key) ~= nil
end

-- Get the size of the tree
function RedBlackTree:Size()
    return self.size
end

-- In-order traversal iterator returning key-value pairs
function RedBlackTree:InOrderIterator()
    local stack = {}
    local current = self.root
    return function()
        while current ~= nil do
            table.insert(stack, current)
            current = current.left
        end
        if #stack == 0 then
            return nil, nil
        end
        current = table.remove(stack)
        local key = current.key
        local value = current.value
        current = current.right
        return key, value
    end
end

-- Traverse the tree in-order and apply a callback to each key-value pair
function RedBlackTree:Traverse(callback)
    if not callback then
        error("Traverse function requires a callback.")
    end
    local iterator = self:InOrderIterator()
    while true do
        local key, value = iterator()
        if key == nil then break end
        callback(key, value)
    end
end

-- Get the smallest key in the tree
function RedBlackTree:Front()
    if self.root == nil then
        return nil, nil
    end
    local node = self:MinimumNode(self.root)
    return node.key, node.value
end

-- Get the largest key in the tree
function RedBlackTree:Back()
    if self.root == nil then
        return nil, nil
    end
    local node = self:MaximumNode(self.root)
    return node.key, node.value
end

-- Get the next node in in-order traversal
function RedBlackTree:NextNode(node)
    if node.right ~= nil then
        return self:MinimumNode(node.right)
    end
    local parent = node.parent
    while parent ~= nil and node == parent.right do
        node = parent
        parent = parent.parent
    end
    return parent
end

-- Get the previous node in in-order traversal
function RedBlackTree:PreviousNode(node)
    if node.left ~= nil then
        return self:MaximumNode(node.left)
    end
    local parent = node.parent
    while parent ~= nil and node == parent.left do
        node = parent
        parent = parent.parent
    end
    return parent
end

-- Pre-order traversal iterator (returns key-value pairs)
function RedBlackTree:PreOrderIterator()
    local stack = {}
    local current = self.root
    if current ~= nil then
        table.insert(stack, current)
    end
    return function()
        if #stack == 0 then
            return nil, nil
        end
        current = table.remove(stack)
        local key = current.key
        local value = current.value
        if current.right ~= nil then
            table.insert(stack, current.right)
        end
        if current.left ~= nil then
            table.insert(stack, current.left)
        end
        return key, value
    end
end

-- Post-order traversal iterator (returns key-value pairs)
function RedBlackTree:PostOrderIterator()
    local stack = {}
    local lastVisited = nil
    local current = self.root
    return function()
        while current ~= nil do
            table.insert(stack, current)
            current = current.left
        end
        while #stack > 0 do
            local peekNode = stack[#stack]
            if peekNode.right ~= nil and lastVisited ~= peekNode.right then
                current = peekNode.right
                while current ~= nil do
                    table.insert(stack, current)
                    current = current.left
                end
                peekNode = stack[#stack]
            else
                table.remove(stack)
                lastVisited = peekNode
                return peekNode.key, peekNode.value
            end
        end
        return nil, nil
    end
end

-- [[ Example: Print the contents of the RedBlackTree ]]

-- Print the tree's in-order traversal
function RedBlackTree:PrintInOrder()
    if self:IsDestroyed() then
        print("RedBlackTree (destroyed)")
        return
    end
    local iterator = self:InOrderIterator()
    local result = "{ "
    while true do
        local key, value = iterator()
        if key == nil then break end
        result = result .. tostring(key) .. ": " .. tostring(value) .. ", "
    end
    -- Remove trailing comma and space
    if result:sub(-2) == ", " then
        result = result:sub(1, -3)
    end
    result = result .. " }"
    print("RedBlackTree (InOrder): " .. result)
end

-- Print the tree's pre-order traversal
function RedBlackTree:PrintPreOrder()
    if self:IsDestroyed() then
        print("RedBlackTree (destroyed)")
        return
    end
    local iterator = self:PreOrderIterator()
    local result = "{ "
    while true do
        local key, value = iterator()
        if key == nil then break end
        result = result .. tostring(key) .. ": " .. tostring(value) .. ", "
    end
    -- Remove trailing comma and space
    if result:sub(-2) == ", " then
        result = result:sub(1, -3)
    end
    result = result .. " }"
    print("RedBlackTree (PreOrder): " .. result)
end

-- Print the tree's post-order traversal
function RedBlackTree:PrintPostOrder()
    if self:IsDestroyed() then
        print("RedBlackTree (destroyed)")
        return
    end
    local iterator = self:PostOrderIterator()
    local result = "{ "
    while true do
        local key, value = iterator()
        if key == nil then break end
        result = result .. tostring(key) .. ": " .. tostring(value) .. ", "
    end
    -- Remove trailing comma and space
    if result:sub(-2) == ", " then
        result = result:sub(1, -3)
    end
    result = result .. " }"
    print("RedBlackTree (PostOrder): " .. result)
end

return RedBlackTree
