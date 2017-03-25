--3L·紧闭的恋之瞳
local m=37564826
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function cm.initial_effect(c)
	senya.lfus(c,m,cm.mfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(m)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
end
cm.custom_ctlm_3L=2
function cm.mfilter(c)
	return senya.check_fusion_set_3L(c) and c:IsFusionType(TYPE_FUSION)
end