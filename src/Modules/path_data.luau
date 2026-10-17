local path_data = {}

local map_folder = workspace:WaitForChild("Map_1")
local waypoint_folder = map_folder:WaitForChild("Waypoint"):WaitForChild("MainPath")

function path_data.get_waypoints()
    local waypoints = waypoint_folder:GetChildren()
    table.sort(waypoints, function(a, b)
        return tonumber(a.Name) < tonumber(b.Name)
    end)
    return waypoints
end

return path_data