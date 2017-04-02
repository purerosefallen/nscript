--3L·死灵的夜樱
local m=37564824
local cm=_G["c"..m]
function cm.initial_effect(c)
	senya.leff(c,m)
	senya.rxyz3(c,cm.xfilter,2)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:GetSummonType()==SUMMON_TYPE_XYZ and c:GetOverlayGroup():IsExists(senya.lefffilter,1,nil,e:GetHandler())
	end)
	e0:SetOperation(cm.skipop)
	c:RegisterEffect(e0)
end
function cm.effect_operation_3L(c)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_SZONE)
	e3:SetTarget(cm.distg)
	e3:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e3,true)
	return e3
end
function cm.distg(e,c)
	return c:IsFacedown()
end
function cm.xfilter(c,xyzcard)
	if not senya.check_set_3L(c) then return false end
	for i=1,4 do
		if c:IsXyzLevel(xyzcard,i) then return true end
	end
	return false
end
function cm.skipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,e:GetHandler():GetOriginalCode())
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local tc=c:GetOverlayGroup():FilterSelect(tp,senya.lefffilter,1,1,nil,e:GetHandler()):GetFirst()
	local descid=1
	local effct=tc.custom_effect_count_3L
	if effct and effct>1 then descid=effct+1 end
	Duel.Hint(HINT_OPSELECTED,1-tp,tc:GetOriginalCode()*16+descid)
	senya.lgeff(c,tc)