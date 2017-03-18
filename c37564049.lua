--竹之花 -SDVX Remix-
local m=37564049
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function cm.initial_effect(c)
	senya.setreg(c,m,37564876)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,6,4,nil,nil,5)
	senya.cneg(c,cm.discon,cm.discost,nil,m*16,true,nil)
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(m,0))
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetCondition(cm.xcon)
		e3:SetTarget(cm.mttg)
		e3:SetOperation(cm.mtop)
		c:RegisterEffect(e3)
end
function cm.xcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(cm.xfilter,1,nil,4) and e:GetHandler():GetOverlayGroup():IsExists(cm.xfilter,1,nil,5)
end
function cm.xfilter(c,rr)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x770) and c:GetRank()==rr
end
function cm.mtfilter(c)
	return true
end
function cm.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.mtfilter,tp,LOCATION_HAND,0,1,nil) end
end
function cm.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,cm.mtfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end
function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp~=tp and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and cm.xcon(e,tp,eg,ep,ev,re,r,rp)
end
function cm.discost(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end