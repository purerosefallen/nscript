--Nanahira & 3L
local m=37564519
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
cm.Senya_desc_with_nanahira=true
function cm.initial_effect(c)
	Senya.CommonEffect_3L(c,m)
	Senya.Nanahira(c)
	Senya.NegateEffectModule(c,1,m,Senya.SelfRemoveCost,Senya.NanahiraExistingCondition(true),nil,LOCATION_GRAVE,false)
	Senya.NegateEffectModule(c,1,m,Senya.SelfReleaseCost,cm.discon,nil,LOCATION_HAND+LOCATION_MZONE,false)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e5:SetCode(37564800)
	c:RegisterEffect(e5)
end
function cm.effect_operation_3L(c,ctlm)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(ctlm)
	e1:SetCost(Senya.DescriptionCost())
	e1:SetTarget(cm.target1)
	e1:SetOperation(cm.operation1)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1,true)
	return e1
end
--[[cm.reset_operation_3L={
function(e,c)
	local copym=c:GetFlagEffectLabel(m)
	if not copym then return end
	local copyt=Senya.order_table[copym]
	for i,rcode in pairs(copyt) do
		Duel.Hint(HINT_OPSELECTED,c:GetControler(),m*16+2)
		Senya.RemoveCertainEffect_3L(c,rcode)
	end
	c:ResetFlagEffect(m)
end,
}]]
function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg then return false end
	return Duel.IsChainNegatable(ev) and tg:IsExists(cm.f,1,nil,tp)
end
function cm.f(c,tp)
	if c:IsControler(1-tp) or c:IsFacedown() then return false end
	if c:IsCode(37564765) and c:IsLocation(LOCATION_ONFIELD) then return true end
	if Senya.check_set_3L(c) and c:IsLocation(LOCATION_MZONE) then return true end
	return false
end
function cm.cfilter(c,e)
	return not c:IsPublic() and cd~=m and Senya.EffectSourceFilter_3L(c,e:GetHandler()) and Senya.check_set_3L(c)
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_HAND,0,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,cm.cfilter,tp,LOCATION_HAND,0,1,1,nil,e)
	Duel.ConfirmCards(1-tp,g)
	Duel.SetTargetParam(g:GetFirst():GetOriginalCode())
	Duel.ShuffleHand(tp)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local cd=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Senya.GainEffect_3L(c,cd,2)
	if c:GetFlagEffect(m)==0 then
		local tcode=Senya.order_table_new({cd})
		c:RegisterFlagEffect(m,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,0,2,tcode)
	else
		local copyt=Senya.order_table[c:GetFlagEffectLabel(m)]
		table.insert(copyt,cd)
	end
end