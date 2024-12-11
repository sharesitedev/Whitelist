local gui
local client_script
local player

local map = require(script.Parent.Parent.Model_map)

wait(0.5)

script.Parent.ChildAdded:Connect(function(added)
	if added:IsA("Weld") then
		gui = script.Parent.gui:Clone()
		client_script = script.Parent.Core:Clone()
		player = game.Players:GetPlayerFromCharacter(script.Parent.Occupant.Parent)
		map.player = player
		--script.Parent:SetNetworkOwner(player)
		client_script.aircraft.Value = script.Parent
		----
		client_script.Parent = gui
		gui.Parent = player.PlayerGui
		client_script.Disabled = false
	end
end)
script.Parent.ChildRemoved:Connect(function(added)
	if added:IsA("Weld") then
		--script.Parent:SetNetworkOwner(nil)
		gui:Destroy()
		client_script:Destroy()
		----
		map.player = nil
		player = nil
		gui = nil
		client_script = nil
	end
end)

