--大气元素·希布利兹
function c37564036.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,63)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564036,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,37564036)
	e1:SetCondition(c37564036.condition)
	e1:SetCost(c37564036.cost)
	e1:SetTarget(c37564036.target)
	e1:SetOperation(c37564036.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37564036,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,37564036)
	e2:SetCondition(c37564036.condition1)
	e2:SetCost(c37564036.cost)
	e2:SetTarget(c37564036.target)
	e2:SetOperation(c37564036.operation)
	c:RegisterEffect(e2)
end
function c37564036.condition(e,tp,eg,ep,ev,re,r,rp)
	local o=e:GetHandler():GetOverlayCount()
	return o<3
end
function c37564036.condition1(e,tp,eg,ep,ev,re,r,rp)
	local o=e:GetHandler():GetOverlayCount()
	return o>2
end
function c37564036.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function c37564036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37564036.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c37564036.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c37564036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
end
function c37564036.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,532)
	local sg=Duel.SelectMatchingCard(tp,Card.CheckRemoveOverlayCard,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,1,REASON_EFFECT)
	if sg:GetCount()==0 then return end
	Duel.HintSelection(sg)
	sg:GetFirst():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end