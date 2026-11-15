-- Questie area IDs are not UI map IDs. Resolve through the client's localized names.
local _, A = ...
local mapsByName
local locationIndices = {}
local function resolveMap(area)
    if not (C_Map and C_Map.GetAreaInfo and C_Map.GetMapInfo) then
        return nil
    end
    local name = C_Map.GetAreaInfo(area)
    if not name then
        return nil
    end
    if not mapsByName then
        mapsByName = {}
        local scores = {}
        for id = 1, 3000 do
            local info = C_Map.GetMapInfo(id)
            if info and info.name then
                local score = info.mapType == 3 and 100 or 10
                if C_Map.CanSetUserWaypointOnMap and C_Map.CanSetUserWaypointOnMap(id) then
                    score = score + 50
                end
                if not scores[info.name] or score > scores[info.name] then
                    mapsByName[info.name], scores[info.name] = id, score
                end
            end
        end
    end
    return mapsByName[name]
end

function A.SourceLocations(npcID, objectID)
    if not npcID and not objectID then
        return {}
    end
    local spawns = objectID and A.Relation('Object', objectID, 'spawns')
        or A.ReferenceMetadata.Npc.Get(npcID, 'spawns')
    if spawns == false or (type(spawns) == 'table' and next(spawns) == nil) then
        return {}
    end
    local hasCoordinates = false
    for _, points in pairs(type(spawns) == 'table' and spawns or {}) do
        if type(points) == 'table' then
            hasCoordinates = true
            break
        end
    end
    if not hasCoordinates then
        spawns = npcID and A.NpcLocations[npcID]
    end
    local result = {}
    for area, points in pairs(type(spawns) == 'table' and spawns or {}) do
        if type(points) == 'table' then
            for _, point in ipairs(points) do
                if
                    type(point) == 'table'
                    and type(point[1]) == 'number'
                    and type(point[2]) == 'number'
                    and point[1] >= 0
                    and point[1] <= 100
                    and point[2] >= 0
                    and point[2] <= 100
                then
                    result[#result + 1] = { area = area, x = point[1], y = point[2] }
                end
            end
        end
    end
    table.sort(result, function(a, b)
        if a.area ~= b.area then
            return a.area < b.area
        end
        if a.x ~= b.x then
            return a.x < b.x
        end
        return a.y < b.y
    end)
    return result
end

function A.ShowSourceLocation(entry)
    local points = A.SourceLocations(entry.npcID, entry.objectID)
    if #points == 0 then
        return false, 'No recorded coordinates for this source.'
    end
    local key = entry.npcID or ('object:' .. tostring(entry.objectID))
    local index = (locationIndices[key] or 0) % #points + 1
    locationIndices[key] = index
    local spot = points[index]
    local map = resolveMap(spot.area)
    if not map then
        return false, 'This location has no matching client map.'
    end
    if InCombatLockdown and InCombatLockdown() then
        return false, 'Open the map after combat.'
    end
    local canPin = C_Map.SetUserWaypoint
        and UiMapPoint
        and UiMapPoint.CreateFromCoordinates
        and (not C_Map.CanSetUserWaypointOnMap or C_Map.CanSetUserWaypointOnMap(map))
    local pinned = false
    if canPin then
        local ok, result =
            pcall(C_Map.SetUserWaypoint, UiMapPoint.CreateFromCoordinates(map, spot.x / 100, spot.y / 100))
        pinned = ok and result ~= false
        if pinned and C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
        end
    end
    local open = C_Map.OpenWorldMap or OpenWorldMap
    local opened = open and pcall(open, map)
    local position = string.format('%.1f, %.1f (%d/%d)', spot.x, spot.y, index, #points)
    if not opened then
        return false, 'Could not open the map. Coordinates: ' .. position
    end
    return true, (pinned and 'Map pin: ' or 'Map opened; pin unsupported: ') .. position
end
