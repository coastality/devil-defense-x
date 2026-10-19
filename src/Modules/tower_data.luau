local tower_data = {
    Units = {
        ["reze"] = {
            Name = "reze",
            Image = "rbxassetid://91865092689150",
            Cost = 300,
            Damage = 45,
            Range = 12,
            Cooldown = 2.4,
        },
        ["denji"] = {
            Name = "denji",
            Image = "rbxassetid://126440298050706",
            Cost = 250,
            Damage = 8,
            Range = 6,
            Cooldown = 0.3,

        },
        ["himeno"] = {
            Name = "himeno",
            Image = "rbxassetid://98348039379681",
            Cost = 250,
            Damage = 20,
            Range = 16,
            Cooldown = 1,
        }

    }
}

function tower_data.GetUnitData(unitKey: string)
    return tower_data.Units[unitKey]
end

return tower_data