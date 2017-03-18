--Sawawa-Lake Blizzard
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564217.initial_effect(c)
	senya.sww(c,1,true,false,false)
   local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564217,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37564217)
	e1:SetCondition(senya.swwblex)
	e1:SetCost(senya.swwrmcost(1))
	e1:SetTarget(c37564217.tg)
	e1:SetOperation(c37564217.op)
	c:RegisterEffect(e1)
end
function c37564217.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetOverlayCount(tp,0,1)~=0 end
end
function c37564217.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetOverlayGroup(tp,0,1)
	local val=g:GetCount()*300
	if val~=0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Damage(1-tp,val,REASON_EFFECT)
		if not c:IsFacedown() and c:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(val)
			e1:SetReset(RESET_EVENT+0x1ff0000)
			c:RegisterEffect(e1)
		end  
	end
end
