--忘却之海·Firce777
function c66677789.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2)
	--c:SetUniqueOnField(1,0,66677789)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66677789,2))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCost(c66677789.cost)
	e1:SetCondition(c66677789.condition)
	e1:SetTarget(c66677789.target)
	e1:SetOperation(c66677789.activate)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return bit.band(e:GetHandler():GetPreviousPosition(),POS_FACEUP)~=0
			and bit.band(e:GetHandler():GetPreviousLocation(),LOCATION_ONFIELD)~=0
	end)
	e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local s0=Duel.IsExistingMatchingCard(c66677789.tfilter,tp,LOCATION_GRAVE,0,1,nil,0)
		local s1=Duel.IsExistingMatchingCard(c66677789.tfilter,tp,LOCATION_REMOVED,0,1,nil,1)
		if chk==0 then return s1 or s2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=nil
	if s0 and not s1 then
		op=0
	elseif s1 and not s0 then
		op=1
	elseif s0 and s1 then
		op=Duel.SelectOption(tp,aux.Stringid(66677789,0),aux.Stringid(66677789,1))
	end
	if op then e:SetLabel(op) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
	end)
	e4:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local op=e:GetLabel()
		local g=Group.CreateGroup()
		if op==0 and Duel.IsExistingMatchingCard(c66677789.tfilter,tp,LOCATION_GRAVE,0,1,nil,0) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			g=Duel.SelectMatchingCard(tp,c66677789.tfilter,tp,LOCATION_GRAVE,0,1,2,nil,0)   
		elseif op==1 and Duel.IsExistingMatchingCard(c66677789.tfilter,tp,LOCATION_REMOVED,0,1,nil,1) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			g=Duel.SelectMatchingCard(tp,c66677789.tfilter,tp,LOCATION_REMOVED,0,1,2,nil,1)
		end
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end)   
	c:RegisterEffect(e4)
end
function c66677789.tfilter(c,se)
	if not se then return true end
	if not (c:IsType(TYPE_MONSTER) and c:IsAbleToHand()) then return false end 
	return (c:IsRace(RACE_SEASERPENT) and se==0) or (c:IsFaceup() and se==1)
end
function c66677789.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() and c:IsFaceup()
end
function c66677789.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local exm=c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_FAIRY)
	if chk==0 then return (exm and c:GetFlagEffect(66677789)<2 and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsExistingMatchingCard(c66677789.costfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,2,nil)) or c:GetFlagEffect(66677789)==0 end
	if c:GetFlagEffect(66677789)==0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
		local g=Duel.SelectMatchingCard(tp,c66677789.costfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,2,2,nil)
		Duel.SendtoDeck(g,nil,2,REASON_COST)
	end
	c:RegisterFlagEffect(66677789,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,1)
end
function c66677789.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function c66677789.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66677789.cfilter,1,nil,1-tp)
end
function c66677789.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
function c66677789.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	if c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_SEASERPENT) and e:GetLabel()==1 and c:IsType(TYPE_XYZ) then
		Duel.Overlay(c,sg)
	else
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
