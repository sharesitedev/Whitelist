print("Control_module loaded")
local event = script.Parent.Event
local bindings = script.Parent.Parent.Parent.Parent.Bindings
local AnimationModule = require(script.Parent.Parent.Animation_module)
local Motors = script.Parent.Parent.Parent.Parent.Main.Motors

local Customize = require(script.Parent.Parent.Customize)

event.OnServerEvent:Connect(function(client, id, input)
	if id == "keydown" then
		if (input == Customize.Gear) then

		elseif (input == Customize.Canopy) then

		elseif (input == Customize.Flaps) then
			AnimationModule.Flaps()
		elseif (input == Customize.RudderLeft) then
			Motors.RudderL.Motor.DesiredAngle = .6
			Motors.RudderR.Motor.DesiredAngle = .6
			Motors.Gear.Gears.Front.FrontGearTurn.Motor.DesiredAngle = 1
		elseif (input == Customize.RudderRight) then
			Motors.RudderL.Motor.DesiredAngle = -.6
			Motors.RudderR.Motor.DesiredAngle = -.6
			Motors.Gear.Gears.Front.FrontGearTurn.Motor.DesiredAngle = -1
		elseif (input == Customize.Flare) then
			AnimationModule.Flare()
		elseif (input == Customize.Bomb) then

		elseif (input == Customize.Tank) then

		elseif (input == Customize.Nav) then

		elseif (input == Customize.AntiCollision) then

		elseif (input == Customize.Gun) then
			AnimationModule.Gun(true)
		end 
	end
	if id == "keyup" then
		if (input == Customize.Gun) then
			AnimationModule.Gun(false)
		elseif (input == Customize.RudderLeft) or (input == Customize.RudderRight) then
			Motors.RudderL.Motor.DesiredAngle = 0
			Motors.RudderR.Motor.DesiredAngle = 0
			
			Motors.Gear.Gears.Front.FrontGearTurn.Motor.DesiredAngle = 0
		end
	end
	if id == "deflctn" then
		bindings.Elevators.Value = input[1]
		bindings.Ailerons.Value = input[2]
		Motors.ElevatorL.Motor.DesiredAngle = input[1]/3
		Motors.ElevatorR.Motor.DesiredAngle = input[1]/3
		Motors.AileronL.Motor.DesiredAngle = input[2]/2
		Motors.AileronR.Motor.DesiredAngle = -input[2]/2
		
		Motors.Cockpit.StickX.Motor.DesiredAngle = 	input[2]/5
		Motors.Cockpit.StickY.Motor.DesiredAngle = 	-input[1]/15
		Motors.IntakeL.Motor.DesiredAngle = input[1]/10
		Motors.IntakeR.Motor.DesiredAngle = input[1]/10
	end
	if id == "throttle" then
		bindings.Throttle.Value = input
		if bindings.Throttle.Value < 1 then
			Motors.Cockpit.Throttle.Motor.DesiredAngle = -(bindings.Throttle.Value) * 0.6
		else
			Motors.Cockpit.Throttle.Motor.DesiredAngle = -(bindings.Throttle.Value) * 0.65 
		end
		if script.Parent.Parent.Parent.Parent.Bindings.Engine.Value == true then
			Motors.Parent.Engine.L.Idle.PlaybackSpeed = 1 * bindings.Throttle.Value + 0.5
		end
		if bindings.Throttle.Value <= 0 and bindings.Engine.Value then
			Motors.Airbrake.Motor.DesiredAngle = 0.9
--			if Motors.Airbrake.AssemblyLinearVelocity < 25 then
		--		Motors.Parent.Parent.Animations.Airbrake.Airbrake.Force.VectorForce.Enabled = true
		--	end
		elseif bindings.Throttle.Value >= 0 then
			Motors.Airbrake.Motor.DesiredAngle = 0
		--	Motors.Parent.Parent.Animations.Airbrake.Airbrake.Force.VectorForce.Enabled = false
		end
	end
end)