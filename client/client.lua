local pendingNameCallbacks = {}

local function openNui(data)
    SendNUIMessage({
        action = data.mode,
        metadata = data
    })
    SetNuiFocus(true, true)
end

local function openNotepad(data)
    local note = {}

    if not data or next(data) == nil then
        note.mode = 'create'
        note.title = Config.defaultTitle
    else
        note.mode = data.mode or 'view'
        note.title = data.save or data.title or 'Anonimo'
        note.save = data.save or 'Anonimo'
        note.object = data.object or ''
    end

    openNui(note)
end

local function requestPlayerName(cb)
    local requestId = ('%s-%s'):format(GetGameTimer(), math.random(100000, 999999))

    pendingNameCallbacks[requestId] = cb
    TriggerServerEvent('bg_notepad:requestName', requestId)

    SetTimeout(5000, function()
        if pendingNameCallbacks[requestId] then
            pendingNameCallbacks[requestId] = nil
            cb('Anonimo')
        end
    end)
end

RegisterNetEvent('bg_notepad:receiveName', function(requestId, name)
    local cb = pendingNameCallbacks[requestId]
    if not cb then return end

    pendingNameCallbacks[requestId] = nil
    cb(name or 'Anonimo')
end)

RegisterNetEvent('bg_notepad:openNotepad', function(data)
    openNotepad(data or {})
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)

    if cb then
        cb({ ok = true })
    end
end)

RegisterNUICallback('giveItemNote', function(data, cb)
    local function createNotepad(printName)
        local metadata = {
            mode = 'view',
            title = data.title,
            object = data.object,
            save = printName or 'Anonimo'
        }

        TriggerServerEvent('bg_notepad:createItems', metadata)
        SetNuiFocus(false, false)

        if cb then
            cb({ ok = true })
        end
    end

    if data.anonymous then
        createNotepad('Anonimo')
        return
    end

    requestPlayerName(function(name)
        createNotepad(name or 'Anonimo')
    end)
end)

exports('openNotepad', openNotepad)
