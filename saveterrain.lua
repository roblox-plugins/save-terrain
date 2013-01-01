--[[

Crazyman32's Save Terrain plugin
Version 1.0

About:
ROBLOX posted a blog article: http://blog.roblox.com/2012/06/using-run-length-encoding-to-compress-roblox-terrain/
The article describes how ROBLOX uses a
Run Length Encoding (RLE) method to save
terrain efficiently. Seeing this, I thought
it would be cool to try to make a plugin
that does the same thing, but that can
save it to a script that another plugin
can then load it from.

That way, you can save your terrain inside a
script, put the script in another map, and
load it into there as well.

The original version of this could save my
Freeflight terrain in 132 seconds. The final
version (this) can do it in just 35.

]]

self = PluginManager():CreatePlugin()
toolbar = self:CreateToolbar("TerrainSave")
button = toolbar:CreateButton("","Save Terrain","terrainsave.png")

local gui,gui2
local saving = false

local block = {
	[Enum.CellBlock.CornerWedge]		=	"a";
	[Enum.CellBlock.HorizontalWedge]	=	"b";
	[Enum.CellBlock.InverseCornerWedge]	=	"c";
	[Enum.CellBlock.Solid]				=	"d";
	[Enum.CellBlock.VerticalWedge]		=	"e";
}

local material = {
	[Enum.CellMaterial.Aluminum]		=	"a";
	[Enum.CellMaterial.Asphalt]			=	"b";
	[Enum.CellMaterial.BluePlastic]		=	"c";
	[Enum.CellMaterial.Brick]			=	"d";
	[Enum.CellMaterial.Cement]			=	"e";
	[Enum.CellMaterial.CinderBlock]		=	"f";
	[Enum.CellMaterial.Empty]			=	"g";
	[Enum.CellMaterial.Gold]			=	"h";
	[Enum.CellMaterial.Granite]			=	"i";
	[Enum.CellMaterial.Grass]			=	"j";
	[Enum.CellMaterial.Gravel]			=	"k";
	[Enum.CellMaterial.Iron]			=	"l";
	[Enum.CellMaterial.MossyStone]		=	"m";
	[Enum.CellMaterial.RedPlastic]		=	"n";
	[Enum.CellMaterial.Sand]			=	"o";
	[Enum.CellMaterial.Water]			=	"p";
	[Enum.CellMaterial.WoodLog]			=	"q";
	[Enum.CellMaterial.WoodPlank]		=	"r";
}

local orientation = {
	[Enum.CellOrientation.NegX]			=	"a";
	[Enum.CellOrientation.NegZ]			=	"b";
	[Enum.CellOrientation.X]			=	"c";
	[Enum.CellOrientation.Z]			=	"d";
}

_G.terrainBlock = {}
_G.terrainMaterial = {}
_G.terrainOrientation = {}
for e,s in pairs(block) do
	_G.terrainBlock[s] = e
end
for e,s in pairs(material) do
	_G.terrainMaterial[s] = e
end
for e,s in pairs(orientation) do
	_G.terrainOrientation[s] = e
end

function SaveTerrain()
	print("Saving terrain...")
	local start = tick()
	local file = Instance.new("Script")
	file.Name = "TerrainData"
	file.Disabled = true

	-- All these variables actually help the code run much quicker
	local allS = {}
	local s = {}
	local t = game.Workspace.Terrain
	local vol = t:CountCells()
	local ext = t.MaxExtents
	local get = t.GetCell
	local n,n2 = 0,0
	local last = ""
	local pre = ""
	local c,c2 = 1,0
	local x = 0
	local emp,wtr = Enum.CellMaterial.Empty,Enum.CellMaterial.Water
	local per,bar,cou = gui2.Percent,gui2.Area.Bar,gui2.Count
	per.Text = "0.00%"
	cou.Text = "Starting..."
	bar.Size = UDim2.new(0,0,1,0)
	gui2.Visible = true
	local vol2 = (math.abs(ext.Min.Y-ext.Max.Y)*math.abs(ext.Min.Z-ext.Max.z)*math.abs(ext.Min.X-ext.Max.X))
	for Y = ext.Min.Y,ext.Max.Y do for Z = ext.Min.Z,ext.Max.Z do for X = ext.Min.X,ext.Max.X do
		local m,b,o = get(t,X,Y,Z)
		if (m ~= emp) then
			x = (x+1)
			if (m == wtr) then vol = (vol+1) end
		end
		local this = (material[m]..block[b]..orientation[o])
		if (this == last) then
			c = (c+1)
			c2 = (c2+1)
		else
			if (c ~= 0) then
				-- Store terrain info:
				s[n-c2] = (c..pre..last.."("..X..","..Y..","..Z..")\n")
				pre = ("("..(X+1)..","..Y..","..Z..")")
				last = this
			end
			c = 1
		end
		n = (n+1)
		if (n > 200000) then
			-- Puase iteration and update interface
			n = 0
			c2 = 0
			local r = (x/vol)
			per.Text = ("%.2f%%"):format(r*100)
			cou.Text = ((vol-x).." blocks left")
			bar.Size = UDim2.new(r,0,1,0)
			local s2 = table.concat(s)
			table.insert(allS,s2)
			s = {}
			Wait(0.001)
		end
		if (x >= vol) then break end
	end if (x >= vol) then break end end if (x >= vol) then break end end

	table.insert(allS,table.concat(s))
	s = {}
	for _,partS in pairs(allS) do
		if (partS:find("\n")) then
			partS = partS:sub(partS:find("\n")+1)
		end
		table.insert(s,partS)
	end
	allS = nil
	file.Source = table.concat(s)

	file.Parent = game.Workspace
	gui2.Visible = false
	print(("Terrain saved in %.2f seconds"):format(tick()-start))
	return file
