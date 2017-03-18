--Sawawa-Seventh Doll
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564214.initial_effect(c)
senya.sww(c,2,true,false,false)
	--move
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564214,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2,375642141)
	e1:SetCondition(c37564214.seqcon)
	e1:SetCost(c37564214.seqcost)
	e1:SetOperation(c37564214.seqop)
	c:RegisterEffect(e1)
   --hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37564214,2))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,375642142)
	e2:SetCondition(senya.swwblex)
	e2:SetCost(c37564214.cost)
	e2:SetTarget(c37564214.tg)
	e2:SetOperation(c37564214.op)
	c:RegisterEffect(e2)
end
function c37564214.seqcon(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
function c37564214.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c37564214.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	local seq=c:GetSequence()
	if (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1)) then
		local flag=0
		if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=bit.bor(flag,bit.lshift(0x1,seq-1)) end
		if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=bit.bor(flag,bit.lshift(0x1,seq+1)) end
		flag=bit.bxor(flag,0xff)
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		Duel.MoveSequence(c,nseq)
	end
end


function c37564214.costfilter(c)
	return c:IsHasEffect(37564299) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c37564214.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37564214.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c37564214.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c37564214.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
function c37564214.filter(c,seq)
	return c:GetSequence()==seq and c:IsAbleToDeck()
end
function c37564214.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37564214.filter,tp,0,LOCATION_ONFIELD,1,nil,4-e:GetHandler():GetSequence()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RHAND)
	local g=Duel.GetMatchingGroup(c37564214.filter,tp,0,LOCATION_ONFIELD,nil,4-e:GetHandler():GetSequence())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c37564214.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c37564214.filter,tp,0,LOCATION_ONFIELD,nil,4-e:GetHandler():GetSequence())
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end