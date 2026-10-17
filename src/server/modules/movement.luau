local rs = game:GetService("ReplicatedStorage")
local path_data = require(rs.Modules.path_data)
local ts = game:GetService("TweenService")
local move_speed = 8


local movement = {}

function movement.traverse(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then
        return
    end

    local waypoints = path_data.get_waypoints()

    task.spawn(function()
        root.Anchored = true
        local height_offset = root.Position.Y - waypoints[1].Position.Y
        for _, node in ipairs(waypoints) do
            if not model.Parent then break end

            local destination = node.Position + Vector3.new(0, height_offset, 0)
            local flat_direction = Vector3.new(destination.X - root.Position.X, 0, destination.Z - root.Position.Z)
            if flat_direction.Magnitude < 0.1 then
                continue
            end

            local distance = (destination - root.Position).Magnitude
            local info = TweenInfo.new(distance / move_speed, Enum.EasingStyle.Linear)
            local goal = { CFrame = CFrame.new(destination, destination + flat_direction) }
        
            local tween = ts:Create(root, info, goal)
            tween:Play()
            tween.Completed:Wait()
        end

        if model.Parent then
            model:Destroy()
        end
    end)
end

return movement