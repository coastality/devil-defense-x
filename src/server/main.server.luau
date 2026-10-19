local rs = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")
local wave_manager = require(sss.Server.modules.wave_manager)

local wave_event = rs.Events:WaitForChild("WaveStart")

wave_event.OnServerEvent:Connect(function(player, enemy_key, count)
    if typeof(enemy_key) ~= "string" or typeof(count) ~= "number" then
        return
    end
    if count <= 0 or count > 50 then
        return
    end

    wave_manager.dispatch(enemy_key, count)
end)

local place_event = rs.Events:WaitForChild("PlaceTower")

local function get_towers_folder()
    local towers_folder = workspace:FindFirstChild("Towers")
    if not towers_folder then
        warn("no tower folder")
    end
    return towers_folder
end

place_event.OnServerEvent:Connect(function(player, tower_name, position)
    if typeof(tower_name) ~= "string" or typeof(position) ~= "Vector3" then return end
    local towers_storage = rs:WaitForChild("Towers")
    local template = towers_storage:FindFirstChild(tower_name)

    if not template then return end

    local clone = template:Clone()
    clone:SetAttribute("UnitKey", tower_name)

    local hrp = clone:FindFirstChild("HumanoidRootPart") or clone.PrimaryPart
    if hrp then
        clone.PrimaryPart = hrp
        clone:PivotTo(CFrame.new(position) + Vector3.new(0, (2 * 0.65), 0))
    else
        clone:MoveTo(position)
    end

    clone.Parent = get_towers_folder()
end)