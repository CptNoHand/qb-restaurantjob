QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('qb-restaurant:server:get:ingredient', function(source, cb, items)
    local src = source
    local Ply = QBCore.Functions.GetPlayer(src)
    local items = items
    local hasItems = true
    for k, v in pairs(items) do
        hasItems = hasItems and (Ply.Functions.GetItemByName(v) ~= nil)
    end
    cb(hasItems)
end)

RegisterNetEvent("qb-restaurant:server:cook")
AddEventHandler("qb-restaurant:server:cook", function(items, giveitem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.AddItem(giveitem, 1) then
        for k, v in pairs(items) do
            Player.Functions.RemoveItem(v, 1)
            TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[v], "remove")
        end
        TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[giveitem], "add")
    end
end)
