--Sawawa-Cosmic Drive

local m=37564208
local cm=_G["c"..m]
cm.named_with_sawawa=true
function cm.initial_effect(c)
	senya.sww(c,1,true,false,false)
   local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564208,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37564208)
	e1:SetCondition(senya.swwblex)
	e1:SetTarget(c37564208.tg)
	e1:SetCost(senya.swwrmcost(1))
	e1:SetOperation(c37564208.op)
	c:RegisterEffect(e1)
end
function c37564208.filter(c)
	return c:IsFaceup() and senya.check_set_sawawa(c)
end
function c37564208.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37564208.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c37564208.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c37564208.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c37564208.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetValue(c37564208.efilter)
		e3:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function c37564208.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