end

function CreateGUI()
	local screen = Instance.new("ScreenGui",game:GetService("CoreGui"))
	screen.Name = "SaveTerrainGui"
	gui = Instance.new("Frame",screen)
	gui.Name = "Prompt"
	gui.Position = UDim2.new(0.5,-150,0.5,-50)
	gui.Size = UDim2.new(0,300,0,100)
	gui.Style = Enum.FrameStyle.RobloxRound
	local t = Instance.new("TextLabel",gui)
	t.Name = "Title"
	t.Position = UDim2.new(0.5,0,0.25,-4)
	t.Font = Enum.Font.ArialBold
	t.FontSize = Enum.FontSize.Size36
	t.Text = "Save Terrain?"
	t.TextColor3 = Color3.new(1,1,1)
	local yes = Instance.new("TextButton",gui)
	yes.Name = "Yes"
	yes.Position = UDim2.new(0,0,1,0)
	yes.Size = UDim2.new(0.5,-4,-0.5,0)
	yes.Style = Enum.ButtonStyle.RobloxButtonDefault
	yes.Font = Enum.Font.ArialBold
	yes.FontSize = Enum.FontSize.Size18
	yes.Text = "YES"
	yes.TextColor3 = Color3.new(1,1,1)
	local no = Instance.new("TextButton",gui)
	no.Name = "No"
	no.Position = UDim2.new(1,0,1,0)
	no.Size = UDim2.new(-0.5,4,-0.5,0)
	no.Style = Enum.ButtonStyle.RobloxButton
	no.Font = Enum.Font.ArialBold
	no.FontSize = Enum.FontSize.Size18
	no.Text = "NO"
	no.TextColor3 = Color3.new(1,1,1)
	yes.MouseButton1Click:connect(function()
		if (game.Workspace.Terrain:CountCells() == 0) then
			print("NO TERRAIN TO SAVE")
			return
		end
		gui.Visible = false
		saving = true
		local file = SaveTerrain()
		game.Selection:Set({file})
		saving = false
	end)
	no.MouseButton1Click:connect(function()
		gui.Visible = false
	end)
	gui2 = Instance.new("Frame",screen)
	gui2.Visible = false
	gui2.Name = "Saving"
	gui2.Position = UDim2.new(0.5,-150,0.5,-40)
	gui2.Size = UDim2.new(0,300,0,80)
	gui2.Style = Enum.FrameStyle.RobloxRound
	t = Instance.new("TextLabel",gui2)
	t.Name = "Title"
	t.Position = UDim2.new(0,0,0,8)
	t.Font = Enum.Font.ArialBold
	t.FontSize = Enum.FontSize.Size18
	t.Text = "Saving Terrain"
	t.TextColor3 = Color3.new(1,1,1)
	t.TextXAlignment = Enum.TextXAlignment.Left
	local p = Instance.new("TextLabel",gui2)
	p.Name = "Percent"
	p.Position = UDim2.new(1,0,0,8)
	p.Font = Enum.Font.ArialBold
	p.FontSize = Enum.FontSize.Size18
	p.Text = "0%"
	p.TextColor3 = Color3.new(1,1,1)
	p.TextXAlignment = Enum.TextXAlignment.Right
	local a = Instance.new("Frame",gui2)
	a.Name = "Area"
	a.BackgroundColor3 = Color3.new(0,0,0)
	a.BorderSizePixel = 0
	a.Position = UDim2.new(0,0,0.5,-10)
	a.Size = UDim2.new(1,0,0,20)
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
	local c = Instance.new("TextLabel",gui2)
	c.Name = "Count"
	c.Position = UDim2.new(0.5,0,1,-8)
	c.Font = Enum.Font.ArialBold
	c.FontSize = Enum.FontSize.Size18
	c.Text = ""
	c.TextColor3 = Color3.new(1,1,1)
end

button.Click:connect(function()
	if (not gui) then
		CreateGUI()
	elseif (not saving) then
		gui.Visible = (not gui.Visible)
	end
end)