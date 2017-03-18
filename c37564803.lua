--3L·Sweets Magic
local m=37564803
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
cm.fusion_att_3L=ATTRIBUTE_FIRE
function cm.initial_effect(c)
	senya.lfus(c,m)
end
