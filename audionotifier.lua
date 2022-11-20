-- alex

--[[
* This module has ONE function. You can change the way the game notifies the player by changing the `informplyr` function

* This is designed SPECIFICALLY for informing players that played an audio into their boombox that their audio didnt work

———————————————————————————————————————————————————————————————————
// Log Player
<void> AudioNotifier.Log(<Instance> plyr, <number/string> audioID) 

Adds player to the cache in case the audio fails to load.
If it fails to load, it will notify them.
Don't worry, theres garbage collection for the cache :)
———————————————————————————————————————————————————————————————————

Let me know if there's a problem with my code via a PM on the dev forum.
]]

AudioNotifier = {}

-- lets the player know that their audio does not work
function informplyr(plyr)
	game.ReplicatedStorage.RemoteEvent:FireClient(plyr, 'msgbox', 'Roblox\'s recent audio update probably broke your id. Try another.')
end

local audioCache = {}

function findUserInCache(audio)
	for i,v in pairs(audioCache) do
		if v[3] == audio then
			table.remove(audioCache, i) -- removes it from the cache since it was found!
			return v[2]
		end
	end
end

game:GetService('LogService').MessageOut:Connect(function(msg)
	if msg and msg:sub(1, 20) == 'Failed to load sound' then
		local id = msg:match('%d+')
		if id then
			id = tostring(id)
			local user = findUserInCache(id)
			if user then
				local plyr = game.Players:GetPlayerByUserId(user)
				if plyr  then
					-- for some reason it doesnt work if i dont spawn it
					-- i have no idea why but its ok
					spawn(function()
						informplyr(plyr)
					end)
				end
			end
		end
	end
end)


spawn(function()
	-- collect garbage
	local function updateCache()
		for i,v in pairs(audioCache) do
			if os.clock() > v[1] then
				table.remove(audioCache, i)
			end
		end
	end
	while wait() do
		updateCache()
	end
end)

local function makeEntry(plyr, audioID)
	table.insert(audioCache, {os.clock() + 75, plyr.UserId, audioID})
end
AudioNotifier.Log = makeEntry

return AudioNotifier
