--百慕 全力偶像·萨妮娅
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564410.initial_effect(c)
	senya.bm(c,c37564410.target,c37564410.operation,true)
end
function c37564410.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(senya.bmchkfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
function c37564410.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(37564410,0))
	local g=Duel.SelectMatchingCard(tp,senya.bmchkfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end
