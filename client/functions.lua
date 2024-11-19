currentAnim = nil
playingEmote = false

AnimationDuration = -1
ChosenAnimation = ""
ChosenDict = ""
MostRecentChosenAnimation = ""
MostRecentChosenDict = ""
MovementType = 0
PlayerGender = "male"
PlayerHasProp = false
PlayerParticles = {}
SecondPropEmote = false
PtfxNotif = false
PtfxPrompt = false
PtfxWait = 500
PtfxCanHold = false
PtfxNoProp = false
AnimationThreadStatus = false

function sendNotification(data)
    local text = data.text or ''
    local title = data.title or 'Notification'
    local type = data.type or 'notification'
    local timeout = data.timeout or 5
    SendNUIMessage({
        action = "notification",
        data = {
            type = type,
            title = title,
            text = text,
            description = description,
            anim = data.anim,
            timeout = timeout,
        }
    })
end


function loadAnimSet(walkstyle)
    if HasAnimSetLoaded(walkstyle) then return true end
    local timer = GetGameTimer() + 5000
    RequestAnimSet(walkstyle)
    while not HasAnimSetLoaded(walkstyle) do
        if timer < GetGameTimer() then
            return false, print('Could not load walk style: ' .. walkstyle)
        end
        RequestAnimSet(walkstyle)
        Wait(0)
    end
    return true
end

function loadAnim(dict)
    if not DoesAnimDictExist(dict) then
        return false, print('Anim not found in streams: ' .. dict)
    end
    if HasAnimDictLoaded(dict) then return true end
    local timer = GetGameTimer() + 5000
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        if timer < GetGameTimer() then
            return false, print('Could not load animation dictionary: ' .. dict)
        end
        RequestAnimDict(dict)
        Wait(0)
    end
    return true
end

function clearProps(ped)
    DetachEntity(ped, true, false)
    TriggerEvent('brinley-animation:propattach:destroyProp', ped)
    TriggerEvent('brinley-animation:propattach:destroyProp2', ped)
    DestroyAllProps()
end

function onEmoteCancel(ped)
    local ped = ped or PlayerPedId()
    if not playingEmote then return print('No emote playing') end
    PtfxNotif = false
    PtfxPrompt = false
    Pointing = false
    if LocalPlayer.state.ptfx then
        PtfxStop()
    end
    if playingEmote.scenario then
        ClearPedTasks(ped)
       
        -- while IsPedUsingScenario(ped, playingEmote.scenario) do
        --     Wait(50)
        -- end
        TaskStartScenarioInPlace(ped, playingEmote.scenario, 0, true)
        Wait(0)
        ClearPedTasksImmediately(ped)
        ClearPedTasks(ped)
        DetachEntity(ped, true, false)
        ClearAreaOfObjects(GetEntityCoords(ped), 2.0, 0)
    end
    ClearPedTasks(ped)
    clearProps(ped)
    TriggerEvent('turnoffsitting')
    TriggerEvent('animation:gotCanceled')
    playingEmote = false
    AnimationThreadStatus = false
    FreezeEntityPosition(ped, false)
end

