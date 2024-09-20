--[[

Hello!!
An amazing scripter (Kiwi) had suggested to use a community created utility called Signals.
The amazing resource is able to allow communication between clients effortlessly and efficiently, as if you were using remote events to bridge the gap.
https://github.com/InfernusScripts/Fire-Hub/blob/main/Documentations/Signals.md

If this script doesn't make sense to you in the slightest, I reccoment checking out the documentation for Signals, and trying to recreate this
using an entirely different method! Since this module is based off of synchronization in a seed, this really wouldn't have much utility.

Cheers! -- Chrono @Comet Development

--]]

local Module = {}

local RunService = game:GetService("RunService")
local GAME_JOB_ID = game.JobId
local SEED = 0

for iteration = 1, #GAME_JOB_ID do
    SEED += string.byte(GAME_JOB_ID, iteration)
end

-- Declare: 

function Module:returnSeed(): number
    return SEED
end

function Module:deltaWait(duration: number): ()
    local elapsedTime = 0
    
    local connection = RunService.Heartbeat:Connect(function(delta): ()
        elapsedTime = elapsedTime + delta
    end)
    
    while elapsedTime < duration do
        RunService.Heartbeat:Wait()
    end
    
    connection:Disconnect()
end

function Module:generateRandom(Min: number, Max: number): number
    return Random.new(SEED):NextNumber(Min, Max)
end

-- Return:

return Module
