local npc_names = T{
    mine = T{'Mineral Vein #4', 'Mineral Vein #3','Mineral Vein #2','Mineral Vein',},
}

local function table_contains(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

return T{
    short_name = 'mg',
    long_name = 'garden',
    npc_plural = 'spots',
    zone_npc_list = function(type)
        local mlist = windower.ffxi.get_mob_list()
        mlist = table.filter(mlist, function(name)
            return name ~= "" and npc_names[type]:any(string.startswith+{name})
        end)
        mlist = table.map(mlist, function(name)
            local num = name:match('%d+$')
            return {name=name, key=(num and tostring(num))}
        end)
        return mlist
    end,
    validate = function(menu_id, zone, current_activity)
        if current_activity.self_cmd then
            return nil
        end

        if 'mine' == current_activity.sub_cmd and not table_contains(T{1042, 1043, 1044, 1045, 1046, 1047, 1048, 1063, 1064}, menu_id) then
            return "Incorrect menu detected! Menu ID: "..menu_id
        end

        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        return missing
    end,
    help_text = "[sw] mg [all/a/@all] mine --Mine at the mineral vein.",
    sub_zone_targets =  S{},
    auto_select_zone = function(zone)
    end,
    auto_select_sub_zone = function(zone)
    end,
    build_warp_packets = function(current_activity, zone, p, settings)
        -- no warps, only go.
        packet = packets.new('outgoing', 0x05B)
        packet["Target"] = npc.id
        packet["Option Index"] = 0
        packet["_unknown1"] = 16384
        packet["Target Index"] = npc.index
        packet["Automated Message"] = false
        packet["_unknown2"] = 0
        packet["Zone"] = zone
        packet["Menu ID"] = menu
        actions:append(T{packet=packet, description='cancel menu', message='ERROR! Something went wrong!'})
        return actions
    end,
    sub_commands = {
        mine = function(current_activity, zone, p, settings)
            local actions = T{}
            local packet = nil
            local menu = p["Menu ID"]
            local npc = current_activity.npc
            
            -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, description='update request'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 1
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = true
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, description='send options'})

            packet = packets.new('outgoing', 0x05B)
            packet["Target"] = npc.id
            packet["Option Index"] = 1
            packet["_unknown1"] = 0
            packet["Target Index"] = npc.index
            packet["Automated Message"] = false
            packet["_unknown2"] = 0
            packet["Zone"] = zone
            packet["Menu ID"] = menu
            actions:append(T{packet=packet, expecting_zone=true, delay=wiggle_value(settings.simulated_response_time, settings.simulated_response_variation), description='complete menu', message='Mining stuff'})

            actions:append(T{fn = function(last_packet) 
                windower.send_command('setkey escape down; wait 0.2;setkey escape up; wait 0.2;')
                general_release()
                return true
            end})

            return actions
        end,
    },
    self_commands = {
    },
    warpdata = T{

	},
}