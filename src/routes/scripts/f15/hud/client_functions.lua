print("Client_functions loaded")
local main = script.main.Value
local hud = main.HUD
local screen = hud.screen.CanvasGroup.base

local cs = game:GetService("CollectionService")
local debrs = game:GetService("Debris")
local ts = game:GetService("TweenService")
local failures = false
----
local marker = nil
local pitch_ladder = {}
local heading_scale = {}
local disposable_guis = {}
local impact_vector = Vector3.new(0,0,0)

local distance = 0

local d = {
	displacement = Vector2.new(0,0),
	velocity = Vector2.new(0,0)
}


local log = {
	closure = {},
	displacement = {Vector3.new()},
	velocity = {Vector2.new()}
}

local function draw(obj, c1, c2)
	if obj:IsA("GuiObject") then
		local startX, startY = c1.X.Offset, c1.Y.Offset
		local endX, endY = c2.X.Offset, c2.Y.Offset
		--if math.abs(endY) > screen.AbsoluteSize.Y/2 and math.abs(endX) > screen.AbsoluteSize.X/2 then
		--	obj.Visible = false
		--else
		--	obj.Visible = true
		if math.abs(endY) > screen.AbsoluteSize.Y/2 then
			endY /= math.abs(2*endY/screen.AbsoluteSize.Y)
			endX /= math.abs(2*endY/screen.AbsoluteSize.Y)
		end
		if math.abs(endX) > screen.AbsoluteSize.X/2 then
			endY /= math.abs(2*endX/screen.AbsoluteSize.X)
			endX /= math.abs(2*endX/screen.AbsoluteSize.X)
		end
		--end

		obj.AnchorPoint = Vector2.new(0.5, 0.5)
		obj.Size = UDim2.new(0, ((endX - startX) ^ 2 + (endY - startY) ^ 2) ^ 0.5 + 1, 0, 2) -- Get the size using the distance formula
		obj.Position = UDim2.new(0.5, (startX + endX) / 2, 0.5, (startY + endY) / 2) -- Get the position using the midpoint formula
		obj.Rotation = math.atan2(endY - startY, endX - startX) * (180 / math.pi) -- Get the rotation using atan2, convert radians to degrees
	else
		local frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = Color3.fromRGB(0,255,150)
		frame.Transparency = 1
		frame.Parent = hud.screen.CanvasGroup.base.gun_funnel
		return frame		
	end

end



local function ReturnHeatSources()
	local targets = cs:GetTagged("heat_source")
	local best
	table.foreachi(targets, function(_,v)
		local ofs = hud.CFrame:PointToObjectSpace(v.Position)
		local score, range = ((ofs.X^2 + ofs.Y^2)^0.5)/ofs.Z, ofs.Z
		if math.abs(score) < 0.07 then
			if not best then
				best = {v, range}
			elseif best[2] > range then
				best = {v, range}
			end
		end
	end)
	return best and best[1] or nil
end

local gun_funnel = {}



local config = {
	screen_scale = 0.001
}
--config.funnel_width = 50
--config.funnel_segments = 10

local camera = {}
camera.max = 1.6

local fpm_caged = false

local screen_size = hud.screen.PixelsPerStud

local delayed_cf = {}
delayed_cf.base = nil
delayed_cf.difference = nil

--for n = 1, config.funnel_segments do
--	gun_funnel["_"..n] = {cf = nil, R = NewFrame(), L = NewFrame()}
--end

