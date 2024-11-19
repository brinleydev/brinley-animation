RegisterNetEvent("brinley-animation:server:syncAnimpos", function(coords, heading)
    local source = source
    TriggerClientEvent("brinley-animation:client:syncAnimpos", -1, source, coords, heading)
end)
