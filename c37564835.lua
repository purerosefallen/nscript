--3L·春色小径
local m=37564835
local cm=_G["c"..m]
--
function cm.initial_effect(c)
	senya.leff(c,m)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCountLimit(1,m)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(senya.delay)
	e2:SetCost(cm.discost)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(cm.target)
	e2:SetOperation(senya.drawop)
	c:RegisterEffect(e2)
end
function cm.effect_operation_3L(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabel(senya.order_table_new({}))
	e2:SetOperation(cm.op)
	e2:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e2,true)
	return e2
end
cm.reset_operation_3L={
function(e,c)
	e:SetOperation(aux.NULL)
	local copyt=senya.order_table[e:GetLabel()]
	for tc,cid in pairs(copyt) do
		if tc and cid then
			c:ResetEffect(cid,RESET_COPY)
		end
	end
end,
}
function cm.copyfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsType(TYPE_TRAPMONSTER)
end
function cm.val(c)
	if c:IsType(TYPE_XYZ) then
		return c:GetOriginalRank()
	else
		return c:GetOriginalLevel()
	end
end
function cm.gfilter(c,g)
	if not g then return true end
	return not g:IsContains(c)
end
function cm.gfilter1(c,g)
	if not g then return true end
	return not g:IsExists(cm.gfilter2,1,nil,c:GetOriginalCode())
end
function cm.gfilter2(c,code)
	return c:GetOriginalCode()==code
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local copyt=senya.order_table[e:GetLabel()]
	local exg=Group.CreateGroup()
	for tc,cid in pairs(copyt) do
		if tc and cid then exg:AddCard(tc) end
	end
	local g=Duel.GetMatchingGroup(cm.copyfilter,tp,0,LOCATION_MZONE,nil)
	local maxg=g:GetMaxGroup(cm.val) or Group.CreateGroup()
	local dg=exg:Filter(cm.gfilter,nil,maxg)
	dg:ForEach(function(tc)  
		c:ResetEffect(copyt[tc],RESET_COPY)
		exg:RemoveCard(tc)
		copyt[tc]=nil
	end)
	local cg=maxg:Filter(cm.gfilter1,nil,exg)
	cg:ForEach(function(tc)  
		copyt[tc]=senya.CopyEffectExtraCount(c,c.custom_ctlm_3L,tc:GetOriginalCode(),RESET_EVENT+0x1fe0000,1)
		exg:AddCard(tc)
	end)
end
function cm.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and senya.check_set_3L(c)
end
function cm.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and 
		Duel.IsExistingMatchingCard(cm.costfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST)
end
function cm.cfilter(c,tp)
	local ty=c:GetSummonType()
	return c:GetSummonPlayer()==1-tp and (bit.band(ty,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or bit.band(ty,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO or bit.band(ty,SUMMON_TYPE_XYZ)==SUMMON_TYPE_XYZ) and c:GetMaterialCount()>0
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(cm.cfilter,nil,tp)
	local ct=1
	g:ForEach(function(c)
		ct=ct+c:GetMaterialCount()
	end)
	if chk==0 then return g:GetCount()>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end