if not pcall(function()
		for pitch = -85, 85, 5 do
			if pitch > 0 then
				local bar = screen.horizon.negative:Clone()
				bar.Parent = screen.horizon.line
				bar.L.Rotation = -pitch/2
				bar.L.Up.Rotation = pitch/2
				bar.R.Rotation = pitch/2
				bar.R.Up.Rotation = -pitch/2
				bar:SetAttribute("Pitch",pitch)
				bar.Visible = true
				table.insert(pitch_ladder, bar)
			end
			if pitch < 0 then
				local bar = screen.horizon.positive:Clone()
				bar.Parent = screen.horizon.line
				bar.L.Rotation = -pitch/2
				bar.L.Up.Rotation = pitch/2
				bar.R.Rotation = pitch/2
				bar.R.Up.Rotation = -pitch/2
				bar:SetAttribute("Pitch",pitch)
				bar.Visible = true
				table.insert(pitch_ladder, bar)
			end
		end

		for heading = -2, 2, 1 do
			local bar = screen.heading.t:Clone()
			bar.Parent = screen.heading
			bar:SetAttribute("Offset",heading)
			bar.Visible = true
			table.insert(heading_scale, bar)
			for index = 1,5,1 do
				local tic = bar.up:Clone()
				tic.Position = UDim2.new(0.5, -screen_size * camera.max * math.rad(2*index), 1, 12)
				tic.Parent = bar
			end
		end

	end) then
	script:Destroy()
end


--[[nction drawPath(Line, P1, P2)
	local startX, startY = P1.X.Offset, P1.Y.Offset
	local endX, endY = P2.X.Offset, P2.Y.Offset
	Line.AnchorPoint = Vector2.new(0.5, 0.5)
	Line.Size = UDim2.new(0, ((endX - startX) ^ 2 + (endY - startY) ^ 2) ^ 0.5 + 1, 0, 4) -- Get the size using the distance formula
	Line.Position = UDim2.new(0.5, (startX + endX) / 2, 0.5, (startY + endY) / 2) -- Get the position using the midpoint formula
	Line.Rotation = math.atan2(endY - startY, endX - startX) * (180 / math.pi) -- Get the rotation using atan2, convert radians to degrees
end]]



