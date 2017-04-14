--Nanahira & Miyuki
local m=37564521
local cm=_G["c"..m]

cm.desc_with_nanahira=true
function cm.initial_effect(c)
	senya.nnhrp(c)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37564765,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,m)
	e3:SetCondition(cm.spcon2)
	e3:SetTarget(cm.sptg2)
	e3:SetOperation(cm.spop2)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(37564541)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCondition(senya.nnexpcon)
	e2:SetValue(senya.order_table_new(cm.pendulum_info))
	c:RegisterEffect(e2)
end
cm.pendulum_info={
	location=LOCATION_SZONE,
	filter=function(c,e) return c==e:GetHandler() end,
}
cm.pendulum_level=7
function cm.ssfilter(c)
	return c:IsFaceup() and c:GetOriginalCode()==37564765
end
function cm.hcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(cm.ssfilter,c:GetControler(),LOCATION_MZONE,0,1,nil) and c:IsFaceup() and not c:IsDisabled()
end
function cm.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
function cm.spfilter(c,e,tp)
	return c:IsCode(37564765) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cm.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end