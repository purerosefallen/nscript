--妖隐 -BANAMI & 3L Remix-
local m=37564813
local cm=_G["c"..m]

cm.Senya_name_with_remix=true
function cm.initial_effect(c)
	Senya.CommonEffect_3L(c,m,function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
end
function cm.effect_operation_3L(c,ctlm)
	local e=Senya.NegateEffectModule(c,ctlm)
	e:SetDescription(m*16+1)
	e:SetReset(RESET_EVENT+0x1fe0000)
	e:SetCost(Senya.DescriptionCost())
	local con=e:GetCondition()
	e:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and con(e,tp,eg,ep,ev,re,r,rp)
	end)
	c:RegisterEffect(e,true)
	return e
end