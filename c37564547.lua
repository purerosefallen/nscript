--Nanahira OverDrive
local m=37564547
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
cm.pendulum_level=7
function cm.initial_effect(c)
	senya.nnhrexp(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564765,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.syncon)
	e1:SetTarget(cm.syntg)
	e1:SetOperation(cm.synop)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCost(senya.serlcost)
	e1:SetTarget(cm.hdtg)
	e1:SetOperation(cm.hdop)
	c:RegisterEffect(e1)
end
function cm.matfilter1(c,syncard)
	if c:IsLocation(LOCATION_MZONE) then
		if not c:IsType(TYPE_TUNER) or not c:IsCanBeSynchroMaterial(syncard) then return false end
	else
		if not c:IsType(TYPE_PENDULUM) or bit.band(c:GetOriginalType(),TYPE_TUNER)==0 or not c:IsCode(37564765) then return false end
	end
	return c:IsFaceup() and Duel.IsExistingMatchingCard(cm.matfilter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,syncard)
end
function cm.matfilter2(c,syncard)
	if c:IsFacedown() or not c:IsType(TYPE_PENDULUM) then return false end
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsNotTuner() and c:IsRace(RACE_FAIRY) and c:IsCanBeSynchroMaterial(syncard)
	else
		return bit.band(c:GetOriginalRace(),RACE_FAIRY)~=0 and bit.band(c:GetOriginalType(),TYPE_TUNER)==0 and c:IsCode(37564765)
	end
end
function cm.val(c,sc)
	if c:IsLocation(LOCATION_SZONE) and c:GetSequence()>5 then
		return c:GetOriginalLevel()
	else
		return c:GetSynchroLevel(sc)
	end
end
function cm.synfilter(c,syncard,lv,g2,minc,ft,tp)
	local tlv=cm.val(c,syncard)
	if lv-tlv<=0 then return false end
	local g=g2:Clone()
	g:RemoveCard(c)
	if ft>0 or (c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)) then
		return g:CheckWithSumEqual(cm.val,lv-tlv,minc-1,63,syncard)
	else
		return g:IsExists(cm.ffilter,1,nil,syncard,lv-tlv,g,minc,tp)
	end
end
function cm.ffilter(c,syncard,rlv,g,minc,tp)
	if c:IsControler(1-tp) or not c:IsLocation(LOCATION_MZONE) then return false end
	Duel.SetSelectedCard(c)
	return g:CheckWithSumEqual(cm.val,rlv,minc-2,63,syncard)
end
function cm.syncon(e,c,tuner,mg)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local minc=math.max(-ft,2)
	local g1=nil
	local g2=nil
	if mg then
		g1=mg:Filter(cm.matfilter1,nil,c)
		g2=mg:Filter(cm.matfilter2,nil,c)
	else
		g1=Duel.GetMatchingGroup(cm.matfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c)
		g2=Duel.GetMatchingGroup(cm.matfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c)
	end
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_SMATERIAL)
	local lv=c:GetLevel()
	if tuner then
		return cm.synfilter(tuner,c,lv,g2,minc,ft,tp)
	end
	if not pe then
		return g1:IsExists(cm.synfilter,1,nil,c,lv,g2,minc,ft,tp)
	else
		return cm.synfilter(pe:GetOwner(),c,lv,g2,minc,ft,tp)
	end
end
function cm.syntg(e,tp,eg,ep,ev,re,r,rp,chk,c,tuner,mg)
	local g=Group.CreateGroup()
	local g1=nil
	local g2=nil
	if mg then
		g1=mg:Filter(cm.matfilter1,nil,c)
		g2=mg:Filter(cm.matfilter2,nil,c)
	else
		g1=Duel.GetMatchingGroup(cm.matfilter1,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c)
		g2=Duel.GetMatchingGroup(cm.matfilter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c)
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local minc=math.max(-ft,2)
	local pe=Duel.IsPlayerAffectedByEffect(tp,EFFECT_MUST_BE_SMATERIAL)
	local lv=c:GetLevel()
	if tuner then
		g:AddCard(tuner)
		g2:RemoveCard(tuner)
		local lv1=cm.val(tuner,c)
		if ft<=0 and (tuner:IsControler(1-tp) or not tuner:IsLocation(LOCATION_MZONE)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
			local mf=g2:FilterSelect(tp,cm.ffilter,1,1,nil,c,lv-lv1,g2,minc,tp)
			Duel.SetSelectedCard(mf)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local m2=g2:SelectWithSumEqual(tp,cm.val,lv-lv1,minc-1,63,c)
		g:Merge(m2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
		local tuner=nil
		if not pe then
			local t1=g1:FilterSelect(tp,cm.synfilter,1,1,nil,c,lv,g2,minc,ft,tp)
			tuner=t1:GetFirst()
		else
			tuner=pe:GetOwner()
			Group.FromCards(tuner):Select(tp,1,1,nil)
		end
		g:AddCard(tuner)
		g2:RemoveCard(tuner)
		local lv1=cm.val(tuner,c)
		if ft<=0 and (tuner:IsControler(1-tp) or not tuner:IsLocation(LOCATION_MZONE)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
			local mf=g2:FilterSelect(tp,cm.ffilter,1,1,nil,c,lv-lv1,g2,minc,tp)
			Duel.SetSelectedCard(mf)
			g:Merge(mf)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
			local m2=g2:SelectWithSumEqual(tp,cm.val,lv-lv1,minc-2,63,c)
			g:Merge(m2)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
			local m2=g2:SelectWithSumEqual(tp,cm.val,lv-lv1,minc-1,63,c)
			g:Merge(m2)
		end
	end
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
function cm.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function cm.hdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND,nil)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end