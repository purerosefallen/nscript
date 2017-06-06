--3L·MyonMyonMyonMyonMyon
local m=37564843
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
cm.Senya_name_with_myon=5
function cm.initial_effect(c)
	Senya.CommonEffect_3L(c,m)
	aux.AddXyzProcedure(c,cm.mfilter,7,3,cm.xfilter,m*16)
	c:EnableReviveLimit()
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(37564827)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(Senya.order_table_new(cm.omit_group_3L))
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp)
		return Duel.IsExistingMatchingCard(cm.hfilter,tp,LOCATION_HAND,0,1,nil,e:GetHandler())
	end)
	e2:SetOperation(cm.op)
	c:RegisterEffect(e2)
end
function cm.effect_operation_3L(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1,true)
	return e1
end
function cm.omit_group_3L(c)
	return Duel.GetMatchingGroup(Card.IsPublic,c:GetControler(),LOCATION_HAND,0,nil)
end
function cm.mfilter(c)
	return Senya.check_set_3L(c)
end
function cm.xfilter(c)
	return Senya.check_set(c,"myon") and c:IsType(TYPE_FUSION) and c:IsFaceup() and Senya.GetGainedCount_3L(c)>1
end
function cm.hfilter(c,ec)
	return Senya.EffectSourceFilter_3L(c,ec) and c:IsPublic()
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local og=Duel.GetMatchingGroup(cm.hfilter,tp,LOCATION_HAND,0,nil,c)
	og:ForEach(function(tc)  
		local t=Senya.GainEffect_3L(c,tc,false,63)
		if not t then return end
		for i,te in pairs(t) do
			te:SetCondition(cm.ccon(te:GetCondition(),tc:GetOriginalCode()))
			if te:IsHasType(0x7e0) and not tc.single_effect_3L then
				te:SetCost(cm.ccost(te:GetCost(),tc:GetOriginalCode()))
			end
		end
	end)
end
function cm.kfilter(c,cd)
	return c:GetOriginalCode()==cd and c:IsPublic()
end
function cm.ccon(con,cd)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local p=tp or e:GetHandlerPlayer()
		if Duel.IsExistingMatchingCard(cm.kfilter,p,LOCATION_HAND,0,1,nil,cd) and e:GetHandler():IsHasEffect(37564827) then
			return (not con or con(e,tp,eg,ep,ev,re,r,rp))
		else
			Senya.RemoveCertainEffect_3L(e:GetHandler(),cd)
			return false
		end
	end
end
function cm.ccost(costf,cd)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local ctlm=Senya.CheckKoishiCount(c)
		if chk==0 then return c:GetFlagEffect(cd-3000)<ctlm and (not costf or costf(e,tp,eg,ep,ev,re,r,rp,0)) end
		if costf then costf(e,tp,eg,ep,ev,re,r,rp,1) end
		c:RegisterFlagEffect(cd-3000,0x1fe1000+RESET_PHASE+PHASE_END,0,1)
	end
end