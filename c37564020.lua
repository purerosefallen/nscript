--White Rose Insanity
function c37564020.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,37564020+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		e:SetLabel(1)
	end)
	e1:SetTarget(c37564020.target)
	e1:SetOperation(c37564020.activate)
	c:RegisterEffect(e1)
end

function c37564020.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x770) and c:GetOverlayCount()>0
	and c:IsAbleToExtra() and Duel.IsExistingMatchingCard(c37564020.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode(),c:GetRank())
end
function c37564020.spfilter2(c,e,tp,code,rk)
	return c:IsSetCard(0x770) and c:GetRank()==rk and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c37564020.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37564020.thfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c37564020.thfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,c37564020.thfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c37564020.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c37564020.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetCode(),tc:GetRank())
		local mg=sg:GetFirst()
		  if sg:GetCount()>0 and Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if e:GetLabel()==1 then
				e:SetLabel(0)
				if e:GetHandler():IsRelateToEffect(e) then
					e:GetHandler():CancelToGrave()
					Duel.Overlay(mg,Group.FromCards(e:GetHandler()))
				end
			end
		  Duel.SendtoDeck(tc,nil,2,REASON_EFFECT) 
		  end
	end
end