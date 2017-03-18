--Nanahira & Firce777
local m=37564515
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
--if not pcall(function() require("expansions/script/c37564777") end) then require("script/c37564777") end
function cm.initial_effect(c)
	senya.nnhr(c)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetValue(0x777)
	c:RegisterEffect(e5)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564777,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,37560515)
	e1:SetCost(cm.sesscost)
	e1:SetTarget(cm.swwsstg)
	e1:SetOperation(cm.swwssop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(37564777,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,37561515)
	e2:SetCost(cm.sethcost)
	e2:SetTarget(prim.sethtg)
	e2:SetOperation(prim.sethop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37562515)
	e3:SetCost(cm.secost)
	e3:SetOperation(cm.seop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(78651105,0))
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetCondition(prim.ntcon)
	e4:SetOperation(prim.ntop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e4:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e5)
end
function cm.sessfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsRace(RACE_FAIRY)
end
function cm.sesscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.sessfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	local g=Duel.SelectMatchingCard(tp,cm.sessfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.swwsstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.swwssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function cm.sethcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.sessfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler(),at) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.sessfilter,tp,LOCATION_GRAVE,0,2,2,e:GetHandler(),at)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.sefilter(c,e,tp)
	if not (c:IsAbleToGraveAsCost() and c:IsType(TYPE_MONSTER)) then return false end
	if c:IsSetCard(0x777) and Duel.IsExistingMatchingCard(prim.sefilter2,tp,LOCATION_DECK,0,1,nil) then return true end
	if c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) then return true end
	return c:GetOriginalCode()==37564765 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
end
function cm.secost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.sefilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	Duel.DiscardHand(tp,cm.sefilter,1,1,REASON_COST,e:GetHandler(),e,tp)
	e:SetLabelObject(Duel.GetOperatedGroup():GetFirst())
end
function cm.seop(e,tp,eg,ep,ev,re,r,rp)
	local dc=e:GetLabelObject()
	if dc and dc:IsSetCard(0x777) and Duel.IsExistingMatchingCard(prim.sefilter2,tp,LOCATION_DECK,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,prim.sefilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
	if dc:IsRace(RACE_FAIRY) and dc:IsAttribute(ATTRIBUTE_LIGHT) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		Duel.Damage(1-tp,1400,REASON_EFFECT)
	end
	if dc:GetOriginalCode()==37564765 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)   
	end
end