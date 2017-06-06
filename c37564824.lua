--3L·死灵的夜樱
local m=37564824
local cm=_G["c"..m]

function cm.initial_effect(c)
	Senya.CommonEffect_3L(c,m)
	Senya.AddXyzProcedureCustom(c,cm.xfilter,nil,2,63)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e)
		return e:GetHandler():GetOverlayGroup():IsExists(Senya.EffectSourceFilter_3L,1,nil,e:GetHandler())
	end)
	e2:SetOperation(cm.op)
	c:RegisterEffect(e2)
	--special check
	--for removing effect as cost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(37564827)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(Senya.order_table_new(cm.omit_group_3L))
	c:RegisterEffect(e3)
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
function cm.omit_group_3L(c)
	return c:GetOverlayGroup()
end
function cm.distg(e,c)
	return c:IsFacedown()
end
function cm.xfilter(c,xyzcard)
	if not Senya.check_set_3L(c) then return false end
	for i=1,4 do
		if c:IsXyzLevel(xyzcard,i) then return true end
	end
	return false
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup():Filter(Senya.EffectSourceFilter_3L,nil,e:GetHandler())
	og:ForEach(function(tc)  
		local t=Senya.GainEffect_3L(c,tc,false,63)
		if not t then return end
		for i,te in pairs(t) do
			te:SetCondition(cm.ccon(te:GetCondition(),tc:GetOriginalCode()))
			if te:IsHasType(0x7e0) then
				te:SetCost(cm.ccost(te:GetCost(),tc:GetOriginalCode()),tc.single_effect_3L)
			end
		end
	end)
end
function cm.ccon(con,cd)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if (e:GetHandler():GetOverlayGroup():IsExists(aux.FilterEqualFunction(Card.GetOriginalCode,cd),1,nil) and e:GetHandler():IsHasEffect(37564827)) then
			return (not con or con(e,tp,eg,ep,ev,re,r,rp))
		else
			Senya.RemoveCertainEffect_3L(e:GetHandler(),cd)
			return false
		end
	end
end
function cm.ccost(costf,cd,chks)
	if chks then
		return function(e,tp,eg,ep,ev,re,r,rp,chk)
			local c=e:GetHandler()
			if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and (not costf or costf(e,tp,eg,ep,ev,re,r,rp,0)) end
			if costf then costf(e,tp,eg,ep,ev,re,r,rp,1) end
			e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		end
	else
		return function(e,tp,eg,ep,ev,re,r,rp,chk)
			local c=e:GetHandler()
			local ctlm=Senya.CheckKoishiCount(c)
			if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and c:GetFlagEffect(cd-3000)<ctlm and (not costf or costf(e,tp,eg,ep,ev,re,r,rp,0)) end
			if costf then costf(e,tp,eg,ep,ev,re,r,rp,1) end
			c:RemoveOverlayCard(tp,1,1,REASON_COST)
			c:RegisterFlagEffect(cd-3000,0x1fe1000+RESET_PHASE+PHASE_END,0,1)
		end
	end
end