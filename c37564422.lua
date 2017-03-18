--百慕 甜蜜乐园·玛妮娅
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564422.initial_effect(c)
	senya.bm(c,c37564422.sptg,c37564422.spop,false,CATEGORY_SPECIAL_SUMMON)
end
function c37564422.filter(c,e,tp)
	return senya.bmchkfilter(c) and not c:IsCode(37564422) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetLevel()==3 and Duel.GetFlagEffect(tp,c:GetCode())==0
end
function c37564422.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c37564422.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c37564422.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c37564422.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:RegisterFlagEffect(37564499,RESET_EVENT+0x1fe0000,0,1)
		Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		Duel.SpecialSummonComplete()
	end
end