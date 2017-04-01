--Sawawa-Mayohiga Spurt

local m=37564209
local cm=_G["c"..m]
cm.named_with_sawawa=true
function cm.initial_effect(c)
	senya.sww(c,1,true,false,false)
   local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564209,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37564209)
	e1:SetCondition(senya.swwblex)
	e1:SetCost(senya.swwrmcost(1))
	e1:SetTarget(c37564209.tg)
	e1:SetOperation(c37564209.op)
	c:RegisterEffect(e1)
end
function c37564209.lvfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_XYZ)
end
function c37564209.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37564209.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c37564209.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c37564209.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c37564209.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-3)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
