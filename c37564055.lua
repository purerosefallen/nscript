--元灵的祈愿·梅娅
local m=37564055
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
cm.Senya_name_with_elem=true
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.syncon)
	e1:SetTarget(cm.syntg)
	e1:SetOperation(cm.synop)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO and e:GetLabel()==1
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		c:RegisterFlagEffect(m-1000,RESET_EVENT+0x1fe0000,0,1)
	end)
	c:RegisterEffect(e2)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(cm.valcheck)
	e0:SetLabelObject(e2)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(cm.regcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(cm.adcon)
	e3:SetTarget(cm.adtg)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_SET_ATTACK_FINAL)
	e5:SetValue(0)
	c:RegisterEffect(e5)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,0x1c0)
	e1:SetCountLimit(1)
	e1:SetTarget(cm.target1)
	e1:SetOperation(cm.operation1)
	c:RegisterEffect(e1)
end
function cm.regcon(e)
	return e:GetHandler():GetFlagEffect(m-1000)>0
end
function cm.adcon(e)
	local c=e:GetHandler()
	return c:GetBattleTarget() and cm.regcon(e)
		and (Duel.GetCurrentPhase()==PHASE_DAMAGE or Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL)
end
function cm.adtg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
function cm.filter(c)
	return c:IsAbleToDeck()
end
function cm.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and cm.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cm.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cm.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end
function cm.matfilter1(c,syncard)
	if c:IsFaceup() and c:IsType(TYPE_XYZ) then return true end 
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsCanBeSynchroMaterial(syncard)
end
function cm.matfilter2(c,syncard)
	return c:IsFaceup() and c:IsNotTuner() and Senya.check_set_elem(c) and c:IsCanBeSynchroMaterial(syncard)
end
function cm.val(c,syncard)
	if c:IsType(TYPE_XYZ) then
		return c:GetRank()
	else
		return c:GetSynchroLevel(syncard)
	end
end
function cm.synfilter(c,syncard,lv,g2,minc,maxc,tp)
	return Senya.CheckGroup(g2,cm.goal,Group.FromCards(c),minc,maxc,tp,lv,syncard)
end
function cm.goal(g,tp,lv,syncard)
	if Duel.GetLocationCountFromEx(tp,tp,g,syncard)<=0 then return false end
	local ct=g:GetCount()
	return g:CheckWithSumEqual(cm.val,lv,ct,ct,syncard)
end
function cm.syncon(e,c,tuner,mg)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local minc=3
	local maxc=c:GetLevel()
	local g1=nil
	local g2=nil
	if mg then
		g1=mg:Filter(cm.matfilter1,nil,c)
		g2=mg:Filter(cm.matfilter2,nil,c)
	else
		g1=Duel.GetMatchingGroup(cm.matfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
		g2=Duel.GetMatchingGroup(cm.matfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
	end
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_SMATERIAL)
	local lv=c:GetLevel()
	local sg=nil
	if tuner then
		return cm.synfilter(tuner,c,lv,g2,minc,maxc,tp)
	end
	if not pe then
		return g1:IsExists(cm.synfilter,1,nil,c,lv,g2,minc,maxc,tp)
	else
		return cm.synfilter(pe:GetOwner(),c,lv,g2,minc,maxc,tp)
	end
end
function cm.syntg(e,tp,eg,ep,ev,re,r,rp,chk,c,tuner,mg)
	local g1=nil
	local g2=nil
	local minc=3
	local maxc=c:GetLevel()
	if mg then
		g1=mg:Filter(cm.matfilter1,nil,c)
		g2=mg:Filter(cm.matfilter2,nil,c)
	else
		g1=Duel.GetMatchingGroup(cm.matfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
		g2=Duel.GetMatchingGroup(cm.matfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
	end
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_SMATERIAL)
	local lv=c:GetLevel()
	local tuc=nil
	if tuner then
		tuner=tuc
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		if not pe then
			local t1=g1:FilterSelect(tp,cm.synfilter,1,1,nil,c,lv,g2,minc,maxc,tp)
			tuc=t1:GetFirst()
		else
			tuc=pe:GetOwner()
			Group.FromCards(tuc):Select(tp,1,1,nil)
		end
	end
	tuc:RegisterFlagEffect(m,RESET_EVENT+0x1fe0000,0,1)
	local g=Senya.SelectGroup(tp,HINTMSG_SMATERIAL,g2,cm.goal,Group.FromCards(tuc),minc,maxc,tp,lv,c)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else return false end
end
function cm.synop(e,tp,eg,ep,ev,re,r,rp,c,tuner,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
	g:DeleteGroup()
end
function cm.mfilter(c)
	return c:IsType(TYPE_XYZ) and Senya.check_set_elem(c)
		and (c:IsType(TYPE_TUNER) or c:GetFlagEffect(m)~=0)
end
function cm.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(cm.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end