if game:GetService("RunService"):IsClient() then error("Script must be server-side in order to work; use h/ and not hl/") end
local Player,Mouse,mouse,UserInputService,ContextActionService = owner
script.Parent = Player.Character

-- FE STUFF

--RemoteEvent for communicating
local Event = Instance.new("RemoteEvent")
Event.Name = "UserInput_Event"

--Fake event to make stuff like Mouse.KeyDown work
local function fakeEvent()
	local t = {_fakeEvent=true,Connect=function(self,f)self.Function=f end}
	t.connect = t.Connect
	return t
end

--Creating fake input objects with fake variables
local m = {Target=nil,Hit=CFrame.new(),KeyUp=fakeEvent(),KeyDown=fakeEvent(),Button1Up=fakeEvent(),Button1Down=fakeEvent()}
local UIS = {InputBegan=fakeEvent(),InputEnded=fakeEvent()}
local CAS = {Actions={},BindAction=function(self,name,fun,touch,...)
	CAS.Actions[name] = fun and {Name=name,Function=fun,Keys={...}} or nil
end}
--Merged 2 functions into one by checking amount of arguments
CAS.UnbindAction = CAS.BindAction

--This function will trigger the events that have been :Connect()'ed
local function te(self,ev,...)
	local t = m[ev]
	if t and t._fakeEvent and t.Function then
		t.Function(...)
	end
end
m.TrigEvent = te
UIS.TrigEvent = te

Event.OnServerEvent:Connect(function(plr,io)
	if plr~=Player then return end
	if io.isMouse then
		m.Target = io.Target
		m.Hit = io.Hit
	else
		local b = io.UserInputState == Enum.UserInputState.Begin
		if io.UserInputType == Enum.UserInputType.MouseButton1 then
			return m:TrigEvent(b and "Button1Down" or "Button1Up")
		end
		for _,t in pairs(CAS.Actions) do
			for _,k in pairs(t.Keys) do
				if k==io.KeyCode then
					t.Function(t.Name,io.UserInputState,io)
				end
			end
		end
		m:TrigEvent(b and "KeyDown" or "KeyUp",io.KeyCode.Name:lower())
		UIS:TrigEvent(b and "InputBegan" or "InputEnded",io,false)
	end
end)
Event.Parent = NLS([==[
local Player = game:GetService("Players").LocalPlayer
local Event = script:WaitForChild("UserInput_Event")

local UIS = game:GetService("UserInputService")
local input = function(io,a)
	if a then return end
	--Since InputObject is a client-side instance, we create and pass table instead
	Event:FireServer({KeyCode=io.KeyCode,UserInputType=io.UserInputType,UserInputState=io.UserInputState})
end
UIS.InputBegan:Connect(input)
UIS.InputEnded:Connect(input)

local Mouse = Player:GetMouse()
local h,t
--Give the server mouse data 30 times every second, but only if the values changed
--If player is not moving their mouse, client won't fire events
while wait(1/30) do
	if h~=Mouse.Hit or t~=Mouse.Target then
		h,t=Mouse.Hit,Mouse.Target
		Event:FireServer({isMouse=true,Target=t,Hit=h})
	end
end]==],Player.Character)
Mouse,mouse,UserInputService,ContextActionService = m,m,UIS,CAS

-- END

local SPEED = 50

local runService = game:GetService("RunService")

local character: Model = owner.Character or owner.CharacterAdded:Wait()

local blink = false
local blinked = false

local humanoid: Humanoid = character:WaitForChild("Humanoid")

for _,x in ipairs(character:GetDescendants()) do
	if x:IsA("Accessory") or x:IsA("Decal") or x:IsA("Sound") then
		x:Destroy()
	end

	if x:IsA("BasePart") and x ~= humanoid.RootPart then
		x.Transparency = 1
	end
end

humanoid.WalkSpeed = SPEED
humanoid.RootPart.Transparency = 0

local mesh = Instance.new("SpecialMesh")
mesh.MeshId = "rbxassetid://7176615085"
mesh.TextureId = "rbxassetid://7176615317"
mesh.Scale *= 0.02
mesh.Offset = Vector3.new(0,0.6,0)
mesh.Parent = humanoid.RootPart

local function kill()
	local parts = workspace:GetPartBoundsInRadius(humanoid.RootPart.Position,2)
	for _,part in ipairs(parts) do
		if part:IsA("BasePart") then
			local model = part:FindFirstAncestorWhichIsA("Model")
			if model == character then continue end
			local vHumanoid = model:FindFirstChildWhichIsA("Humanoid")
			if not vHumanoid then continue end
			vHumanoid:TakeDamage(math.huge)
			break
		end
	end
end

character.DescendantAdded:Connect(function(x)
	if x:IsA("Accessory") or x:IsA("Decal") then
		x:Destroy()
	end

	if x:IsA("BasePart") and x ~= humanoid.RootPart then
		x.Transparency = 1
	end
end)

UserInputService.InputBegan:Connect(function(input: InputObject)

	print(input)
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		kill()
	end
	
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		if blinked then
			humanoid.RootPart.Position = mouse.Hit.Position + Vector3.new(0,3,0)
			kill()
			blinked = false
		end
	end
end)

coroutine.wrap(function()
	while task.wait(3) do
		blinked = true
		blink = true
		task.wait(0.1)
		blink = false
	end
end)()

runService.Heartbeat:Connect(function()
	local shouldMove = true

	for _,human in ipairs(workspace:GetChildren()) do
		local vHumanoid = human:FindFirstChildWhichIsA("Humanoid")
		if not vHumanoid or not vHumanoid.RootPart then continue end

		local distance_from_player = (humanoid.RootPart.Position - vHumanoid.RootPart.Position).Unit
		local look = vHumanoid.RootPart.CFrame.LookVector

		local dot = look:Dot(distance_from_player)

		local angle = math.deg(math.acos(dot))

		if angle < 90 / 2 then
			shouldMove = false
			break
		end
	end

	if shouldMove then
		blinked = false
		humanoid.WalkSpeed = SPEED
	else
		humanoid.WalkSpeed = 0
	end
end)
