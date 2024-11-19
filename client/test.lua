-- local testedAnims = {}
-- local firstHeading = nil
-- function testAnim()
--     if not firstHeading then
--         firstHeading = GetEntityHeading(PlayerPedId())
--     end
--     onEmoteCancel()
--     Wait(1500)
--     for k, v in pairs(Config.AllAnimations) do
--         if not testedAnims[v.id] then
--             SetEntityHeading(PlayerPedId(), firstHeading + 0.0)
--             print('testing', json.encode(v, {indent = true}))
--             onAnimTriggered(v)
--             SetEntityHeading(PlayerPedId(), firstHeading + 0.0)
--             testedAnims[v.id] = true
--             break
--         end
--     end
-- end

-- RegisterCommand('macro', function()
--     testAnim()
-- end)

-- CreateThread(function()
--     local animCancelKey = 182--'L'
--     local animKey = 303--'U'
--     while true do 
--         Wait(0)
--         if IsControlJustPressed(0, animCancelKey) then
--             SetEntityHeading(PlayerPedId(), firstHeading + 0.0)
--             onEmoteCancel()
--         end
        
--         if IsControlJustPressed(0, animKey) then
--             testAnim()
--         end
--     end
-- end)


-- local model = `greenscreen_prop`
-- local props = {}
-- local tpCoords = vec3(-1921.7728271484, 3021.1940917969, 58.552459716797)
-- local tpHeading = 265.5

-- RegisterCommand('green', function()
--     local ped = PlayerPedId()
--     local pos = GetEntityCoords(ped)
--     local heading = GetEntityHeading(ped)

--     RequestModel(model)
--     while not HasModelLoaded(model) do
--         print('loading model', model)
--         Wait(0)
--     end

--     local object = CreateObject(model, pos.x, pos.y, pos.z, true, false, false)
--     SetEntityHeading(object, heading)
--     SetEntityAsMissionEntity(object, true, true)
--     FreezeEntityPosition(object, true)

--     table.insert(props, object)

--     -- create a new prop and change the orientation of the prop and put it as a floor

--     local object2 = CreateObject(model, pos.x, pos.y, pos.z - 2.5, true, false, false)
--     SetEntityHeading(object2, heading)
--     SetEntityAsMissionEntity(object2, true, true)
--     FreezeEntityPosition(object2, true)
--     SetEntityRotation(object2, 90.0, 0.0, 0.0, 0, false)
--     table.insert(props, object2)

--     print('object', object)

--     Wait(500)
--     SetEntityCoords(ped, tpCoords)
--     SetEntityHeading(ped, tpHeading)
-- end)

-- AddEventHandler('onResourceStop', function(resource)
--     if resource == GetCurrentResourceName() then
--         for k, v in pairs(props) do
--             DeleteObject(v)
--         end
--     end
-- end)
