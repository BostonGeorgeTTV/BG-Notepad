local Framework = nil
local Core = nil

local function debugPrint(...)
    if Config.Debug then
        print('^3[bg_notepad]^7', ...)
    end
end

local function isStarted(resource)
    local state = GetResourceState(resource)
    return state == 'started' or state == 'starting'
end

local function normalize(value)
    return string.lower(tostring(value or 'auto'))
end

local function resolveFramework()
    if Framework then return Framework, Core end

    local configured = normalize(Config.Framework)

    if configured == 'qbox' or configured == 'qbx' or (configured == 'auto' and isStarted('qbx_core')) then
        if isStarted('qbx_core') then
            Framework = 'qbox'
            Core = exports.qbx_core
            debugPrint('Framework rilevato: qbox')
            return Framework, Core
        end
    end

    if configured == 'qbcore' or configured == 'qb-core' or configured == 'qb' or (configured == 'auto' and isStarted('qb-core')) then
        if isStarted('qb-core') then
            Framework = 'qbcore'
            Core = exports['qb-core']:GetCoreObject()
            debugPrint('Framework rilevato: QBCore')
            return Framework, Core
        end
    end

    if configured == 'esx' or (configured == 'auto' and isStarted('es_extended')) then
        if isStarted('es_extended') then
            Framework = 'esx'
            Core = exports['es_extended']:getSharedObject()
            debugPrint('Framework rilevato: ESX')
            return Framework, Core
        end
    end

    Framework = 'standalone'
    Core = nil
    debugPrint('Framework rilevato: standalone')
    return Framework, Core
end

local function getPlayer(source)
    local framework, core = resolveFramework()

    if framework == 'qbox' and isStarted('qbx_core') then
        local ok, player = pcall(function()
            return exports.qbx_core:GetPlayer(source)
        end)

        if ok then return player end
    end

    if framework == 'qbcore' and core and core.Functions and core.Functions.GetPlayer then
        return core.Functions.GetPlayer(source)
    end

    if framework == 'esx' and core and core.GetPlayerFromId then
        return core.GetPlayerFromId(source)
    end

    return nil
end

local function getPlayerFullName(source)
    local framework = resolveFramework()
    local player = getPlayer(source)

    if framework == 'esx' then
        if player and player.getName then
            local name = player.getName()
            if name and name ~= '' then return name end
        end
    elseif framework == 'qbcore' or framework == 'qbox' then
        local charinfo = player and player.PlayerData and player.PlayerData.charinfo
        if charinfo then
            local firstname = charinfo.firstname or charinfo.firstName or ''
            local lastname = charinfo.lastname or charinfo.lastName or ''
            local fullName = (firstname .. ' ' .. lastname):gsub('^%s*(.-)%s*$', '%1')

            if fullName ~= '' then return fullName end
        end

        local charName = player and player.PlayerData and player.PlayerData.name
        if charName and charName ~= '' then return charName end
    end

    return GetPlayerName(source) or 'Anonimo'
end

local function getMetadataFromUsedItem(item)
    if type(item) ~= 'table' then return {} end

    local metadata = item.metadata or item.info or item.data or {}

    if type(metadata) ~= 'table' then
        return {}
    end

    return metadata
end

local function resolveInventory()
    local configured = normalize(Config.Inventory)

    if configured == 'ox' then configured = 'ox_inventory' end
    if configured == 'qb' then configured = 'qb_inventory' end

    if configured ~= 'auto' then
        return configured
    end

    if isStarted('ox_inventory') then return 'ox_inventory' end
    if isStarted('qb-inventory') or isStarted('lj-inventory') or isStarted('ps-inventory') then return 'qb_inventory' end

    return 'framework'
end

local function addItemWithFramework(source, metadata)
    local framework = resolveFramework()
    local player = getPlayer(source)

    if framework == 'qbcore' or framework == 'qbox' then
        if player and player.Functions and player.Functions.AddItem then
            return player.Functions.AddItem(Config.Item, 1, false, metadata)
        end
    elseif framework == 'esx' then
        if player and player.addInventoryItem then
            -- ESX default inventory usually does not support per-item metadata.
            return player.addInventoryItem(Config.Item, 1)
        end
    end

    return false
end

local function addNotepad(source, metadata)
    metadata = type(metadata) == 'table' and metadata or {}

    local inventory = resolveInventory()

    if inventory == 'ox_inventory' and isStarted('ox_inventory') then
        local success, response = exports.ox_inventory:AddItem(source, Config.Item, 1, metadata)
        if not success then debugPrint('ox_inventory AddItem fallito:', response) end
        return success
    end

    if inventory == 'qb_inventory' then
        if addItemWithFramework(source, metadata) then
            return true
        end

        if isStarted('qb-inventory') then
            local ok, success = pcall(function()
                return exports['qb-inventory']:AddItem(source, Config.Item, 1, false, metadata, 'bg_notepad:createItems')
            end)

            return ok and (success == true or type(success) == 'table')
        end
    end

    return addItemWithFramework(source, metadata)
end

local function registerUsableItem()
    if not Config.RegisterUsableItem then return end

    local framework, core = resolveFramework()

    if framework == 'qbox' and isStarted('qbx_core') then
        local ok = pcall(function()
            exports.qbx_core:CreateUseableItem(Config.Item, function(source, item)
                TriggerClientEvent('bg_notepad:openNotepad', source, getMetadataFromUsedItem(item))
            end)
        end)

        if ok then
            debugPrint(('Item usabile registrato per qbox: %s'):format(Config.Item))
            return
        end
    end

    if framework == 'qbcore' and core and core.Functions and core.Functions.CreateUseableItem then
        core.Functions.CreateUseableItem(Config.Item, function(source, item)
            TriggerClientEvent('bg_notepad:openNotepad', source, getMetadataFromUsedItem(item))
        end)
        debugPrint(('Item usabile registrato per QBCore: %s'):format(Config.Item))
        return
    end

    if framework == 'esx' and core and core.RegisterUsableItem then
        core.RegisterUsableItem(Config.Item, function(source)
            TriggerClientEvent('bg_notepad:openNotepad', source, {})
        end)
        debugPrint(('Item usabile registrato per ESX: %s'):format(Config.Item))
    end
end

RegisterNetEvent('bg_notepad:requestName', function(requestId)
    local source = source
    TriggerClientEvent('bg_notepad:receiveName', source, requestId, getPlayerFullName(source))
end)

RegisterNetEvent('bg_notepad:createItems', function(data)
    local source = source
    local metadata = type(data) == 'table' and data or {}

    metadata.mode = metadata.mode or 'view'
    metadata.title = metadata.title or 'MemoryRp'
    metadata.object = metadata.object or ''
    metadata.save = metadata.save or 'Anonimo'

    addNotepad(source, metadata)
end)

CreateThread(function()
    Wait(500)
    resolveFramework()
    registerUsableItem()
end)
