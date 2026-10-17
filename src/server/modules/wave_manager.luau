local rs = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")
local path_data = require(rs.Modules.path_data)
local movement = require(sss.Server.modules.movement)

local wave_manager = {}

function wave_manager.dispatch(enemy_key, count)
    print("dispatching wave for:", enemy_key, count)
    local enemies_folder = rs:WaitForChild("Enemies")
    if not enemies_folder then
        return
    end

    local prefab = enemies_folder:FindFirstChild("Enemy_" .. enemy_key)
    if not prefab then
        return
    end

    task.spawn(function()
    local waypoints = path_data.get_waypoints()
    print("waypoints count:", #waypoints, "first:", waypoints[1].Name)

        for _ = 1, count do
            local clone = prefab:Clone()
            local hrp = clone:FindFirstChild("HumanoidRootPart")

            if not hrp then
                warn("no HumanoidRootPart in " .. prefab.Name)
                return
            end

            clone.PrimaryPart = hrp

            clone:PivotTo(waypoints[1].CFrame + Vector3.new(0, 0.5, 0))
            clone.Parent = workspace

            print("spawned at:", hrp.Position, "waypoint:", waypoints[1].Position)

            local result = workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0))
            print("ground below:", result and result.Instance:GetFullName() or "NOTHING")

            movement.traverse(clone)
            task.wait(1)
        end
    end)
end

return wave_manager