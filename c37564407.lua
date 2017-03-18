--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564407.initial_effect(c)
	senya.bm(c,c37564407.target,c37564407.operation,true,CATEGORY_TOHAND)
end
function c37564407.filter(c)
	return senya.bmchkfilter(c) and not c:IsCode(37564407) and c:IsAbleToHand()
end
function c37564407.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37564407.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c37564407.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c37564407.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c37564407.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end