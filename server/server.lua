-- The Framework variable holds the core object of the selected framework
Framework = exports['lsrp-core']:GetCoreObject()

-- This function registers a server callback based on the selected framework
function registerServerCallback(...)
    Framework.Functions.CreateCallback(...)
end

-- This server callback retrieves player data based on the selected framework
registerServerCallback("lsrp-pausemenu:getPlayerData", function(src, cb)
    -- Get the player object based on the selected framework
    local xPlayer = Framework.Functions.GetPlayer(src)

    -- If the player object is not found, log an error and callback with nil or default data
    if not xPlayer then
        print("Error: Player not found for source ID " .. tostring(src))  -- Ensure src is a string
        cb(nil)  -- Callback with nil or default data if necessary
        return  -- Exit the function to prevent further execution
    end

    -- Retrieve player data based on the selected framework
    local playerId = src
    local players = GetPlayers()
    local playerCount = #players
    local maxPlayers = GetConvarInt("sv_maxclients", 48)
    local cash, bank, name, job, grade, gender

-- Now we can safely access money, job, and charinfo data
cash = xPlayer.PlayerData.money and xPlayer.PlayerData.money.cash or 0
bank = xPlayer.PlayerData.money and xPlayer.PlayerData.money.bank or 0
job = xPlayer.PlayerData.job and xPlayer.PlayerData.job.label or "Unemployed"
grade = xPlayer.PlayerData.job and xPlayer.PlayerData.job.grade and xPlayer.PlayerData.job.grade.name or "None"
gender = xPlayer.PlayerData.charinfo.gender or "Unknown"
name = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname


    -- Callback with the retrieved player data
    cb({
        id = playerId,
        players = playerCount,
        maxPlayers = maxPlayers,
        bank = bank,
        wallet = cash,
        name = name,
        gender = gender,
        job = job,
        grade = grade
    })
end)

