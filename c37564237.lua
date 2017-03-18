--さわわ-幻桜
local m=37564237
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function cm.initial_effect(c)
	senya.sww(c,2,true,false,false)
	senya.neg(c,1,m,senya.swwrmcost(2),senya.swwblex)
end