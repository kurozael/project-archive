// Meta table adjustments

local Meta = FindMetaTable("Player")

// Get entity

function Meta:GetControllingEntity()
	return self:GetNetworkedEntity("GetControllingEntity")
end