--百慕 舞台风暴·约理

local m=37564401
local cm=_G["c"..m]
cm.named_with_prism=true
function cm.initial_effect(c)
	senya.bm(c,c37564401.target,c37564401.activate,false,CATEGORY_TOHAND+CATEGORY_SEARCH)
end
function c37564401.filter(c)
	return senya.bmchkfilter(c) and c:IsAbleToHand() and not c:IsCode(37564401)
end
function c37564401.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c37564401.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c37564401.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c37564401.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end