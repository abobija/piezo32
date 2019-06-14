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

local function do_step(_timer)
    local interval = 0
    
    if play_step == true then
        channel:setfreq(options.freq)
        channel:setduty(options.duty)
        channel:resume()
        interval = options.play_duration
        timer:interval(interval)
        play_step = false
    else
        interval = options.pause_duration
        
        if interval > 0 or step >= options.times then
            channel:stop(ledc.IDLE_LOW)
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
    end
end

--[[
    @options - {
        freq,
        duty,
        play_duration,
        pause_duration,
        times
    }
]]
M.play = function(opts)
    if step > 1 then
        return -- Busy...
    end
    
    options = opts
    do_step()
end

M.success = function()
    M.play({
        freq = 2700,
        duty = 4000,
        play_duration = 100,
        pause_duration = 25,
        times = 2
    })
end

M.error = function()
    M.play({
        freq = 700,
        duty = 4000,
        play_duration = 750,
        pause_duration = 0,
        times = 1
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
        duty      = 500
    })

    channel:stop(ledc.IDLE_LOW)
    
    timer = tmr:create()
    timer:register(100, tmr.ALARM_SEMI, do_step)

    return M
end
