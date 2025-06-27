local npc_names = T{
    enter = T{'Shattered Telepoint', 'Cermet Gate'},
}

return T{
    short_name = 'mythic',
    long_name = 'mythic',
    npc_plural = 'points',
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

        -- check menu id here.
		if not (
            --shattered telepoints
            menu_id == 913 or
            menu_id == 202 or
            --hall of transference
            menu_id == 150 or
            menu_id == 151
        ) then
            return "Incorrect menu detected! Menu ID: "..menu_id
        end
        return nil
    end,
    missing = function(warpdata, zone, p)
        local missing = T{}
        return missing
    end,
    help_text = "[sw] mythic [all/a/@all] ichor/drop --Various mythic helper functions.",
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
        ichor = function(current_activity, zone, p, settings)
            local actions = T{}
            local packet = nil
            local menu = p["Menu ID"]
            local npc = current_activity.npc
            
            -- update request
            packet = packets.new('outgoing', 0x016)
            packet["Target Index"] = windower.ffxi.get_player().index
            actions:append(T{packet=packet, description='update request'})

            return actions
        end,
    },
    self_commands = {
        drop = function(current_activity, zone, settings )
            local items = windower.ffxi.get_items()
            local droppables = S{
                5414, --einherjar lamp
                5365,5366,5367,5368,5369,5370,5371,5372,5373,5374,5375,5376,5377,5378,5379,5380,5381,5382,5383,5384 --cells
            }

            for index, item in pairs(items.inventory) do
                if type(item) == 'table' and droppables:contains(item.id) and item.status == 0 then
                    windower.ffxi.drop_item(index, item.count)
                end
            end
        end,
    },
    warpdata = T{

	},
}