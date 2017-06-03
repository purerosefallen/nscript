--邪眼之魔女-Sandorion
local m=37564701
local cm=_G["c"..m]
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(cm.xyzcon)
	e0:SetOperation(cm.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(0x14000)
	e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.regtg)
	e1:SetOperation(cm.regop)
	c:RegisterEffect(e1)
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(m,2))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end)
	e8:SetTarget(cm.target)
	e8:SetOperation(cm.activate)
	c:RegisterEffect(e8)
	local e14=Effect.CreateEffect(c)
	e14:SetDescription(aux.Stringid(m,3))
	e14:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e14:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e14:SetCategory(CATEGORY_TOHAND)
	e14:SetCode(EVENT_LEAVE_FIELD)
	--e14:SetCountLimit(1,60150512)
	e14:SetCondition(cm.sumcon)
	e14:SetTarget(cm.target2)
	e14:SetOperation(cm.activate2)
	c:RegisterEffect(e14)
end
function cm.xyzfilter(c,xyzc)
	return c:IsFaceup() and c:IsCanBeXyzMaterial(xyzc) and c:IsXyzLevel(xyzc,1)
end
function cm.xyzfilter1(c)
	return c:IsFaceup()
end
function cm.xyzcon(e,c,og,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		local minc=4
		local maxc=4
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		local mg=nil
		if og then
			mg=og:Filter(cm.xyzfilter,nil,c)
		else
			mg=Duel.GetMatchingGroup(cm.xyzfilter,tp,LOCATION_MZONE,0,nil,c)
			local exg=Duel.GetMatchingGroup(cm.xyzfilter1,tp,LOCATION_PZONE,0,nil)
			if exg:GetCount()==2 and Duel.GetLocationCountFromEx(tp,tp,exg,c)>0 then return true end
		end
		return Senya.CheckGroup(mg,Senya.CheckFieldFilter,nil,minc,maxc,tp,c)
end
function cm.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local g=nil
	if og and not min then
		g=og
	else
		local minc=2
		local maxc=2
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		local mg=nil
		if og then
			mg=og:Filter(cm.xyzfilter,nil,c)
		else
			local exg=Duel.GetMatchingGroup(cm.xyzfilter1,tp,LOCATION_PZONE,0,nil)
			if exg:GetCount()==2 and Duel.GetLocationCountFromEx(tp,tp,exg,c)>0 and Duel.SelectYesNo(tp,m*16) then
				c:SetMaterial(exg)
				Senya.OverlayGroup(c,exg,false,true)
				return
			end
			mg=Duel.GetMatchingGroup(cm.xyzfilter,tp,LOCATION_MZONE,0,nil,c)
		end
		g=Senya.SelectGroup(tp,HINTMSG_XMATERIAL,mg,Senya.CheckFieldFilter,nil,minc,maxc,tp,c)
	end
	c:SetMaterial(g)
	Senya.OverlayGroup(c,g,false,true)
end
function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ
end
function cm.thfilter1(c)
	return c:IsType(TYPE_PENDULUM) and c:IsLevelBelow(4)
end
function cm.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter1,tp,LOCATION_DECK,0,1,nil) end
end
function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(cm.thcon)
	e1:SetOperation(cm.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand() and c:IsLevelBelow(4)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,m)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cm.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_EXTRA+LOCATION_HAND)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local tg=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_EXTRA+LOCATION_HAND,0,nil,e,tp)
	local sg=Group.CreateGroup()
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect and (ect<=0 or ect>ft) then ect=nil end
	if ect==nil or tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=tg:Select(tp,1,ft,nil)
		sg:Merge(g)
	else
		repeat
			local ct=math.min(ft,ect)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=tg:Select(tp,1,ct,nil)
			tg:Sub(g)
			sg:Merge(g)
			ft=ft-g:GetCount()
			ect=ect-g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
		until ft==0 or ect==0 or not Duel.SelectYesNo(tp,210)
		local hg=tg:Filter(Card.IsLocation,nil,LOCATION_HAND)
		if ft>0 and ect==0 and hg:GetCount()>0 and Duel.SelectYesNo(tp,210) then
			local g=hg:Select(tp,1,ft,nil)
			sg:Merge(g)
		end
	end
	Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,false,false,POS_FACEUP)
end
function cm.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function cm.filter2(c)
	return c:IsAbleToHand() and c:IsType(TYPE_PENDULUM)
end
function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==LOCATION_GRAVE and cm.filter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter2,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,cm.filter2,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function cm.activate2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end