--3L·mokou
local m=37564827
local cm=_G["c"..m]
function cm.initial_effect(c)
	senya.leff(c,m)
	aux.AddXyzProcedure(c,cm.mfilter,7,2)
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(senya.desccost())
	e2:SetTarget(cm.tdtg)
	e2:SetOperation(cm.tdop)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e)
		return e:GetHandler():GetOverlayGroup():IsExists(senya.lefffilter,1,nil,e:GetHandler())
	end)
	e2:SetOperation(cm.op)
	c:RegisterEffect(e2)
	--special check
	--for removing effect as cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(m)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	c:RegisterEffect(e3)
end
function cm.omit_group_3L(c,tp)
	return c:GetOverlayGroup()
end
function cm.effect_operation_3L(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetReset(RESET_EVENT+0x1fe0000)
	e2:SetTarget(cm.desreptg)
	e2:SetOperation(cm.desrepop)
	c:RegisterEffect(e2,true)
	return e2
end
function cm.mfilter(c)
	return senya.check_set_3L(c)
end
function cm.filter(c)
	return senya.check_set_3L(c) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,e:GetHandler()) and e:GetHandler():IsType(TYPE_XYZ) end
	local ct=63
	for i=1,62 do
		if not e:GetHandler():CheckRemoveOverlayCard(tp,i,REASON_COST) then
			ct=i
			break
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,ct,e:GetHandler())
	local rct=g:GetCount()-1
	if rct>0 then
		e:GetHandler():RemoveOverlayCard(tp,rct,rct,REASON_COST)
	end
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if gg:GetCount()==0 then return end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,1,0,LOCATION_GRAVE)
end
function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 and e:GetHandler():IsRelateToEffect(e) then
		Duel.Overlay(e:GetHandler(),tg)
	end
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup():Filter(senya.lefffilter,nil,e:GetHandler())
	og:ForEach(function(tc)  
		local t=senya.lgeff(c,tc,false,63)
		if not t then return end
		for i,te in pairs(t) do
			te:SetCondition(cm.ccon(te:GetCondition(),tc:GetOriginalCode()))
			if te:IsHasType(0x7e0) and not tc.single_effect_3L then
				te:SetCost(cm.ccost(te:GetCost(),tc:GetOriginalCode()))
			end
		end
	end)
end
function cm.ccon(con,cd)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():GetOverlayGroup():IsExists(aux.FilterEqualFunction(Card.GetOriginalCode,cd),1,nil) and e:GetHandler():IsHasEffect(m) then
			return (not con or con(e,tp,eg,ep,ev,re,r,rp))
		else
			senya.lreseff(e:GetHandler(),cd)
			return false
		end
	end
end
function cm.ccost(costf,cd)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local ctlm=c.custom_ctlm_3L or 1
		if chk==0 then return c:GetFlagEffect(cd-3000)<ctlm and (not costf or costf(e,tp,eg,ep,ev,re,r,rp,0)) end
		if costf then costf(e,tp,eg,ep,ev,re,r,rp,1) end
		c:RegisterFlagEffect(cd-3000,0x1fe1000+RESET_PHASE+PHASE_END,0,1)
	end
end
function cm.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(cm.repfilter,tp,0,LOCATION_ONFIELD,1,c) end
	if Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,cm.repfilter,tp,0,LOCATION_ONFIELD,1,1,c)
		e:SetLabelObject(g:GetFirst())
		Duel.HintSelection(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function cm.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
function cm.repfilter(c)
	return not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end