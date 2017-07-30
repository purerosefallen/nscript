--Secret Scarlet
local m=37564561
local cm=_G["c"..m]

cm.Senya_desc_with_nanahira=true
function cm.initial_effect(c)
	Senya.Nanahira(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),2,4)
	local ex=Effect.CreateEffect(c)
	ex:SetType(EFFECT_TYPE_SINGLE)
	ex:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	ex:SetCode(EFFECT_SPSUMMON_CONDITION)
	ex:SetValue(cm.splimit)
	c:RegisterEffect(ex)
	local e2=Senya.NegateEffectModule(c,1)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local rc=re:GetHandler()
		if not Duel.NegateActivation(ev) then return end
		if rc:IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 and not rc:IsLocation(LOCATION_HAND+LOCATION_DECK) then
			if rc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
				and Duel.SelectYesNo(tp,aux.Stringid(90809975,3)) then
				Duel.BreakEffect()
				Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				Duel.ConfirmCards(1-tp,rc)
			elseif (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
				and rc:IsSSetable() and Duel.SelectYesNo(tp,aux.Stringid(90809975,4)) then
				Duel.BreakEffect()
				Duel.SSet(tp,rc)
				Duel.ConfirmCards(1-tp,rc)
			end
		end
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
			local cat=e:GetCategory()
			if bit.band(re:GetHandler():GetOriginalType(),TYPE_MONSTER)~=0 then
				e:SetCategory(bit.bor(cat,CATEGORY_SPECIAL_SUMMON))
			else
				e:SetCategory(bit.band(cat,bit.bnot(CATEGORY_SPECIAL_SUMMON)))
			end
		end
	end)
end
function cm.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end