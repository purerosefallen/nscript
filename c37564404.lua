--百慕 沉默的歌姬·伊丝卡
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564404.initial_effect(c)
	senya.bm(c,c37564404.target,c37564404.activate,true,CATEGORY_SPECIAL_SUMMON)
end
function c37564404.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and senya.bmchkfilter(c)
end
function c37564404.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c37564404.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c37564404.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c37564404.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c37564404.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end