local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    local hash = Config.PedProps['hash']
    local coords = Config.PedProps['location']
    QBCore.Functions.LoadModel(hash)
    local buyerPed = CreatePed(0, hash, coords.x, coords.y, coords.z-1.0, coords.w, false, false)
	TaskStartScenarioInPlace(buyerPed, 'WORLD_HUMAN_CLIPBOARD', true)
	FreezeEntityPosition(buyerPed, true)
	SetEntityInvincible(buyerPed, true)
	SetBlockingOfNonTemporaryEvents(buyerPed, true)
    exports['qb-target']:AddTargetEntity(buyerPed, {
        options = {
            {
                icon = 'fas fa-circle',
                label = 'Check Items',
                action = function()
                    local pedPos = GetEntityCoords(PlayerPedId())
                    local dist = #(pedPos - vector3(coords))
                    if dist <= 5.0 then
                        ShowMenu()
                    end
                end,
            },
        },
        distance = 2.0
    })
end)
function ShowMenu()
    local registeredMenu = {
        id = 'item-menu',
        title = 'Sellable Items',
        options = {}
    }
    local options = {}
    for itemName, itemData in pairs(Config.Items) do
        if QBCore.Functions.HasItem(itemName) then
            local description = 'Cost: $' .. itemData.price .. ' per'
            if itemName == 'markedbills' and itemData.worth then
                description = description .. ' | Worth: $' .. itemData.worth .. ' per bill'
            end

            options[#options+1] = {
                title = QBCore.Shared.Items[itemName]["label"],
                description = description,
                event = 'hadiresource:giveinput',
                args = {
                    item = itemName,
                    price = itemData.price,
                    worth = itemData.worth
                }
            }
        end
    end
    registeredMenu["options"] = options
    lib.registerContext(registeredMenu)
    lib.showContext('item-menu')
end
RegisterNetEvent('hadiresource:giveinput', function(data)
    local header = 'Item: ' .. data.item
    local input = lib.inputDialog(header, {
        { type = 'input', label = 'Sell Amount', placeholder = '10' },
        { type = 'select', label = 'Payment Method', options = {
           ---{ value = 'cash', label = 'Cash', icon = 'fas fa-wallet' },---- di matikan 
            { value = 'markedbills', label = 'Marked Bills', icon = 'fas fa-money-bill' }
        }},
    })

    if not input then return end 

    local amount = tonumber(input[1])
    local payMethod = input[2]

    if amount then
        if payMethod then
            TriggerServerEvent('hadiresource:sellitem', data.item, data.price, amount, payMethod, data.worth)
        else
            QBCore.Functions.Notify('No selected payment method.', 'error', 4500)
        end
    else
        QBCore.Functions.Notify('No amount was given.', 'error', 4500)
    end
end)
