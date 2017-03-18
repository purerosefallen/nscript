--Corrupted fantasY
function c37564235.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37564235+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c37564235.cost)
	e1:SetOperation(c37564235.operation)
	c:RegisterEffect(e1)
end
function c37564235.filter(c)
	return c:IsSetCard(0x772) and c:IsType(TYPE_MONSTER) and c:IsReleasable()
end
function c37564235.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37564235.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c37564235.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function c37564235.operation(e,tp,eg,ep,ev,re,r,rp)
	--
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c37564235.tg)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetOperation(c37564235.droperation)
	Duel.RegisterEffect(e3,tp)
end
function c37564235.tg(e,c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function c37564235.tg2(c)
	return c:GetSummonLocation()==LOCATION_EXTRA and c:IsAbleToDeck()
end
function c37564235.droperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c37564235.tg2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end