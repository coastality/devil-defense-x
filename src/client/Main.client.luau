local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local uis = game:GetService("UserInputService")


local player = players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("TestingGUI")
local main_frame = gui:WaitForChild("MainFrame")

local name_input = main_frame:WaitForChild("EnemyName_Textbox")
local count_input = main_frame:WaitForChild("EnemyCount_Textbox")
local start_btn = main_frame:WaitForChild("WaveStart_Button")
local close_btn = main_frame:WaitForChild("Close_Button")
local open_btn = player:WaitForChild("PlayerGui"):WaitForChild("TestingGUI"):WaitForChild("WaveOpen_Button")

local wave_event = rs.Events:WaitForChild("WaveStart")

open_btn.Activated:Connect(function()
    main_frame.Visible = true
end)
close_btn.Activated:Connect(function()
    main_frame.Visible = false
end)

start_btn.Activated:Connect(function()
    local enemy_key = name_input.Text
    local count = tonumber(count_input.Text)

    if not enemy_key or enemy_key == "" then
        return
    end
    if not count or count <= 0 then
        return
    end

    wave_event:FireServer(enemy_key, count)
end)

local tower_data = require(rs:WaitForChild("Modules"):WaitForChild("tower_data"))

local user_gui = player:WaitForChild("PlayerGui"):WaitForChild("UserGUI")
local unit_selection = user_gui:WaitForChild("UnitSelection")
local unit_frame = user_gui:WaitForChild("UnitFrame")

local back_frame = unit_frame:WaitForChild("BackFrame")
local back_label = back_frame:WaitForChild("TextLabel")
local back_arrow = back_frame:WaitForChild("Arrow_Back")

local unit_overview = unit_frame:WaitForChild("Unit_Overview")
local unit_name_label = unit_overview:WaitForChild("UnitName")
local unit_image = unit_overview:WaitForChild("UnitImage")
local upg_tree_btn = unit_overview:WaitForChild("UpgTreeButton")

local upgrade_tree = unit_frame:WaitForChild("Upgrade_Tree")
local nodes_group = upgrade_tree:WaitForChild("Nodes"):WaitForChild("CanvasGroup")

unit_frame.Visible = false

local placement_active = false
local selected_tower_key = nil
local ghost_model = nil
local mouse = player:GetMouse()

local function change_view(mode)
    if mode == "overview" then
        unit_overview.Visible = true
        upgrade_tree.Visible = false
        back_label.Text = "unit overview"
        back_arrow.Visible = false
        back_arrow.Active = false
    elseif mode == "tree" then
        unit_overview.Visible = false
        upgrade_tree.Visible = true
        back_label.Text = "upgrade tree"
        back_arrow.Visible = true
        back_arrow.Active = true
    end
end

local function open_unit(unit_key) -- Ayoo
    local data = tower_data.GetUnitData(unit_key)
    if not data then return end

    unit_name_label.Text = data.Name
    unit_image.Image = data.Image
    change_view("overview")
    unit_frame.Visible = true
end

unit_frame.Visible = false
change_view("overview")


local function create_ghost(tower_name)
    if ghost_model then
        ghost_model:Destroy()
        ghost_model = nil
    end

    local template = rs:WaitForChild("Towers"):WaitForChild(tower_name, 3)
    if template then
        ghost_model = template:Clone()
        for _, part in ipairs(ghost_model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.CanCollide = false
            end
        end
        ghost_model.Parent = workspace
    end
end

run_service.RenderStepped:Connect(function()
    if placement_active and ghost_model then
        local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local raycast_params = RaycastParams.new()
        raycast_params.FilterType = Enum.RaycastFilterType.Exclude
        raycast_params.FilterDescendantsInstances = {player.Character, ghost_model}

        local result = workspace:Raycast(ray.Origin, ray.Direction * 500, raycast_params)
        if result and result.Position then
            local target_cf = CFrame.new(result.Position) + Vector3.new(0, 3.2, 0)
            if ghost_model.PrimaryPart then
                ghost_model:SetPrimaryPartCFrame(target_cf)
            else
                ghost_model:PivotTo(target_cf)
            end
        end
    end
end)

local function get_tower_from_part(part)
    local towers_folder = workspace:FindFirstChild("Towers")
    if not towers_folder then return nil end

    local current = part
    while current and current.Parent ~= towers_folder do
        current = current.Parent
    end
    if current and current:IsA("Model") then
        return current
    end
    return nil
end


uis.InputBegan:Connect(function(input, game_processed)
    if game_processed then
        return
    end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end
    if placement_active and ghost_model then
        local pos = ghost_model.PrimaryPart and ghost_model.PrimaryPart.Position or ghost_model:GetPivot().Position
        local base_pos = pos - Vector3.new(0, (2 *0.65), 0)
        local event = rs:WaitForChild("Events"):WaitForChild("PlaceTower", 3)
        
        if event then
            event:FireServer(selected_tower_key, base_pos)
        end
        
        ghost_model:Destroy()
        ghost_model = nil
        placement_active = false

        return
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}

    local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
    local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)

    if result and result.Instance then
        local tower = get_tower_from_part(result.Instance)
        if tower then
            open_unit(tower:GetAttribute("UnitKey") or tower.Name)
        end
    end
end)


for _, btn in ipairs(unit_selection:GetChildren()) do
    if btn:IsA("GuiButton") or btn:IsA("ImageButton") then
        local unit_attr = btn:GetAttribute("UnitKey")
        if unit_attr then
            btn.MouseButton1Click:Connect(function()
                unit_frame.Visible = false
                selected_tower_key = unit_attr
                placement_active = true
                create_ghost(unit_attr)
            end)
        end
    end
end

upg_tree_btn.MouseButton1Click:Connect(function()
    change_view("tree")
end)

back_arrow.MouseButton1Click:Connect(function()
    change_view("overview")
end)