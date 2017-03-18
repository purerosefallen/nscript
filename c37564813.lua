--妖隐 -BANAMI & 3L Remix-
local m=37564813
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function cm.initial_effect(c)
	senya.setreg(c,m,37564876)
	senya.leff(c,m)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(1)
	e3:SetCondition(function(e)
		return not e:GetHandler():IsOnField()
	end)
	c:RegisterEffect(e3)
end
function cm.effect_operation_3L(c,ctlm)
	local e=senya.neg(c,ctlm)
	e:SetDescription(m*16+1)
	e:SetReset(RESET_EVENT+0x1fe0000)
	e:SetCost(senya.desccost())
	c:RegisterEffect(e,true)
	return e
end