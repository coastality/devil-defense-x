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