
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564615.initial_effect(c)
	senya.negtrap(c,1,37564615,c37564615.cost)
end
function c37564615.filter(c)
	return c:IsHasEffect(37564600) and c:IsAbleToDeckOrExtraAsCost()
end
function c37564615.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37564615.filter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c37564615.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end