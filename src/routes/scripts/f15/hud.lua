wait(5)
for _,v in pairs(game.Players:GetChildren()) do
	script.client_functions:Clone().Parent = v.PlayerGui
end

script.client_functions:Clone().Parent=game.StarterGui
script:Destroy()