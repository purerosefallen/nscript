--3L·MyonMyonMyon
local m=37564842
local cm=_G["c"..m]
cm.named_with_myon=true
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	senya.leff(c,m)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(cm.lfuscon)
	e1:SetOperation(cm.lfusop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c)
		return not senya.check_set_3L(c)
	end)
	c:RegisterEffect(e2)
end
function cm.effect_operation_3L(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1,true)
	return e1
end
function cm.lfusfilter(c)
	return senya.check_fusion_set_3L(c) and c:IsOnField()
end
function cm.mfilter(c)
	return c:IsFusionType(TYPE_EFFECT) and not c:IsHasEffect(6205579)
end
function cm.filter_extra(c,ec,chkfnf)
	if bit.band(chkfnf,0x100)~=0 then return false end
	return c:IsFaceup() and c:IsCanBeFusionMaterial(ec)
end
function cm.lfuscon(e,g,gc,chkfnf)
	if g==nil then return true end
	local f1=cm.lfusfilter
	local f2=cm.mfilter
	local chkf=bit.band(chkfnf,0xff)
	local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local tp=e:GetHandlerPlayer()
	local exg=Duel.GetMatchingGroup(cm.filter_extra,tp,0,LOCATION_MZONE,nil,e:GetHandler(),chkfnf)
	mg:Merge(exg)
	if gc then
		if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
		return senya.lfuscheck_gc(mg,gc,f1,f2,chkf) or senya.filter_sayuri_3L(gc,e:GetHandler(),chkfnf)
	end
	return senya.lfuscheck(mg,f1,f2,chkf) or mg:IsExists(senya.filter_sayuri_3L,1,nil,e:GetHandler(),chkfnf)
end
function cm.lfusop(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
	local f1=cm.lfusfilter
	local f2=cm.mfilter
	local chkf=bit.band(chkfnf,0xff)
	local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local exg=Duel.GetMatchingGroup(cm.filter_extra,tp,0,LOCATION_MZONE,nil,e:GetHandler(),chkfnf)
	g:Merge(exg)
	if gc then
		if senya.filter_sayuri_3L(gc,e:GetHandler(),chkfnf) and (not senya.lfuscheck_gc(g,gc,f1,f2,chkf) or Duel.SelectYesNo(tp,37564914*16)) then
			Duel.SetFusionMaterial(Group.FromCards(gc))
			return
		end
		local fs=(chkf==PLAYER_NONE or aux.FConditionCheckF(gc,chkf))
		local sg=Group.CreateGroup()
		if f1(gc) then sg:Merge(g:Filter(f2,gc)) end
		if f2(gc) then sg:Merge(g:Filter(f1,gc)) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=sg:FilterSelect(tp,senya.lchkffilter,1,1,nil,nil,chkf,fs)
		Duel.SetFusionMaterial(g1)
		return
	end
	if g:IsExists(senya.filter_sayuri_3L,1,nil,e:GetHandler(),chkfnf) and (not senya.lfuscheck(g,f1,f2,chkf) or Duel.SelectYesNo(tp,37564914*16)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=g:FilterSelect(tp,senya.filter_sayuri_3L,1,1,nil,e:GetHandler(),chkfnf)
		Duel.SetFusionMaterial(g1)
		return
	end
	local sg=g:Filter(aux.FConditionFilterF2c,nil,f1,f2)
	local g1=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	if chkf~=PLAYER_NONE then
		g1=sg:FilterSelect(tp,aux.FConditionCheckF,1,1,nil,chkf)
	else g1=sg:Select(tp,1,1,nil) end
	local tc1=g1:GetFirst()
	sg:RemoveCard(tc1)
	local b1=f1(tc1)
	local b2=f2(tc1)
	if b1 and not b2 then sg:Remove(aux.FConditionFilterF2r,nil,f1,f2) end
	if b2 and not b1 then sg:Remove(aux.FConditionFilterF2r,nil,f2,f1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g2=sg:Select(tp,1,1,nil)
	g1:Merge(g2)
	Duel.SetFusionMaterial(g1)
end