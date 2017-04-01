--百慕 魔法的音杖·夏尔温

local m=37564403
local cm=_G["c"..m]
cm.named_with_prism=true
function cm.initial_effect(c)
	senya.bm(c,c37564403.target,c37564403.activate,false,CATEGORY_DRAW)
end
function c37564403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c37564403.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
		Duel.BreakEffect()
		Duel.DiscardHand(p,aux.TRUE,d,d,REASON_EFFECT+REASON_DISCARD)
	end
end