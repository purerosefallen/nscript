--3L·mokou
local m=37564827
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
function cm.initial_effect(c)
	Senya.CommonEffect_3L(c,m)
	aux.AddXyzProcedure(c,cm.mfilter,7,2,nil,nil,63)
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,0x1e0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(Senya.DescriptionCost())
	e2:SetTarget(cm.tdtg)
	e2:SetOperation(cm.tdop)
	c:RegisterEffect(e2)
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
	e3:SetCode(m)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(Senya.order_table_new(cm.omit_group_3L))
	c:RegisterEffect(e3)
end
function cm.omit_group_3L(c)
	return c:GetOverlayGroup()
end
function cm.effect_operation_3L(c)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetValue(0x770)
	e3:SetReset(0x1fe1000)
	c:RegisterEffect(e3,true)
	if c:GetFlagEffect(m+1000)==0 then
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(m*16+1)
		e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e2:SetCode(EVENT_TO_GRAVE)
		e2:SetCondition(cm.mkcon)
		e2:SetTarget(cm.mktg)
		e2:SetOperation(cm.mkop)
		c:RegisterEffect(e2,true)
		c:RegisterFlagEffect(m+1000,0,0,0)
	end
	return e3
end
function cm.mfilter(c)
	return Senya.check_set_3L(c)
end
function cm.filter(c)
	return Senya.check_set_3L(c) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ct=63
	for i=1,62 do
		if not e:GetHandler():CheckRemoveOverlayCard(tp,i,REASON_COST) then
			ct=i-1
			break
		end
	end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,e:GetHandler()) and e:GetHandler():IsType(TYPE_XYZ) and ct>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,ct,e:GetHandler())
	local rct=g:GetCount()
	e:GetHandler():RemoveOverlayCard(tp,rct,rct,REASON_COST)
	local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if gg:GetCount()==0 then return end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,gg:GetCount(),0,LOCATION_GRAVE)
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
	local og=c:GetOverlayGroup():Filter(Senya.EffectSourceFilter_3L,nil,e:GetHandler())
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
function cm.ccon(con,cd)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():GetOverlayGroup():IsExists(aux.FilterEqualFunction(Card.GetOriginalCode,cd),1,nil) and e:GetHandler():IsHasEffect(m) then
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
function cm.MokouRebornCondition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsPreviousSetCard(0x770)
end
function cm.cfilter(c,e)
	return not c:IsCode(m) and Senya.EffectSourceFilter_3L(c,e:GetHandler()) and Senya.check_set_3L(c)
end
function cm.MokouRebornTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc~=e:GetHandler() and cm.cfilter(chkc,e) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) and Duel.IsExistingTarget(cm.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.MokouRebornOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,true,true) then return end
	Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)
	c:CompleteProcedure()
	if tc then Senya.GainEffect_3L(c,tc) end
end