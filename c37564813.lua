--妖隐 -BANAMI & 3L Remix-
local m=37564813
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
cm.Senya_name_with_remix=true
function cm.initial_effect(c)
	Senya.CommonEffect_3L(c,m)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	e3:SetCondition(function(e)
		return not e:GetHandler():IsOnField()
	end)
	c:RegisterEffect(e3)
end
function cm.effect_operation_3L(c,ctlm)
	local e=Senya.NegateEffectModule(c,ctlm)
	e:SetDescription(m*16+1)
	e:SetReset(RESET_EVENT+0x1fe0000)
	e:SetCost(Senya.DescriptionCost())
	c:RegisterEffect(e,true)
	return e
end