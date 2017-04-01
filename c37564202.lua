--Sawawa-High Speed Cucumber

local m=37564202
local cm=_G["c"..m]
cm.named_with_sawawa=true
function cm.initial_effect(c)
senya.sww(c,2,true,true,false)
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564202,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37564202)
	e1:SetCondition(senya.swwblex)
	e1:SetTarget(c37564202.rmtg)
	e1:SetOperation(c37564202.rmop)
	c:RegisterEffect(e1)
end
function c37564202.filter1(c)
	return c:IsType(TYPE_TUNER) and c:IsFaceup() and c:IsAbleToRemove()
end
function c37564202.filter2(c)
	return c:IsNotTuner() and c:IsFaceup() and c:IsAbleToRemove()
end
function c37564202.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c37564202.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(c37564202.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,c37564202.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local sc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,c37564202.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,sc)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end
function c37564202.rmop(e,tp,eg,ep,ev,re,r,rp)
 local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
 local g=ac:Filter(Card.IsRelateToEffect,nil,e)
  if g:GetCount()>0 then
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local og=Duel.GetOperatedGroup()
		og:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(og)
		e1:SetCountLimit(1)
		e1:SetOperation(c37564202.retop)
		Duel.RegisterEffect(e1,tp)
		local dc=og:FilterCount(Card.IsType,nil,TYPE_SYNCHRO)
		if dc and dc>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,dc,REASON_EFFECT)
		end
	end
 end
end
function c37564202.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tc=g:GetFirst()
	while tc do
		Duel.ReturnToField(tc)
		tc=g:GetNext()
	end
end