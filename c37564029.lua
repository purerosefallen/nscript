--三千世界
function c37564029.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,4,nil,nil,5)
	--val
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c37564029.atkval)
	c:RegisterEffect(e2)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetValue(c37564029.atkval)
	c:RegisterEffect(e8)
	--exeffects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(c37564029.xcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	e3:SetCondition(c37564029.xcon)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(c37564029.xcon)
	e4:SetTarget(c37564029.distg)
	c:RegisterEffect(e4)
	local e88=Effect.CreateEffect(c)
	e88:SetDescription(aux.Stringid(37564029,0))
	e88:SetCategory(CATEGORY_REMOVE)
	e88:SetType(EFFECT_TYPE_QUICK_O)
	e88:SetCode(EVENT_FREE_CHAIN)
	e88:SetRange(LOCATION_MZONE)
	e88:SetHintTiming(0,0x1e0)
	e88:SetCountLimit(1)
	e88:SetCost(c37564029.cost)
	e88:SetTarget(c37564029.tgtg)
	e88:SetOperation(c37564029.tgop)
	c:RegisterEffect(e8)
end
function c37564029.atkval(e,c)
	return c:GetOverlayCount()*1000
end
function c37564029.xcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(c37564029.xfilter,1,nil,4) and e:GetHandler():GetOverlayGroup():IsExists(c37564029.xfilter,1,nil,5)
end
function c37564029.xfilter(c,rr)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x770) and c:GetRank()==rr
end
function c37564029.distg(e,c)
	return c:GetSummonLocation()==LOCATION_EXTRA
end
function c37564029.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c37564029.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c37564029.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end