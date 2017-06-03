

local m=37564615
local cm=_G["c"..m]
function cm.initial_effect(c)
	Senya.NegateEffectTrap(c,1,37564615,c37564615.cost)
end
function c37564615.filter(c)
	return Senya.check_set_prim(c) and c:IsAbleToDeckOrExtraAsCost()
end
function c37564615.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37564615.filter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c37564615.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end