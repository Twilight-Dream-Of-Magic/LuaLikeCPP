-- StandardLibrary_Containers_RedBlackTree.lua

-- [[ RedBlackTreeNode class ]]

local RedBlackTreeNode = {}
RedBlackTreeNode.__index = RedBlackTreeNode

-- Constructor for the RedBlackTreeNode class
function RedBlackTreeNode.Create(value)
    local self = setmetatable({}, RedBlackTreeNode)
    self.value = value
    self.color = "red" -- Default color for new nodes
    self.parent = nil
    self.left = nil
    self.right = nil
    return self
end

function RedBlackTreeNode:IsDestroyed()
    -- Check if the node is destroyed
    return self.value == nil
end

function RedBlackTreeNode:Clear()
    -- Clear the node's data
    self.value = nil
    self.color = nil
    self.parent = nil
    self.left = nil
    self.right = nil
end

-- Destructor for the RedBlackTreeNode class
function RedBlackTreeNode:Destroy()
    self:Clear()
end

-- [[ RedBlackTree class ]]

local RedBlackTree = {}
RedBlackTree.__index = RedBlackTree

-- Private functions for RedBlackTree

function RedBlackTree:Compare(value1, value2)
    if self.mode == "LessThan" then
        return value1 < value2
    elseif self.mode == "LessThanOrEqualTo" then
        return value1 <= value2
    elseif self.mode == "GreaterThan" then
        return value1 > value2
    elseif self.mode == "GreaterThanOrEqualTo" then
        return value1 >= value2
    else
        error("Invalid comparison mode")
    end
end

function RedBlackTree:GetColor(node)
    return node and node.color or "black"
end

-- RotateLeft(self, node)
-- 左旋转指定的节点。
-- node: 需要旋转的节点。
-- 这个操作会将 node 的右子节点移到 node 的位置，而 node 变成这个右子节点的左子节点。
-- 左旋转是维护红黑树平衡的关键操作之一。
local function RotateLeft(self, node)
    -- 右旋转的目标节点
    local rightChild = node.right
    node.right = rightChild.left

    if rightChild.left ~= nil then
        rightChild.left.parent = node
    end
    rightChild.parent = node.parent

    -- 如果节点是根节点，更新根节点
    if node.parent == nil then
        self.root = rightChild
    elseif node == node.parent.left then
        node.parent.left = rightChild
    else
        node.parent.right = rightChild
    end
    rightChild.left = node
    node.parent = rightChild
end

-- RotateRight(self, node)
-- 右旋转指定的节点。
-- node: 需要旋转的节点。
-- 这个操作会将 node 的左子节点移到 node 的位置，而 node 变成这个左子节点的右子节点。
-- 右旋转是维护红黑树平衡的关键操作之一。
local function RotateRight(self, node)
    -- 左旋转的目标节点
    local leftChild = node.left
    node.left = leftChild.right

    if leftChild.right ~= nil then
        leftChild.right.parent = node
    end
    leftChild.parent = node.parent

    -- 如果节点是根节点，更新根节点
    if node.parent == nil then
        self.root = leftChild
    elseif node == node.parent.right then
        node.parent.right = leftChild
    else
        node.parent.left = leftChild
    end
    leftChild.right = node
    node.parent = leftChild
end

-- FixInsertion(self, k)
-- 在插入新节点后修复红黑树的性质。
-- k: 新插入的节点。
-- 这个函数确保了红黑树在插入新节点后依旧保持其性质，包括节点颜色和平衡性。
local function FixInsertion(self, k)
    -- 继续修复，只要我们不是在根节点且父节点是红色
    while k ~= self.root and k.parent.color == "red" do
        -- 如果父节点是祖父节点的左子节点
        if k.parent == k.parent.parent.left then
            local uncle = k.parent.parent.right  -- 祖父节点的右子节点作为叔叔节点
            -- 如果叔叔节点存在且为红色
            if uncle and uncle.color == "red" then
                -- 把父节点和叔叔节点变为黑色以修复性质
                k.parent.color = "black"
                uncle.color = "black"
                -- 把祖父节点变成红色并继续修复
                k.parent.parent.color = "red"
                k = k.parent.parent
            else
                -- 如果当前节点是父节点的右子节点
                if k == k.parent.right then
                    -- 在父节点上做左旋转
                    k = k.parent
                    RotateLeft(self, k)
                end
                -- 重新着色并在祖父节点上做右旋转
                k.parent.color = "black"
                k.parent.parent.color = "red"
                RotateRight(self, k.parent.parent)
            end
        else
            -- 父节点是祖父节点的右子节点（逻辑与上面相反）
            local uncle = k.parent.parent.left  -- 祖父节点的左子节点作为叔叔节点

            if uncle and uncle.color == "red" then
                k.parent.color = "black"
                uncle.color = "black"
                k.parent.parent.color = "red"
                k = k.parent.parent
            else
                if k == k.parent.left then
                    k = k.parent
                    RotateRight(self, k)
                end
                k.parent.color = "black"
                k.parent.parent.color = "red"
                RotateLeft(self, k.parent.parent)
            end
        end
    end
    -- 确保根节点总是黑色
    self.root.color = "black"