function onAnimTriggered(anim, ped)
    if not anim then return print('No emote found', json.encode(anim)) end
    if anim.disabled then return print('This emote is disabled for now', anim) end

    local ped = ped or PlayerPedId()
    local category = anim.category
    if anim.category == 'walks' then
        return onWalk(anim)
    end

    if anim.category == 'expressions' then
       return onExpression(anim)
    end

    if not Config.MultipleAnim and playingEmote then return print('multiple emotes is disabled, so you cant do emote without cancel', anim) end
    if anim.scenario then
        local scenario = anim.scenario
        ClearPedTasks(ped)
        TaskStartScenarioInPlace(ped, scenario, 0, true)
        playingEmote = anim
        return true
    end

    if anim.dict and anim.dict ~= '' then
        if not loadAnim(anim.dict) then return false end
        local flag = 1

        local duration = -1 --GetAnimDuration(anim.dict, anim.anim) + 0.01;
        if anim.duration then
            duration = anim.duration
        end

        print('duration', duration, anim.duration)
        print('flag', flag, anim.flag)


        -- DP Emotes
        if anim.animSettings then
            if anim.animSettings.EmoteLoop then
                flag = 1
                if anim.animSettings.EmoteMoving then
                    flag = 51 -- 110011
                end
            elseif anim.animSettings.EmoteMoving then
                flag = 51 -- 110011
            elseif anim.animSettings.EmoteMoving == false then
                flag = 0
            elseif anim.animSettings.EmoteStuck then
                flag = 50 -- 110010
            else
                flag = 0
            end
            
            if anim.animSettings.EmoteDuration ~= nil then
                duration = anim.animSettings.EmoteDuration
                AttachWait = anim.animSettings.EmoteDuration
            else
                AttachWait = 0
            end


            if anim.animSettings.PtfxAsset then
                PtfxAsset = anim.animSettings.PtfxAsset
                PtfxName = anim.animSettings.PtfxName
                if anim.animSettings.PtfxNoProp then
                    PtfxNoProp = anim.animSettings.PtfxNoProp
                else
                    PtfxNoProp = false
                end
                Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, PtfxScale = table.unpack(anim.animSettings.PtfxPlacement)
                PtfxBone = anim.animSettings.PtfxBone
                PtfxColor = anim.animSettings.PtfxColor
                PtfxInfo = anim.animSettings.PtfxInfo
                PtfxWait = anim.animSettings.PtfxWait
                PtfxCanHold = anim.animSettings.PtfxCanHold
                PtfxNotif = false
                PtfxPrompt = true
    
                TriggerServerEvent("brinley-animation:ptfx:sync", PtfxAsset, PtfxName, vector3(Ptfx1, Ptfx2, Ptfx3),
                    vector3(Ptfx4, Ptfx5, Ptfx6), PtfxBone, PtfxScale, PtfxColor)
            else
                print("Ptfx = none")
                PtfxPrompt = false
            end
        else
            flag = 0
        end

        if anim.flag ~= nil then
            flag = anim.flag
        end
        
        TaskPlayAnim(ped, anim.dict, anim.anim, 3.0, 3.0, duration, flag, 0, false, false, false);
        RunAnimationThread()
        if anim.prop then 
            TriggerEvent('brinley-animation:propattach:attachItem', anim.prop);
        end

        -- DP Emotes
        if anim.animSettings and anim.animSettings.Prop then
            PropName = anim.animSettings.Prop
            PropBone = anim.animSettings.PropBone
            PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(anim.animSettings.PropPlacement)
            if anim.animSettings.SecondProp then
                SecondPropName = anim.animSettings.SecondProp
                SecondPropBone = anim.animSettings.SecondPropBone
                SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(anim
                    .animSettings.SecondPropPlacement)
                SecondPropEmote = true
            else
                SecondPropEmote = false
            end
            Wait(AttachWait)
            -- if not AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, 0.0, 300.0, textureVariation) then return end
            if not AddPropToPlayer(ped, PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6, textureVariation) then return end
            if SecondPropEmote then
                if not AddPropToPlayer(ped, SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3,
                    SecondPropPl4, SecondPropPl5, SecondPropPl6, textureVariation) then 
                    DestroyAllProps()
                    return 
                end
            end

            -- Ptfx is on the prop, then we need to sync it
            if anim.animSettings.PtfxAsset and not PtfxNoProp then
                TriggerServerEvent("brinley-animation:ptfx:syncProp", ObjToNet(prop))
            end
        end

        if anim.prop2 then 
            TriggerEvent('brinley-animation:propattach:attachItem2', anim.prop2);
        end
        playingEmote = anim
        return true
    end

    if anim.event then
        return true, TriggerEvent(anim.event)
    end
end








----- walk
function onWalkCancel()
    local ped = PlayerPedId()
    ResetPedMovementClipset(ped, 0)
    TriggerEvent('brinley-animation:client:onWalkSet', 'default')
    if Config.PersistentWalkStyle then
        DeleteResourceKvp("brinley-animation:walkstyle")
    end
end

function onWalk(anim)
    local ped = PlayerPedId()
    local walkstyle = anim.value
    if walkstyle == 'default' then
        return onWalkCancel()
    end
    if not loadAnimSet(walkstyle) then return end
    SetPedMovementClipset(ped, walkstyle, 0.5)
    if Config.PersistentWalkStyle then
        SetResourceKvp('brinley-animation:walkstyle', walkstyle)
    end
    SetResourceKvp('brinley-animation:walkstyle', walkstyle)
    TriggerEvent('brinley-animation:client:onWalkSet', value)
    return true
end


--- expressions
function onExpression(anim)
    local ped = PlayerPedId()
    local expression = anim.value
    if expression == 'default' then
        return onExpressionCancel()
    end
    SetFacialIdleAnimOverride(ped, expression, 0)
    if Config.PersistentExpressions then
        SetResourceKvp('brinley-animation:expression', expression)
    end
    TriggerEvent('brinley-animation:client:onExpressionSet', expression)
    return true
end

function onExpressionCancel()
    local ped = PlayerPedId()
    ClearFacialIdleAnimOverride(ped)
    TriggerEvent('brinley-animation:client:onExpressionSet', 'default')
    if Config.PersistentExpressions then
        DeleteResourceKvp("brinley-animation:expression")
    end
end

local list = {
    'QBCore:Client:OnPlayerLoaded',
    'esx:playerLoaded',
    'hospital:client:Revive',
    'playerSpawned'
}

for _, event in pairs(list) do
    RegisterNetEvent(event, function()
        if event:lower():match('playerloaded') then
            Citizen.Wait(5000)
        else
            Wait(1000)
        end
        if Config.PersistentWalkStyle then
            local walkstyle = GetResourceKvpString('brinley-animation:walkstyle')
            print('walkstyle', walkstyle)
            if walkstyle and walkstyle ~= 'default' then
                onWalk({value = walkstyle})
            end
        end

        if Config.PersistentExpressions then
            local expression = GetResourceKvpString("brinley-animation:expression")
            print('expression', expression)
            if expression and expression ~= 'default' then
                onExpression({value = expression})
            end
        end
    end)
end
