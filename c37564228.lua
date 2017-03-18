--Sawawa-永远的三日天下
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function c37564228.initial_effect(c)
	senya.sww(c,1,true,false,false)
	senya.bmdamchk(c,true)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37564228,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return senya.bmdamchkcon(e,tp,eg,ep,ev,re,r,rp) and senya.swwblex(e,tp)
	end)
	e3:SetCost(c37564228.atkcost)
	e3:SetOperation(c37564228.atkop)
	c:RegisterEffect(e3)
end
function c37564228.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=1
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(senya.swwcostfilter,tp,LOCATION_GRAVE,0,ct,nil) and c:GetFlagEffect(37564228)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,senya.swwcostfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	c:RegisterFlagEffect(37564228,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function c37564228.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and bc then
		local val=bc:GetAttack()
		if val<0 then val=0 end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(val)
		c:RegisterEffect(e1)
	end
end