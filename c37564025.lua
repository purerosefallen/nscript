--Sweet Sweet Magic☆
function c37564025.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,37564025+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c37564025.target)
	e1:SetOperation(c37564025.activate)
	c:RegisterEffect(e1)
end
function c37564025.filter1(c,e,tp)
	return c:IsSetCard(0x770) and c:GetOverlayCount()==0 and c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c37564025.filter3(c)
	return c:IsAbleToChangeControler() and bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL
end
function c37564025.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and c37564025.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c37564025.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
		and Duel.IsExistingTarget(c37564025.filter3,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,c37564025.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37564025,0))
	local g2=Duel.SelectTarget(tp,c37564025.filter3,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g2:GetFirst())
end
function c37564025.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local sc=g:GetNext()
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e)
		or ac:IsImmuneToEffect(e) or not ac:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_XYZ) then
		local og=ac:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(tc,Group.FromCards(ac))
	end
end
