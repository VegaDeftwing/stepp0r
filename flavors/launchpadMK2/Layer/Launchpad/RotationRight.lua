function Launchpad:_right_callback(msg)
    local result = _is_matrix_right(msg)
    if (result.flag) then
        for _, callback in pairs(self._matrix_listener) do
            callback(self, result)
        end
        return
    end
    --
    result = _is_top_right(msg)
    if (result.flag) then
        for _, callback in pairs(self._top_listener) do
            callback(self, result)
        end
        return
    end
    --
    result = _is_side_right(msg)
    if (result.flag) then
        for _, callback in pairs(self._side_listener) do
            callback(self, result)
        end
        return
    end
end
-- NOTE: OKAY TO HERE
-- TODO: make all the circle buttons go back to LpMKI bindings
--- Test functions for the handler
--

function _is_top_right(msg)
    if msg[1] == 0xB0 then
      -- corrected for MkII
        local x = msg[2] - 0x68 -- NOTE 0x68 in ref = 104
		local v = Launchpad:getvel(msg[3]) --should be fine to keep, vel for pro?
        if (x > -1 and x < 8) then
            return { flag = true,  x = (x + 1), vel = v }
        end
    end
    return LaunchpadData.no
end

function _is_side_right(msg)
      local v = Launchpad:getvel(msg[3])
      if msg[2] == 19 then
        return { flag = true,  x = 8, vel = v }
      end
      if msg[2] == 29 then
        return { flag = true,  x = 7, vel = v }
      end
      if msg[2] == 39 then
        return { flag = true,  x = 6, vel = v }
      end
      if msg[2] == 49 then
        return { flag = true,  x = 5, vel = v }
      end
      if msg[2] == 59 then
        return { flag = true,  x = 4, vel = v }
      end
      if msg[2] == 69 then
        return { flag = true,  x = 3, vel = v }
      end
      if msg[2] == 79 then
        return { flag = true,  x = 2, vel = v }
      end
      if msg[2] == 89 then
        return { flag = true,  x = 1, vel = v }
      end
    -- if msg[1] == 0xb0 then -- NOTE 0x90 in ref = 144
      -- TODO try just a fuck load of ifs
        -- local x = 8 - math.floor(msg[2] / 10) -- WTF is this line??
		    -- local v = Launchpad:getvel(msg[3])
        -- NOTE these next few lines look to be the same
        -- but allow for vel from pro, again, should be able
        -- to keep this
        -- if (x > -1 and x < 8) then
        --     return { flag = true,  x = (x + 1), vel = v }
        -- end
    -- end
    return LaunchpadData.no
end

function _is_matrix_right(msg)
    if msg[1] == 0x90 then -- 0x90 is SAME as in ref
        local note = msg[2]
        -- TODO, should the next two lines be removed?
        local y = math.floor(note / 10) -1 --WTF is this line?
        local x = note - 10 * (1+y) - 1; --Dito.
		local v = Launchpad:getvel(msg[3])
		y = 7 - y
        -- logic is same, adapeted for pro's vel
        if ( x > -1 and x < 8 and y > -1  and y < 8 ) then
            return { flag = true , x = (x + 1) , y = (y + 1), vel = v }
        end
    end
    return LaunchpadData.no
end



---
-- Set parameters
-- NOTE: Should be done
function Launchpad:_set_matrix_right( a, b , color )
    local x = a - 1
    local y = b - 1
    if ( x < 8 and x > -1 and y < 8 and y > -1) then
      -- OKAY
        self:send(0x90 , 81 + x - 10 *y , color) --self:send(0x90 , y * 16 + x , color) 0x90=144
    end
end

function Launchpad:_set_top_right(a,color)
    local x = a - 1
    if ( x > -1 and x < 8 ) then
      -- this should start at 104 and go up for mk2
        self:send( 0xB0, x + 0x68, color) --self:send( 0xB0, x + 0x68, color) 0x68=104
    end
end

function Launchpad:_set_side_right(a,color)
    local x = a - 1
    if ( x > -1 and x < 8 ) then
      -- 89 - 10*x would give 89,79...,19 which is correct
        self:send( 0xb0, 89 - (10 * x), color) --self:send( 0x90, 0x10 * x + 0x08, color) 0x90=144
    end
end