end

-- FixErasement(self, x)
-- 在删除节点后修复红黑树的性质。
-- x: 受影响的节点，通常是被删除节点的子节点或替代节点。
-- 这个函数确保了红黑树在删除节点后依旧保持其性质，特别是当删除黑色节点时可能需要进行一系列复杂的操作来保持平衡。
function RedBlackTree:FixErasement(x)
    while x ~= self.root and x.color == "black" do
        if x == x.parent.left then
            local sibling = x.parent.right
            if sibling.color == "red" then
                sibling.color = "black"
                x.parent.color = "red"
                RotateLeft(self, x.parent)
                sibling = x.parent.right
            end
            if sibling.left.color == "black" and sibling.right.color == "black" then
                sibling.color = "red"
                x = x.parent
            else
                if sibling.right.color == "black" then
                    sibling.left.color = "black"
                    sibling.color = "red"
                    RotateRight(self, sibling)
                    sibling = x.parent.right
                end
                sibling.color = x.parent.color
                x.parent.color = "black"
                sibling.right.color = "black"
                RotateLeft(self, x.parent)
                x = self.root
            end
        else
            -- 对称的处理对于 x 是其父节点的右子节点的情况
            local sibling = x.parent.left
            if sibling.color == "red" then
                sibling.color = "black"
                x.parent.color = "red"
                RotateRight(self, x.parent)
                sibling = x.parent.left
            end
            if sibling.right.color == "black" and sibling.left.color == "black" then
                sibling.color = "red"
                x = x.parent
            else
                if sibling.left.color == "black" then
                    sibling.right.color = "black"
                    sibling.color = "red"
                    RotateLeft(self, sibling)
                    sibling = x.parent.left
                end
                sibling.color = x.parent.color
                x.parent.color = "black"
                sibling.left.color = "black"
                RotateRight(self, x.parent)
                x = self.root
            end
        end
    end
    x.color = "black"
end

-- Transplant(self, u, v)
-- 用 v 子树替换 u 子树。
-- u: 被替换的节点。
-- v: 替换用的节点。
-- 这是红黑树删除操作中的关键步骤，用于调整树中的链接。
function RedBlackTree:Transplant(u, v)
    -- 判断 u 是否是根节点
    if u.parent == nil then
        -- 如果 u 是根节点，那么 v 成为新的根节点
        self.root = v
    elseif u == u.parent.left then
        -- 如果 u 是其父节点的左子节点，将 v 设置为 u 的父节点的左子节点
        u.parent.left = v
    else
        -- 如果 u 是其父节点的右子节点，将 v 设置为 u 的父节点的右子节点
        u.parent.right = v
    end
    -- 如果 v 不是空节点，更新 v 的父节点为 u 的父节点
    if v then v.parent = u.parent end
end

-- Public Red-Black Tree operations

function RedBlackTree:MinimumNode(node)
    while node.left ~= nil do
        node = node.left
    end
    return node
end

function RedBlackTree:MaximumNode(node)
    while node.right ~= nil do
        node = node.right
    end
    return node
end

-- Access the first node
function RedBlackTree:Front()
    if self:IsDestroyed() then
        error("RedBlackTree GetFirst failed: RedBlackTree is destroyed.")
    end
    return self:MinimumNode(self.root).value
end

-- Access the last node
function RedBlackTree:Back()
    if self:IsDestroyed() then
        error("RedBlackTree GetLast failed: RedBlackTree is destroyed.")
    end
    return self:MaximumNode(self.root).value
end

function RedBlackTree:Next()
    -- 如果有右子节点，返回右子树中的最小节点
    if self.right then
        return self.right:Minimum()
    end

    -- 否则，向上查找第一个左子树包含当前节点的祖先
    local node = self
    while node.parent and node == node.parent.right do
        node = node.parent
    end
    return node.parent
end

function RedBlackTree:Previous()
    -- 如果有左子节点，返回左子树中的最大节点
    if self.left then
        return self.left:Maximum()
    end

    -- 否则，向上查找第一个右子树包含当前节点的祖先
    local node = self
    while node.parent and node == node.parent.left do
        node = node.parent
    end
    return node.parent
end

