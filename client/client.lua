-- This variable determines which framework to use based on the value of Config.Framework.
-- If Config.Framework is "lsrp", it uses the 'lsrp-core' framework.
local Framework = Config.Framework == "lsrp" and exports['lsrp-core']:GetCoreObject()

local open = false -- Flag to track if the pause menu is open
local cam -- Variable to store the camera object

-- Callback function triggered when the NUI (Native UI) is loaded
RegisterNUICallback("loaded", function(_, cb)
    cb(Config.Tabs) -- Sends the Config.Tabs data to the NUI
end)

-- Callback function triggered when an event is received from the NUI
RegisterNUICallback("event", function(eType)
    -- Handle different event types
    if eType == "close" then
        TriggerServerEvent("lsrp-pausemenu:dropPlayer") -- Triggers a server event to drop the player
    elseif eType == "settings" then
        ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'),1,-1) -- Activates the settings menu
        SetNuiFocus(false, false) -- Releases NUI focus
    elseif eType == "map" then
        ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'),1,-1) -- Activates the map menu
        SetNuiFocus(false, false) -- Releases NUI focus
    elseif eType == "resume" then
        SetNuiFocus(false, false) -- Releases NUI focus
    end

    local playerPed = PlayerPedId() -- Gets the player's ped (character) ID
    open = false -- Sets the open flag to false
    FreezeEntityPosition(playerPed, false) -- Unfreezes the player's position
    DestroyCam(cam, false) -- Destroys the camera object
    DisplayRadar(true) -- Displays the radar
    RenderScriptCams(false, false, 0, false, false) -- Stops rendering script cameras
end)

-- Command to open the pause menu
RegisterCommand('OpenPauseMenu', function()
    if GetCurrentFrontendMenuVersion() == -1 and not IsNuiFocused() then
        open = true -- Sets the open flag to true
        OpenPauseMenu() -- Calls the OpenPauseMenu function
    end
end)

-- Key mapping for opening the pause menu
RegisterKeyMapping('OpenPauseMenu', 'Open Pause Menu', 'keyboard', 'ESCAPE')

-- Thread that continuously checks if the pause menu is open and sets the pause menu active flag accordingly
CreateThread(function()
    while true do 
        if open then
            SetPauseMenuActive(false) -- Sets the pause menu active flag to false
        end

        Wait(1) -- Waits for 1 millisecond
    end
end)

-- Function to trigger a server callback using the 'lsrp-core' framework
function triggerServerCallback(...)
    Framework.Functions.TriggerCallback(...) -- Triggers a server callback using the 'lsrp-core' framework
end

-- Function to open the pause menu
function OpenPauseMenu()
    triggerServerCallback("lsrp-pausemenu:getPlayerData", function(cb)
        SetNuiFocus(true, true) -- Sets NUI focus

        -- Sends player data to the NUI
        SendNUIMessage({
            action = "setData",
            id = cb?.id,
            players = cb?.players,
            maxPlayers = cb?.maxPlayers,
            bank = cb?.bank,
            wallet = cb?.wallet,
            name = cb?.name,
            gender = cb?.gender,
            job = cb?.job,
            grade = cb?.grade,
        })

        local ped = PlayerPedId() -- Gets the player's ped (character) ID
        local coords = GetOffsetFromEntityInWorldCoords(ped, 0, 1.1, 0) -- Gets the offset coordinates from the player's ped
        FreezeEntityPosition(ped, true) -- Freezes the player's position
        RenderScriptCams(false, false, 0, 1, 0) -- Stops rendering script cameras
        DestroyCam(cam, false) -- Destroys the camera object
        FreezePedCameraRotation(ped) -- Freezes the player's camera rotation

        if not DoesCamExist(cam) then
            DisplayRadar(false) -- Hides the radar
            cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) -- Creates a new camera object
            SetCamActive(cam, true) -- Sets the new camera as active
            RenderScriptCams(true, false, 0, true, true) -- Starts rendering script cameras
            SetCamUseShallowDofMode(cam, true) -- Sets the camera to use shallow depth of field mode
            SetCamNearDof(cam, 0) -- Sets the near depth of field value for the camera
            SetCamFarDof(cam, 1.3) -- Sets the far depth of field value for the camera
            SetCamDofStrength(cam, 0.1) -- Sets the depth of field strength for the camera
            SetPedCanPlayAmbientAnims(ped, true) -- Allows the player's ped to play ambient animations
        end

        if not IsPedInAnyVehicle(ped, false) then 
            SetCamCoord(cam, coords.x, coords.y, coords.z + 0.6) -- Sets the camera coordinates
            SetCamRot(cam, 0.0, 0.0, GetEntityHeading(ped) + 180) -- Sets the camera rotation

            while DoesCamExist(cam) do
                SetUseHiDof() -- Sets the camera to use high depth of field
                Wait(0) -- Waits for the next frame
            end
        end
    end)
end
