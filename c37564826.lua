--3L·紧闭的恋之瞳
local m=37564826
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function cm.initial_effect(c)
	senya.lfus(c,m,Card.IsFusionType,TYPE_FUSION)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(m)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
end
cm.custom_ctlm_3L=2