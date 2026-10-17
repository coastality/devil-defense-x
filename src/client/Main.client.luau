local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local player = players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("TestingGUI")
local main_frame = gui:WaitForChild("MainFrame")

local name_input = main_frame:WaitForChild("EnemyName_Textbox")
local count_input = main_frame:WaitForChild("EnemyCount_Textbox")
local start_btn = main_frame:WaitForChild("WaveStart_Button")

local wave_event = rs.Events:WaitForChild("WaveStart")

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