--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	this file without the permission of its owner(s).
--]]

CHIP.m_bDrawLabel = false;
CHIP.m_bInvalid = false;
CHIP.m_sName = "Base Chip";
CHIP.m_image = util.GetImage("chip");

-- Called when the chip is constructed.
function CHIP:__init()
	self.m_inputs = {"A", "B"};
	self.m_outputs = {"C"};
	self.m_nextFlow = {};
	self.m_inputWires = {};
	self.m_outputWires = {};
	self.m_outputCache = {};
	self:OnInitialize();
	
	for k, v in ipairs(self.m_outputs) do
		self.m_nextFlow[v] = 0;
		self.m_outputWires[v] = {};
	end;
end;

-- A function to remove the chip.
function CHIP:Remove()
	for k, v in pairs(self.m_inputWires) do
		v:GetEditorObject():Remove();
	end;
	
	for k, v in pairs(self.m_outputWires) do
		for k2, v2 in pairs(v) do
			v2:GetEditorObject():Remove();
		end;
	end;
	
	self.m_bInvalid = true;
end;

-- A function to get whether the chip is valid.
function CHIP:IsValid()
	return (not self.m_bInvalid);
end;

-- A function to get the image of the chip.
function CHIP:GetImage()
	return self.m_image;
end;

-- A function to get whether the chip should have a label drawn.
function CHIP:GetDrawLabel()
	return self.m_bDrawLabel;
end;

-- A function to set the chip's editor object.
function CHIP:SetEditorObject(editorObject)
	self.m_editorObject = editorObject;
end;

-- A function to get the chip's editor object.
function CHIP:GetEditorObject()
	return self.m_editorObject;
end;

-- A function to set the input wire for the chip.
function CHIP:SetInputWire(wireTable, inputKey)
	local wireObject = self.m_inputWires[inputKey];
	
	if ( wireObject and wireObject:IsValid() ) then
		wireObject:GetEditorObject():Remove();
	end;
	
	self.m_inputWires[inputKey] = wireTable;
end;

-- A function to get the input wire for the chip.
function CHIP:GetInputWire(inputKey)
	return self.m_inputWires[inputKey];
end;

-- A function to add an output wire to the chip.
function CHIP:AddOutputWire(wireTable, outputKey)
	for k, v in ipairs( self.m_outputWires[outputKey] ) do
		if (v == wireTable) then
			return;
		end;
	end;
	
	table.insert(
		self.m_outputWires[outputKey],
		wireTable
	);
end;

-- A function to get whether a chip's output should flow.
function CHIP:ShouldOutputFlow(key)
	if ( g_Time:CurTime() > self.m_nextFlow[key] ) then
		return true;
	else
		return false;
	end;
end;

-- A function to reset an output flow.
function CHIP:ResetOutputFlow(key)
	self.m_nextFlow[key] = g_Time:CurTime() + 1;
end;

-- A function to cache an output value.
function CHIP:CacheOutputValue(key, value)
	self.m_outputCache[key] = value;
end;

-- A function to get a cached output value.
function CHIP:GetCachedOutput(key)
	return self.m_outputCache[key];
end;

-- A function to get a chip's input.
function CHIP:GetInput(key)
	return self:OnGetInput(key);
end;

-- A function to get a chip's output.
function CHIP:GetOutput(key)
	if ( self:ShouldOutputFlow(key) ) then
		self:CacheOutputValue( key, self:OnGetOutput(key) );
		self:ResetOutputFlow(key);
	end;
	
	return self:GetCachedOutput(key);
end;

-- A function to get the chip's inputs.
function CHIP:GetInputs()
	return self.m_inputs;
end;

-- A function to get the chip's outputs.
function CHIP:GetOutputs()
	return self.m_outputs;
end;

-- A function to get whether a chip has any inputs.
function CHIP:HasInputs()
	return (#self.m_inputs > 0);
end;

-- A function to get whether a chip has any outputs.
function CHIP:HasOutputs()
	return (#self.m_outputs > 0);
end;

-- A function to get the chip's name.
function CHIP:GetName()
	return self.m_sName;
end;

-- A function to get the chip's class.
function CHIP:GetClass()
	return self.m_sClassName;
end;

--[[
	Called when the chip should be drawn.
	Return true to override default drawing.
--]]
function CHIP:OnDraw(editorObject)
	return false;
end;

-- Called when the chip has initialized.
function CHIP:OnInitialize() end;

-- Called when the chip's output is needed.
function CHIP:OnGetOutput(key)
	local inputA = self:GetInput("A");
	local inputB = self:GetInput("B");
	
	return (inputA and inputB);
end;

-- Called when the chip's input is needed.
function CHIP:OnGetInput(key)
	local inputWire = self:GetInputWire(key);
	
	if ( not inputWire or not inputWire:IsValid() ) then
		return false;
	end;
	
	local output = inputWire:GetOutput();
	
	if (output) then
		return output.chip:GetOutput(output.key);
	else
		return false;
	end;
end;

-- Called when the select menu should be edited.
function CHIP:OnEditSelectMenu(menu) end;