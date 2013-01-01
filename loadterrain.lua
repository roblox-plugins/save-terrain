self = PluginManager():CreatePlugin()
toolbar = self:CreateToolbar("TerrainSave")
button = toolbar:CreateButton("","Load Terrain","terrainload.png")

local gui
local loading = false

while (not _G.terrainOrientation) do Wait(0.1) end
Wait(1)

local block,material,orientation = _G.terrainBlock,_G.terrainMaterial,_G.terrainOrientation
_G.terrainBlock,_G.terrainMaterial,_G.terrainOrientation = nil,nil,nil

local terrPattern = ("(%d+)%((%-*%d+),(%-*%d+),(%-*%d+)%)(%a%a*)(%a%a*)(%a%a*)%((%-*%d+),(%-*%d+),(%-*%d+)%)")
local match = string.match

function LoadTerrain(s)
	print("Loading terrain")
	do
		local cam = game.Workspace.CurrentCamera
		cam.CoordinateFrame = CFrame.new(1024,1024,1024)
		cam.Focus = CFrame.new(0,40,0)
	end
	local start = tick()
	local t = game.Workspace.Terrain
	local set = t.SetCells
	local r3 = Region3int16.new
	local v3 = Vector3int16.new
	local c,ln = 0,0
	local lines = 1
	for _ in s:gmatch("%C+") do lines = (lines+1) end
	local per,bar = gui.Percent,gui.Area.Bar
	per.Text = "0%"
	local UD2 = UDim2.new
	bar.Size = UD2(0,0,1,0)
	gui.Visible = true
	for l in s:gmatch("%C+") do
		c = (c+1)
		ln = (ln+1)
		local n,x,y,z,m,b,o,x2,y2,z2 = match(l,terrPattern)
		set(t,r3(v3(x,y,z),v3(x2,y2,z2)),material[m],block[b],orientation[o])
		if (c > 12000) then
			c = 0
			local r = (ln/lines)
			per.Text = (tostring(math.floor(r*100)).."%")
			bar.Size = UD2(r,0,1,0)
			wait(0.001)
		end
	end
	gui.Visible = false
	print(("Terrain loaded in %.2f seconds"):format(tick()-start))
end

function CreateGUI()
	local screen = Instance.new("ScreenGui",game:GetService("CoreGui"))
	screen.Name = "LoadTerrainGui"
	gui = Instance.new("Frame",screen)
	gui.Visible = false
	gui.Name = "Loading"
	gui.Position = UDim2.new(0.5,-150,0.5,-25)
	gui.Size = UDim2.new(0,300,0,50)
	gui.Style = Enum.FrameStyle.RobloxRound
	t = Instance.new("TextLabel",gui)
	t.Name = "Title"
	t.Position = UDim2.new(0,0,0.25,-4)
	t.Font = Enum.Font.ArialBold
	t.FontSize = Enum.FontSize.Size18
	t.Text = "Loading Terrain"
	t.TextColor3 = Color3.new(1,1,1)
	t.TextXAlignment = Enum.TextXAlignment.Left
	local p = Instance.new("TextLabel",gui)
	p.Name = "Percent"
	p.Position = UDim2.new(1,0,0.25,-4)
	p.Font = Enum.Font.ArialBold
	p.FontSize = Enum.FontSize.Size18
	p.Text = "0%"
	p.TextColor3 = Color3.new(1,1,1)
	p.TextXAlignment = Enum.TextXAlignment.Right
	local a = Instance.new("Frame",gui)
	a.Name = "Area"
	a.BackgroundColor3 = Color3.new(0,0,0)
	a.BorderSizePixel = 0
	a.Position = UDim2.new(0,0,0.5,0)
	a.Size = UDim2.new(1,0,0.5,0)
	local b = Instance.new("Frame",a)
	b.Name = "Bar"
	b.BackgroundColor3 = Color3.new(0,1,0)
	b.BorderSizePixel = 0
	b.Size = UDim2.new(0,0,1,0)
	local o = Instance.new("ImageLabel",a)
	o.Name = "Overlay"
	o.BackgroundTransparency = 1
	local img = "http://www.roblox.com/asset/?id=67010381"
	game:GetService("ContentProvider"):Preload(img)
	o.Image = img
	o.Size = UDim2.new(1,0,1,0)
	o.ZIndex = 2
end

button.Click:connect(function()
	if (loading) then return end
	local s = game.Selection:Get()[1]
	if (not s or not s:IsA("Script")) then
		print("Please select the script containing the terrain data and then select the plugin again")
		return
	end
	if (not gui) then
		CreateGUI()
	end
	loading = true
	LoadTerrain(s.Source)
	loading = false
end)