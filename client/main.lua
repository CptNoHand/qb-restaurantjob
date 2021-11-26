QBCore = exports['qb-core']:GetCoreObject()

isLoggedIn = false

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(JobInfo)
    isLoggedIn = true
    PlayerJob = JobInfo
end)

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    local idle = 100
    while true do
        Wait(idle)
        if isLoggedIn then
            local playerped = PlayerPedId()
            for k, v in pairs(Config.Locations) do
                -- body
                if #(GetEntityCoords(playerped) - v.coords) < 2.0 and PlayerJob.name == Config.Job then
                    inRange = true
                    idle = 0
                    DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[E] "..v.text)
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent("qb-restaurant:client:OpenMenu", v.config)
                    end
                end
            end

            for k, v in pairs(Config.JobStash) do
                -- body
                if #(GetEntityCoords(playerped) - v.coords) < 2.0 then
                -- if #(GetEntityCoords(playerped) - v.coords) < 2.0 and PlayerJob.name == Config.Job then
                    inRange = true
                    idle = 0
                    DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[E] Access Job Stash")
                    if IsControlJustPressed(0, 38) then
                        TriggerEvent("qb-restaurant:client:jobstash", v.name, v.size, v.slots)
                    end
                end
            end

            if inRange then
                idle = 0
            else
                idle = 100
            end
        end
    end
end)


--Oven station--
RegisterNetEvent("qb-restaurant:client:OpenMenu")
AddEventHandler("qb-restaurant:client:OpenMenu", function(config)
    for k, v in pairs(config) do
        TriggerEvent('nh-context:sendMenu',{
            {
                id = k,
                header = v.label,
                txt = v.description,
                params = {
                    event = "qb-restaurant:menu:AllStations",
                    args = {
                        item = v.item, --item that will be given
                        required = v.required, -- required items to make
                        progressbar = v.progressbar, -- text to display on progressbar
                        progresstime = v.progresstime, -- in milliseconds
                        dictionary = v.dictionary, --dictionary name for animation
                        animname = v.animname --animation name
                    }
                }
            },
        })
    end 
end)

RegisterNetEvent("qb-restaurant:menu:AllStations")
AddEventHandler("qb-restaurant:menu:AllStations", function(data)
    QBCore.Functions.TriggerCallback('qb-restaurant:server:get:ingredient', function(HasItems)
        if HasItems then
            local ped = PlayerPedId()
            local playerPed = PlayerPedId()
            local src = source 
            LoadAnim(data.dictionary)
            TaskPlayAnim(ped, data.dictionary, data.animname, 6.0, -6.0, -1, 46, 0, 0, 0, 0)
            FreezeEntityPosition(playerPed, true)
                QBCore.Functions.Progressbar("cutting_station", data.progressbar, data.progresstime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done    
                
                ClearPedTasksImmediately(ped)
                FreezeEntityPosition(playerPed, false)
            TriggerServerEvent('qb-restaurant:server:cook', data.required, data.item)
            end)
        else
            QBCore.Functions.Notify("You don\'t have all the ingredients!", "error")
        end
    end, data.required)
end)

--stash--
RegisterNetEvent("qb-restaurant:client:jobstash")
AddEventHandler("qb-restaurant:client:jobstash", function(name, size, slots)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", name, {
        maxweight = size,
        slots = slots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", name)
end)

function LoadAnim(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end