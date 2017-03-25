--Lucky 7
local m=37564548
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
cm.pendulum_level=7
cm.desc_with_nanahira=true
function cm.initial_effect(c)
	senya.nnhrexp(c)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.xyzcon)
	e2:SetOperation(cm.xyzop)
	e2:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e2)
	local e3=senya.neg(c,1,nil,nil,cm.condition,cm.rop)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsType(TYPE_PENDULUM) end
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	end)
end
cm.list={
		CATEGORY_DESTROY,
		CATEGORY_RELEASE,
		CATEGORY_REMOVE,
		CATEGORY_TOHAND,
		CATEGORY_TODECK,
		CATEGORY_TOGRAVE,
		CATEGORY_DECKDES,
		CATEGORY_HANDES,
		CATEGORY_POSITION,
		CATEGORY_CONTROL,
		CATEGORY_DISABLE,
		CATEGORY_DISABLE_SUMMON,
		CATEGORY_EQUIP,
		CATEGORY_DAMAGE,
		CATEGORY_RECOVER,
		CATEGORY_ATKCHANGE,
		CATEGORY_DEFCHANGE,
		CATEGORY_COUNTER,
		CATEGORY_LVCHANGE,
		CATEGORY_NEGATE,
}
function cm.xyzfilter(c,xyzcard)
	if c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsCanBeXyzMaterial(xyzcard) and c:IsType(TYPE_PENDULUM) and c:IsXyzLevel(xyzcard,7)
end
function cm.xyzfilter1(c)
	return c:IsLocation(LOCATION_SZONE) and c:GetSequence()>5 and c:GetOriginalLevel()==7 and c:IsCode(37564765)
end
function cm.xyzcon(e,c,og,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local minc=2
		local maxc=2
		local minfc=-ft+1
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		minc=math.max(minc,minfc)
		local mg=nil
		local exg=nil
		if og then
			mg=og:Filter(cm.xyzfilter,nil,c)
		else
			mg=Duel.GetMatchingGroup(cm.xyzfilter,tp,LOCATION_MZONE,0,nil,c)
			exg=Duel.GetMatchingGroup(cm.xyzfilter1,tp,LOCATION_SZONE,0,nil)
		end
		if maxc<minc then return false end
		if exg and exg:GetCount()>0 then
			local mct=mg:GetCount()
			local ect=exg:GetCount()
			return mct>=minfc and mct+ect>=minc
		end
		return mg:GetCount()>=minc
end
function cm.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
		local g=nil
		if og and not min then
			g=og
		else
			local mg=nil
			local exg=nil
			if og then
				mg=og:Filter(cm.xyzfilter,nil,c)
			else
				mg=Duel.GetMatchingGroup(cm.xyzfilter,tp,LOCATION_MZONE,0,nil,c)
				exg=Duel.GetMatchingGroup(cm.xyzfilter1,tp,LOCATION_SZONE,0,nil)
			end
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local minc=2
			local maxc=2
			local minfc=-ft+1
			if min then
				minc=math.max(minc,min)
				maxc=math.min(maxc,max)
			end
			minc=math.max(minc,minfc)
			if exg and exg:GetCount()>0 then
				if minfc>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					g=mg:Select(tp,minfc,minfc,nil)
					minc=minc-minfc
					maxc=maxc-minfc
					if maxc>0 and (minc>0 or Duel.SelectYesNo(tp,93)) then
						local sg=mg:Clone()
						sg:Merge(exg)
						sg:Sub(g)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
						local g1=sg:Select(tp,minc,maxc,nil)
						g:Merge(g1)
					end
				else
					local sg=mg:Clone()
					sg:Merge(exg)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					g=sg:Select(tp,minc,maxc,nil)
				end
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				g=mg:Select(tp,minc,maxc,nil)
			end
		end
		c:SetMaterial(g)
		senya.overlaygroup(c,g,false,true)
end
function cm.rop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local og=c:GetOverlayGroup()
	local exg=og:Filter(Card.IsType,nil,TYPE_PENDULUM)
	Duel.SendtoExtraP(exg,nil,REASON_RULE)
	og:Sub(exg)
	Duel.SendtoGrave(og,REASON_RULE)
	Duel.SendtoExtraP(c,nil,REASON_EFFECT)
end
function cm.nfilter(c)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsFaceup() and c:IsCode(37564765)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if cm.nfilter(re:GetHandler()) then return true end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g and g:IsExists(cm.nfilter,1,nil) then return true end
	local res,ceg,cep,cev,re,r,rp=Duel.CheckEvent(re:GetCode())
	if res and ceg and ceg:IsExists(cm.nfilter,1,nil) then return true end
	for i,ctg in pairs(cm.list) do
		local ex,tg,ct,p,v=Duel.GetOperationInfo(ev,ctg)
		if tg then
			if tg:IsExists(cm.nfilter,1,c) then return true end
		elseif v and v>0 and Duel.IsExistingMatchingCard(cm.nfilter,tp,v,0,1,nil) then
			return true
		end
	end
	return false
end