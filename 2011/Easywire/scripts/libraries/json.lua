--[[
	JSON Encoder and Parser for Lua 5.1

	Copyright © 2007 Shaun Brown (http://www.chipmunkav.com).
	All Rights Reserved.

	Permission is hereby granted, free of charge, to any person 
	obtaining a copy of this software to deal in the Software without 
	restriction, including without limitation the rights to use, 
	copy, modify, merge, publish, distribute, sublicense, and/or 
	sell copies of the Software, and to permit persons to whom the 
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be 
	included in all copies or substantial portions of the Software.
	If you find this software useful please give www.chipmunkav.com a mention.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
	ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
	CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

json = {
	m_customTypes = {}
};

json.ObjectWriter = {
	m_backslashes = {
		['\b'] = "\\b",
		['\t'] = "\\t",	
		['\n'] = "\\n", 
		['\f'] = "\\f",
		['\r'] = "\\r", 
		['\\'] = "\\\\", 
		['"']  = "\\\"", 
		['/']  = "\\/"
	}
};
json.ObjectReader = {
	m_escapes = {
		['t'] = '\t',
		['n'] = '\n',
		['f'] = '\f',
		['r'] = '\r',
		['b'] = '\b',
	}
};

json.ObjectWriter.__index = json.ObjectWriter;
json.ObjectReader.__index = json.ObjectWriter;

json.StringReader = {m_iIndex = 0};
json.StringReader.__index = json.StringReader;

json.StringBuilder = {};
json.StringBuilder.__index = json.StringBuilder;

-- A function to get a new string builder.
function json.StringBuilder:New()
	local object = {};
		setmetatable(object, self);
	object.m_buffer = {};
	
	return object;
end;

-- A function to append text to the string builder.
function json.StringBuilder:Append(text)
	self.m_buffer[#self.m_buffer + 1] = text;
end;

-- A function to convert the string builder to a string.
function json.StringBuilder:ToString()
	return table.concat(self.m_buffer)
end;

-- A function to get a new Json writer.
function json.ObjectWriter:New()
	local object = {}
		object.m_writer = json.StringBuilder:New();
	setmetatable(object, self);
	
	return object;
end;

-- A function to append text to the Json writer.
function json.ObjectWriter:Append(text)
	self.m_writer:Append(text);
end;

-- A function to convert the Json writer to a string.
function json.ObjectWriter:ToString()
	return self.m_writer:ToString();
end;

-- A function to write an object to the Json writer.
function json.ObjectWriter:Write(object)
	local objectType = type(object);
	local customType = json.m_customTypes[objectType];
	
	if (objectType == "nil") then
		self:WriteNil();
	elseif (objectType == "boolean") then
		self:WriteString(object);
	elseif (objectType == "number") then
		self:WriteString(object);
	elseif (objectType == "string") then
		self:ParseString(object);
	elseif (objectType == "table") then
		self:WriteTable(object);
	elseif (objectType == "function") then
		self:WriteFunction(object);
	elseif (objectType == "thread") then
		self:WriteError(object);
	elseif (objectType == "userdata") then
		self:WriteError(object);
	elseif (customType) then
		object = customType.OnWrite(object);
		
		if (type(object) == "table") then
			object.__type = objectType;
			self:WriteTable(object);
		end;
	end;
end;

-- A function to write nil to the Json writer.
function json.ObjectWriter:WriteNil()
	self:Append("null");
end;

-- A function to write a string to the Json writer.
function json.ObjectWriter:WriteString(object)
	self:Append( tostring(object) );
end;

-- A function to parse a string as text.
function json.ObjectWriter:ParseString(text)
	self:Append("\"");
		self:Append( string.gsub(text, "[%z%c\\\"/]", function(value)
			return self.m_backslashes[value] or string.format( "\\u%.4X", string.byte(value) );
		end) );
	self:Append("\"");
end;

-- A function to get whether an object is an array.
function json.ObjectWriter:IsArray(objectType)
	local IsIndexed = function(k) 
		if (type(k) == "number" and k > 0) then
			if (math.floor(k) == k) then
				return true;
			end;
		end;
		
		return false;
	end;
	
	local count = 0;
	
	for k, v in pairs(objectType) do
		if ( not IsIndexed(k) ) then
			return false, "{", "}";
		else
			count = math.max(count, k);
		end;
	end;
	
	return true, "[", "]", count;
end;

-- A function to write a table to the Json writer.
function json.ObjectWriter:WriteTable(object)
	local isIndexed, startTag, endTag, count = self:IsArray(object);
	
	self:Append(startTag);
	
	if (isIndexed) then	
		for i = 1, count do
			self:Write( object[i] );
			
			if (i < count) then
				self:Append(",");
			end;
		end;
	else
		local bIsFirst = true;
		
		for k, v in pairs(object) do
			if (not bIsFirst) then
				self:Append(",");
			end;
			
			bIsFirst = false;	
			self:ParseString(k);
			self:Append(":");
			self:Write(v);
		end;
	end;
	
	self:Append(endTag);
end;

-- A function to write an error to the Json object.
function json.ObjectWriter:WriteError(object)
	g_Lua:Print("Json error encoding object of type '"..tostring(object).."'.");
end;

-- A function to write a function to the object.
function json.ObjectWriter:WriteFunction(object)
	if (object == Null) then 
		self:WriteNil();
	else
		self:WriteError(object);
	end;
end;

-- A function to get a new string reader.
function json.StringReader:New(text)
	if (not text) then text = ""; end;
	
	local object = {};
		setmetatable(object, self);
	object.m_sText = text;
	
	return object;
end;

-- A function to peek the next character in the string reader.
function json.StringReader:Peek()
	local index = self.m_iIndex + 1;
	
	if (index <= #self.m_sText) then
		return string.sub(self.m_sText, index, index);
	end;
	
	return nil;
end;

-- A function to get the next character in the string reader.
function json.StringReader:Next()
	self.m_iIndex = self.m_iIndex + 1;
	
	if (self.m_iIndex <= #self.m_sText) then
		return string.sub(self.m_sText, self.m_iIndex, self.m_iIndex);
	end;
	
	return nil;
end;

-- A function to get the entire string from the string reader.
function json.StringReader:All()
	return self.m_sText;
end;

-- A function to get a new Json reader.
function json.ObjectReader:New(text)
	local object = {};
		object.m_reader = json.StringReader:New(text);
	setmetatable(object, self);
	
	return object;
end;

-- A function to read from the Json reader.
function json.ObjectReader:Read()
	self:SkipWhiteSpace();
	local peek = self:Peek();
	
	if (peek == nil) then
		g_Lua:Print("Json error reading nil from the Json reader!");
	elseif (peek == "{") then
		local object = self:ReadObject();
		local objectType = object.__type;
		local customType = json.m_customTypes[objectType];
		
		if (customType) then
			object = customType.OnRead(object);
		else
			object.__type = nil;
		end;
		
		return object;
	elseif (peek == "[") then
		return self:ReadArray();
	elseif (peek == "\"") then
		return self:ReadString();
	elseif ( string.find(peek, "[%+%-%d]") ) then
		return self:ReadNumber();
	elseif (peek == "t") then
		return self:ReadTrue();
	elseif (peek == "f") then
		return self:ReadFalse();
	elseif (peek == "n") then
		return self:ReadNull();
	elseif (peek == "/") then
		self:ReadComment();
		return self:Read();
	end;
end;

-- A function to read true from the Json reader.
function json.ObjectReader:ReadTrue()
	self:TestReservedWord( {"t", "r", "u", "e"} );
	return true;
end;

-- A function to read false from the Json reader.
function json.ObjectReader:ReadFalse()
	self:TestReservedWord( {"f", "a", "l", "s", "e"} );
	return false;
end;

-- A function to read null from the Json reader.
function json.ObjectReader:ReadNull()
	self:TestReservedWord{'n','u','l','l'}
	return nil;
end;

-- A function to test a reserved read within the Json reason.
function json.ObjectReader:TestReservedWord(characters)
	for k, v in ipairs(characters) do
		if (self:Next() ~= v) then
			g_Lua:Print("Json error testing a reserved word from the Json reader!");
			break;
		end;
	end;
end;

-- A function to read a number from the Json reader.
function json.ObjectReader:ReadNumber()
	local result = self:Next();
	local peek = self:Peek();
	
	while ( peek ~= nil and string.find(peek, "[%+%-%d%.eE]") ) do
		result = result..self:Next();
		peek = self:Peek();
	end;
	
	result = tonumber(result);
	
	if (result == nil) then
		g_Lua:Print("Json error reading a number from the Json reader!");
	else
		return result;
	end;
end;

-- A function to read a string from the Json reader.
function json.ObjectReader:ReadString()
	local result = "";
	
	self:Next();
		while (self:Peek() ~= "\"") do
			local character = self:Next();
			
			if (character == "\\") then
				character = self:Next();
				
				if ( self.m_escapes[character] ) then
					character = self.m_escapes[character];
				end;
			end;
			
			result = result..character;
		end;
	self:Next();
	
	local FromUniCode = function(value)
		return string.char( tonumber(value, 16) );
	end;
	
	return string.gsub(result, "u%x%x(%x%x)", FromUniCode);
end;

-- A function to read a comment from the Json reader.
function json.ObjectReader:ReadComment()
	self:Next(); local second = self:Next();
	
	if (second == "/") then
		self:ReadSingleLineComment();
	elseif second == "*" then
		self:ReadBlockComment();
	else
		g_Lua:Print("Json error reading a comment from the Json reader!");
	end;
end;

-- A function to read a block comment from the Json reader.
function json.ObjectReader:ReadBlockComment()
	local bDone = false;
	
	while (not bDone) do
		local character = self:Next();
		
		if (character == "*" and self:Peek() == "/") then
			bDone = true;
        end;
		
		if (not bDone and character == "/" and self:Peek() == "*") then
            g_Lua:Print("Json error reading illegal block comment!");
		end;
	end;
	
	self:Next();
end;

-- A function to read a single line comment from the Json reader.
function json.ObjectReader:ReadSingleLineComment()
	local character = self:Next();
	
	while (character ~= "\r" and character ~= "\n") do
		character = self:Next();
	end;
end;

-- A function to read an array from the Json reader.
function json.ObjectReader:ReadArray()
	local result = {};
	local bDone = false;
	
	self:Next();
		if (self:Peek() == "]") then
			bDone = true;
		end;
		
		while (not bDone) do
			local item = self:Read();
				result[#result+1] = item;
			self:SkipWhiteSpace();
			
			if (self:Peek() == "]") then
				bDone = true;
			end;
			
			if (not bDone) then
				local character = self:Next();
				
				if (character ~= ",") then
					g_Lua:Print("Json error reading an array from the Json reader!");
				end;
			end;
		end;
	self:Next();
	
	return result;
end;

-- A function to read an object.
function json.ObjectReader:ReadObject()
	local result = {};
	local bDone = false;
	
	self:Next();
		if (self:Peek() == "}") then
			bDone = true;
		end;
		
		while (not bDone) do
			local key = self:Read();
			
			if (type(key) ~= "string") then
				g_Lua:Print("Json error reading invalid non-string object from Json reader!");
			end;
			
			self:SkipWhiteSpace();
				local character = self:Next();
				
				if (character ~= ":") then
					g_Lua:Print("Json error reading invalid object value from Json reader!");
				end;
			self:SkipWhiteSpace();
			
			local value = self:Read();
			result[key] = value;
			
			self:SkipWhiteSpace();
			
			if (self:Peek() == "}") then
				bDone = true;
			end;
			
			if (not bDone) then
				character = self:Next();
				
				if (character ~= ",") then
					g_Lua:Print("Error reading invalid object value from Json reader!");
				end;
			end;
		end;
	self:Next();
	
	return result;
end;

-- A function to skip whitespace from the Json reader.
function json.ObjectReader:SkipWhiteSpace()
	local character = self:Peek();
	
	while ( character ~= nil and string.find(character, "[%s/]") ) do
		if (character == "/") then
			self:ReadComment();
		else
			self:Next();
		end;
		
		character = self:Peek();
	end;
end;

-- A function to peek the next character in the Json reader.
function json.ObjectReader:Peek()
	return self.m_reader:Peek();
end;

-- A function to get the next character in the Json reader.
function json.ObjectReader:Next()
	return self.m_reader:Next();
end;

-- A function to get the entire string from the Json reader.
function json.ObjectReader:All()
	return self.m_reader:All();
end;

-- A function to add an object type to Json.
function json.AddType(objectType, OnWrite, OnRead)
	json.m_customTypes[objectType] = {
		OnWrite = OnWrite,
		OnRead = OnRead
	}
end;

-- A function to encode an object to Json.
function json.Encode(object)
	local writer = json.ObjectWriter:New();
		writer:Write(object);
	return writer:ToString();
end;

-- A function to decode Json to an object.
function json.Decode(text)
	local reader = json.ObjectReader:New(text);
	return reader:Read();
end;

-- A function to return null.
function Null()
	return Null;
end;

--[[
	This is a good place to add all new object types to Json.
	The OnWrite callback -MUST- return a table.
--]]

json.AddType("Angle", function(object)
	return { degrees = object:Degrees() };
end, function(object)
	return util.Degrees(object.degrees);
end);

json.AddType("Color", function(object)
	return {r = object.r, g = object.g, b = object.b, a = object.a};
end, function(object)
	return Color(object.r, object.g, object.b, object.a);
end);

json.AddType("Vec2", function(object)
	return {x = object.x, y = object.y};
end, function(object)
	return Vec2(object.x, object.y);
end);