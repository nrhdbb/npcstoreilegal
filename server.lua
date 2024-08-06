local QBCore = exports['qb-core']:GetCoreObject()
local markedBillsWorth = 1
RegisterNetEvent('hadiresource:sellitem', function(item, price, itemAmount, payMethod)
    local PlayerId = source
    local Player = QBCore.Functions.GetPlayer(PlayerId)
    if not item or not Player then return end
    local totalPay = itemAmount * price
    if Player.Functions.RemoveItem(item, itemAmount, false) then
        TriggerClientEvent('inventory:client:ItemBox', PlayerId, QBCore.Shared.Items[item], "remove", itemAmount)

        if payMethod == 'cash' then
            Player.Functions.AddMoney('cash', totalPay, 'Items Sold')
            TriggerClientEvent('QBCore:Notify', PlayerId, 'Item sold successfully for cash!', 'success')
        elseif payMethod == 'markedbills' then
            local bags = math.floor(totalPay / markedBillsWorth) 
            local info = { worth = markedBillsWorth }

            Player.Functions.AddItem('markedbills', bags, false, info)
            TriggerClientEvent('QBCore:Notify', PlayerId, 'Item sold successfully for marked bills!', 'success')
        else
            TriggerClientEvent('QBCore:Notify', PlayerId, 'Invalid payment method!', 'error')
            Player.Functions.AddItem(item, itemAmount)
        end
    else
        TriggerClientEvent('QBCore:Notify', PlayerId, 'Not enough items to sell!', 'error')
    end
end)
