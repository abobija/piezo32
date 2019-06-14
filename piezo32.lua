-- Title        : piezo32
-- Description  : Library for interfacing ESP32 with Piezo Speaker
-- Author       : Alija Bobija (https://abobija.com)
-- GitHub       : https://github.com/abobija/piezo32
-- Dependencies : > ledc
--                > tmr

local M = {}

M.notes = {
    C = 2441,
    D = 2741,
    E = 3048,
    F = 3255,
    G = 3654,
    A = 4058,
    B = 4562
}

local channel = nil
local timer = nil 

local step = 1
local play_step = true
local options = nil

local function extend(tbl, with)
    if with ~= nil then
        for k, v in pairs(with) do
            tbl[k] = with[k]
        end
    end

    return tbl
end

local function do_step(_timer)
    local interval = 0
    
    if play_step == true then
        channel:setfreq(options.freq)
        channel:setduty(options.duty)
        channel:resume()
        interval = options.play_duration
        timer:interval(interval)
        
        if options.on_step ~= nil then
            options.on_step({
                playing = true,
                freq = options.freq
            })
        end
        
        play_step = false
    else
        interval = options.pause_duration
        
        if interval > 0 or step >= options.times then
            channel:stop(ledc.IDLE_LOW)

            if options.on_step ~= nil then
                options.on_step({
                    playing = false
                })
            end
        end
            
        if interval > 0 then
            timer:interval(interval)
        end
        
        play_step = true
        
        step = step + 1
    end

    if step <= options.times then
        if interval > 0 then
            timer:start()
        else
            do_step()
        end
    else
        step = 1
        play_step = true

        if options.on_done ~= nil then
            options.on_done()
        end
    end
end

M.play = function(opts)
    options = extend({
        freq = 3000,
        duty = 3750,
        play_duration = 1000,
        pause_duration = 0,
        times = 1,
        on_step = nil,
        on_done = nil
    }, opts)
    
    do_step()
end

M.success = function(opts)
    M.play(extend({
        freq = 2700,
        play_duration = 100,
        pause_duration = 25,
        times = 2
    }, opts))
end

M.error = function(opts)
    M.play(extend({
        freq = 200,
        play_duration = 1000
    }, opts))
end

M.play_music = function(mstr)
    if #mstr < 2 then
        return
    end
    
    M.play({
        freq = M.notes[mstr:sub(1, 1)],
        play_duration = 325 * tonumber(mstr:sub(2, 2)),
        pause_duration = 50,
        on_done = function()
            M.play_music(mstr:sub(3))
        end
    })
end

--[[
    @config - {
        gpio
    }
]]
return function(config)
    channel = ledc.newChannel({
        gpio      = config.gpio,
        bits      = ledc.TIMER_13_BIT,
        mode      = ledc.HIGH_SPEED,
        timer     = ledc.TIMER_0,
        channel   = ledc.CHANNEL_0,
        frequency = 500,
        duty      = 3750
    })

    channel:stop(ledc.IDLE_LOW)
    
    timer = tmr:create()
    timer:register(100, tmr.ALARM_SEMI, do_step)

    return M
end