game:GetService("RunService").RenderStepped:Connect(function(dt)
	if (workspace.CurrentCamera.CFrame.p - hud.Position).Magnitude < 6 then

		local xh, reason = pcall(function() -- HUD

			camera.offset = hud.CFrame:PointToObjectSpace(workspace.CurrentCamera.CFrame.Position)

			local relative = {}
			relative.velocity = hud.AssemblyLinearVelocity.Magnitude > 1 and hud.CFrame:VectorToObjectSpace(hud.AssemblyLinearVelocity) or Vector3.new(0,0,0.001)

			----REPLICATES A COLLIMATED DISPLAY SOURCE
			--			screen.Scale.Scale = camera.offset.Z/camera.max
			screen.Position = UDim2.new(0.5, camera.offset.X * screen_size, 0.5, -camera.offset.Y * screen_size)

			----HORIZON LINE

			screen.horizon.Rotation = hud.Orientation.Z
			screen.horizon.line.Position = UDim2.new(0.5, fpm_caged and screen.fpm.Position.X.Offset or 0, 0.5, screen_size*math.rad(hud.Orientation.X) * camera.max)

			table.foreach(pitch_ladder, function(_,n)
				n.Position = UDim2.new(0.5, 0, 0.5, screen_size * camera.max * math.rad(n:GetAttribute("Pitch")))
			end)

			----FLIGHT PATH VECTOR/MARKER UNCAGED
			screen.ghost_fpm.Visible = fpm_caged
			if not fpm_caged then
				screen.fpm.Position = UDim2.new(0.5, -screen_size * camera.max * (relative.velocity.X/relative.velocity.Z), 0.5, screen_size * camera.max * (relative.velocity.Y/relative.velocity.Z))
			else
				screen.ghost_fpm.Position = UDim2.new(0.5, -screen_size * camera.max * (relative.velocity.X/relative.velocity.Z), 0.5, screen_size * camera.max * (relative.velocity.Y/relative.velocity.Z) -5)
			end


			---- ILS/TACAN
			local found_ils = false
			for _,p in pairs(cs:GetTagged("ils")) do
				local ils_offset = p.CFrame:PointToObjectSpace(hud.Position) * Vector3.new(1,1,-1)
				if ils_offset.Z > 0 and (ils_offset.X^2 + ils_offset.Y^2)^0.5/ils_offset.Z < 1 then
					fpm_caged = true
					screen.fpm.Position = screen.steering_cross.Position - UDim2.fromOffset(100 * ils_offset.X/math.abs(ils_offset.Z), 100 * ils_offset.Y/math.abs(ils_offset.Z) - 4)
					ils_offset = hud.CFrame:PointToObjectSpace(p.Position)
					screen.steering_cross.Position = UDim2.new(0.5, 0.75 * screen_size * camera.max * math.clamp((ils_offset.X/math.abs(ils_offset.Z))^1/3, -0.2, 0.2), 0.5, -0.75 * screen_size * camera.max * math.clamp((ils_offset.Y/math.abs(ils_offset.Z))^1/3, -0.2, 0.2))
					found_ils = true
					break
				end
			end
			fpm_caged = found_ils
			screen.steering_cross.Visible = found_ils
			screen.steering_cross.Visible = false
			fpm_caged = false

			---- BANK ANGLE SCALE
			screen.bank_angle.p.Rotation = math.clamp(hud.Orientation.Z,-60,60)

			----HEADING SCALE
			table.foreach(heading_scale, function(_,n)
				n.Position = UDim2.new(0.5, 0.5 * screen_size * camera.max * math.rad(n:GetAttribute("Offset")*10+hud.Orientation.Y%10), 0, 14)
				n.Text = math.ceil(hud.Orientation.Y/10-n:GetAttribute("Offset"))%36
			end)

			----EEGS
			-- calculations

			local d_sum = Vector3.new()
			local v_sum = Vector2.new()

			table.insert(log.displacement, 1, hud.CFrame.LookVector/dt)
			if log.displacement[20] then table.remove(log.displacement,20) end
			if log.displacement[21] then table.remove(log.displacement,21) end
			for i,d in ipairs(log.displacement) do
				if log.displacement[i+1] then
					d_sum += hud.CFrame:VectorToObjectSpace(d-log.displacement[i+1])
				end
				if i > 20 then break end
			end

			--sum = hud.CFrame:VectorToObjectSpace(sum)
			d.displacement = d.displacement*0.9 + 0.1*(Vector2.new(d_sum.X, d_sum.Y) / math.max(1, #log.displacement-1))

			table.insert(log.velocity, 1, d.displacement/dt)
			if log.velocity[20] then table.remove(log.velocity,20) end
			if log.velocity[21] then table.remove(log.velocity,21) end
			for i,d in ipairs(log.velocity) do
				if log.velocity[i+1] then
					v_sum += d-log.velocity[i+1]
				end
				if i > 20 then break end
			end

			d.velocity = d.velocity*0.95 + 0.05*(Vector2.new(-v_sum.X, v_sum.Y) / math.max(1, #log.velocity-1))

			local function calc_sight(t)
				local g = hud.CFrame:VectorToObjectSpace(Vector3.new(0,-1,0))
				return d.displacement*(t)+0.5*d.velocity*(t)^2-Vector2.new(0,math.rad(2))
			end
			local R,P = 0.2, 1
			local width, v = 20, 2500 -- offset = 20/(2500x^P*R^P))
			--draw(screen.lcos.line_1R, UDim2.new(0.5,0,0.5,0), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(R^P).X + width/(v*R^P)),0.5,camera.max*screen_size*calc_sight(R^P).Y))
			draw(screen.lcos.line_1R, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(R^P).X + width/(v*R^P)),0.5,camera.max*screen_size*calc_sight(R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(2^P*R^P).X + width/(v*2^P*R^P)),0.5,camera.max*screen_size*calc_sight(2^P*R^P).Y))
			draw(screen.lcos.line_2R, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(2^P*R^P).X + width/(v*2^P*R^P)),0.5,camera.max*screen_size*calc_sight(2^P*R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(3^P*R^P).X + width/(v*3^P*R^P)),0.5,camera.max*screen_size*calc_sight(3^P*R^P).Y))
			draw(screen.lcos.line_3R, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(3^P*R^P).X + width/(v*3^P*R^P)),0.5,camera.max*screen_size*calc_sight(3^P*R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(4^P*R^P).X + width/(v*4^P*R^P)),0.5,camera.max*screen_size*calc_sight(4^P*R^P).Y))
			draw(screen.lcos.line_4R, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(4^P*R^P).X + width/(v*4^P*R^P)),0.5,camera.max*screen_size*calc_sight(4^P*R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(5^P*R^P).X + width/(v*5^P*R^P)),0.5,camera.max*screen_size*calc_sight(5^P*R^P).Y))

			--draw(screen.lcos.line_1L, UDim2.new(0.5,0,0.5,0), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(R^P).X - width/(v*R^P)),0.5,camera.max*screen_size*calc_sight(R^P).Y))
			draw(screen.lcos.line_1L, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(R^P).X - width/(v*R^P)),0.5,camera.max*screen_size*calc_sight(R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(2^P*R^P).X - width/(v*2^P*R^P)),0.5,camera.max*screen_size*calc_sight(2^P*R^P).Y))
			draw(screen.lcos.line_2L, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(2^P*R^P).X - width/(v*2^P*R^P)),0.5,camera.max*screen_size*calc_sight(2^P*R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(3^P*R^P).X - width/(v*3^P*R^P)),0.5,camera.max*screen_size*calc_sight(3^P*R^P).Y))
			draw(screen.lcos.line_3L, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(3^P*R^P).X - width/(v*3^P*R^P)),0.5,camera.max*screen_size*calc_sight(3^P*R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(4^P*R^P).X - width/(v*4^P*R^P)),0.5,camera.max*screen_size*calc_sight(4^P*R^P).Y))
			draw(screen.lcos.line_4L, UDim2.new(0.5,-camera.max*screen_size*(calc_sight(4^P*R^P).X - width/(v*4^P*R^P)),0.5,camera.max*screen_size*calc_sight(4^P*R^P).Y), UDim2.new(0.5,-camera.max*screen_size*(calc_sight(5^P*R^P).X - width/(v*5^P*R^P)),0.5,camera.max*screen_size*calc_sight(5^P*R^P).Y))


			----TEXT
			--screen.mode.Text = (store.mode_name[1] and tostring(store.mode_name[1].." : "..store.mode_name[2]):upper() or "N/A")
			screen.velocity.Text = math.round(hud.AssemblyLinearVelocity.Magnitude)
			screen.altitude.Text = math.round(hud.Position.Y)
			screen.alpha.Text = -math.round(math.deg(math.atan2(relative.velocity.Y, math.abs(relative.velocity.Z)))*10)/10
		end)
		if not xh then
			warn("Client HUD failed; Script terminated; "..reason)
			script:Destroy()
		end
	end
end)

function update_funnel_cf(t,dt)
	if delayed_cf.base then
		if not delayed_cf.difference then
			delayed_cf.difference = main.Parent.Main.Gun.CFrame:Inverse() * delayed_cf.base
		end
		delayed_cf.difference = delayed_cf.difference:Lerp(main.Parent.Main.Gun.CFrame:Inverse() * delayed_cf.base, 0.05)
		for n,v in pairs(gun_funnel) do
			local r = tonumber(string.sub(n,2))
			local cf = main.Parent.Main.Gun.CFrame
			for _ = 1, r*(math.floor(t/dt)) do
				cf *= delayed_cf.difference
			end
			cf = cf:Lerp(cf * delayed_cf.difference,(t/dt)%1)
			gun_funnel[n]["cf"] = cf
		end
	end
	delayed_cf.base = main.Parent.Main.Gun.CFrame
end