-- Title        : piezo32
-- Description  : Library for interfacing ESP32 with Piezo Speaker
-- Author       : Alija Bobija (https://abobija.com)
-- GitHub       : https://github.com/abobija/piezo32
-- Dependencies : > ledc
--                > tmr

local M = {}

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
        options = nil
    end
end

M.play = function(opts)
    if options ~= nil then
        return -- Busy...
    end
    
    options = extend({
        freq = 3000,
        duty = 4000,
        play_duration = 1000,
        pause_duration = 0,
        times = 1,
        on_step = nil
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
        freq = 600,
        play_duration = 750
    }, opts))
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
        duty      = 4000
    })

    channel:stop(ledc.IDLE_LOW)
    
    timer = tmr:create()
    timer:register(100, tmr.ALARM_SEMI, do_step)

    return M
end