-- Insert(self, value)
-- 向红黑树中插入一个新值。
-- value: 要插入的值。
-- 该方法会创建一个新的节点来存储这个值，并插入到树中适当的位置，然后调用 FixInsertion 方法来维护红黑树的性质。
function RedBlackTree:Insert(value)
    local newNode = RedBlackTreeNode.Create(value)  -- 创建新节点
    local parentNode = nil  -- 将要成为新节点的父节点
    local currentNode = self.root  -- 当前遍历到的节点，开始时是根节点

    -- 寻找新节点的插入位置
    while currentNode ~= nil do
        parentNode = currentNode
        if self:Compare(newNode.value, currentNode.value) then
            currentNode = currentNode.left  -- 向左子树移动
        else
            currentNode = currentNode.right  -- 向右子树移动
        end
    end

    -- 设置新节点的父节点
    newNode.parent = parentNode
    if parentNode == nil then
        -- 树是空的，新节点成为根节点
        self.root = newNode
    elseif self:Compare(newNode.value, parentNode.value) then
        parentNode.left = newNode  -- 新节点作为左子节点
    else
        parentNode.right = newNode  -- 新节点作为右子节点
    end

    -- 初始化新节点的子节点和颜色
    newNode.left = nil
    newNode.right = nil
    newNode.color = "red"

    -- 修复可能因插入操作而打破的红黑树性质
    FixInsertion(self, newNode)
end

-- Erase(self, value)
-- 从红黑树中删除一个值。
-- value: 要删除的值。
-- 该方法会找到并删除存储此值的节点。如果需要，会调用 FixErasement 方法来维护红黑树的性质。
function RedBlackTree:Erase(value)
    local targetNode = self.root  -- 开始搜索的节点

    -- 查找要删除的节点
    while targetNode ~= nil do
        if self:Compare(value, targetNode.value) then
            targetNode = targetNode.left
        elseif self:Compare(targetNode.value, value) then
            targetNode = targetNode.right
        else
            break  -- 找到了要删除的节点
        end
    end

    if targetNode == nil then
        return  -- 没有找到节点，直接返回
    end

    local y = targetNode
    local originalColor = y.color  -- 保存原始颜色，用于之后判断是否需要修复树
    local x

    if targetNode.left == nil then
        x = targetNode.right
        self:Transplant(targetNode, targetNode.right)
    elseif targetNode.right == nil then
        x = targetNode.left
        self:Transplant(targetNode, targetNode.left)
    else
        y = self:MinimumNode(targetNode.right)
        originalColor = y.color
        x = y.right

        if y.parent == targetNode then
            if x then x.parent = y end
        else
            self:Transplant(y, y.right)
            y.right = targetNode.right
            y.right.parent = y
        end

        self:Transplant(targetNode, y)
        y.left = targetNode.left
        y.left.parent = y
        y.color = targetNode.color
    end

    -- 如果删除的是黑色节点，可能需要修复树
    if originalColor == "black" then
        self:FixErasement(x)
    end
end

-- Find(self, value)
-- 在红黑树中查找一个值。
-- value: 要查找的值。
-- 该方法会遍历树以查找存储此值的节点，并返回该节点。如果未找到，则返回 nil。
function RedBlackTree:Find(value)
    local currentNode = self.root  -- 从根节点开始搜索

    -- 遍历树寻找值
    while currentNode ~= nil do
        if self:Compare(value, currentNode.value) then
            currentNode = currentNode.left  -- 向左子树移动
        elseif self:Compare(currentNode.value, value) then
            currentNode = currentNode.right  -- 向右子树移动
        else
            return currentNode  -- 找到了节点
        end
    end
    return nil  -- 没有找到节点
end

-- Traverse(self, node, callback)
-- 遍历红黑树，并对每个节点执行一个回调函数。
-- node: 开始遍历的节点。
-- callback: 对每个节点执行的回调函数。
-- 这是一个递归函数，按照中序遍历（左-根-右）的顺序访问树中的每
function RedBlackTree:Traverse(node, callback)
    if node ~= nil then
        self:Traverse(node.left, callback)  -- 遍历左子树
        callback(node)  -- 对当前节点执行回调
        self:Traverse(node.right, callback)  -- 遍历右子树
    end
end

-- Constructor for the RedBlackTree class
function RedBlackTree.Create(compare_mode)
    local self = setmetatable({}, RedBlackTree)
    self.root = nil
    self.mode = compare_mode or "LessThan" -- 默认为 LessThan
    return self
end

function RedBlackTree:IsDestroyed()
    -- Check if the tree is destroyed
    return self.root == nil
end

function RedBlackTree:Clear()
    -- Destroy all RedBlackTreeNode and Clear the tree
    self:Traverse
    (
        self.root,
        function(node)
            node:Destroy()
        end
    )
end

function RedBlackTree:Destroy()
    self:Clear()
    self.root = nil
end

return RedBlackTree