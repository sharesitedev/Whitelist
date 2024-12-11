-- Simple Weld Script by Rengate, Gate Studios©
wait()
local IgnoreList = { --PUT THE NAME OF ITEMS YOU WANT IGNORED IN THE WELD AND THEN WHAT TYPE
	--	1 = If item is a parent model and you want everything in that ignored
	--  2 = If you want that specfic part ignored
	--  Example: {"Name", 1};
	{"Animations",1};
	{"LG2",1};
	{"RG2",1};
	{"Plane",1};
	{"Animations",1};
	{"StickX",1};
	{"LeftGearRotate",1};
	{"RightGearRotate",1};
	{"FrontGearTurn",1};
	{"HorizonX",1};
}

local ModelsToIgnore = {
--	script.Parent.Main.Engine,
--	script.Parent.Main.Motors.FGT,
--	script.Parent.Main.Motors.LG2,
--	script.Parent.Main.Motors.RG2,
--	script.Parent.Main.Motors.X,
}
--------------------------------------------------------------------------------------------------
-- WELD FUNCTION
function weldit(p1, p2)
	local w = Instance.new('Weld')
	w.Part0, w.Part1 = p1, p2
	w.C1 = p2.CFrame:inverse() * p1.CFrame
	w.Parent = p1
	w.Name = p2.Name
end
--------------------------------------------------------------------------------------------------
-- CHECKS IGNORE LIST
function CheckIgnore(Thing)
	local found = false
	for _,p in pairs(ModelsToIgnore) do
		if Thing == p or Thing:IsDescendantOf(p) then
			found = true
			break;
		end
	end
	for _,g in pairs(IgnoreList) do
		if g[2] == 1 then
			if Thing.Name == g[1] then
				found = true
				table.insert(ModelsToIgnore,Thing)
	            break;
			end
		elseif g[2] == 2 then
			if Thing.Parent.Name == g[1] then
				found = true
				table.insert(ModelsToIgnore,Thing.Parent)
				break;
			end
		end
	end
	return (found)
end
--------------------------------------------------------------------------------------------------
-- LOOKS FOR PARTS
function FindParts(Item)
	for _,i in pairs(Item:GetDescendants()) do
		local NoWeld = CheckIgnore(i)
		if NoWeld == false then
			if i:IsA("BasePart") then
				weldit(script.Parent.Main.Weld,i)
			end
		end
	end
end
FindParts(script.Parent)

function UnAnchor(Item)
	for _,i in pairs(Item:GetDescendants()) do
		local NoWeld = CheckIgnore(i)
		if NoWeld == false then
			if i:IsA("BasePart") then
				i.Anchored = false
			end
		end
	end
end
UnAnchor(script.Parent)