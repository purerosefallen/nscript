--Sawawa-Tokamak Sol Cannon

local m=37564216
local cm=_G["c"..m]
cm.Senya_name_with_sawawa=true
function cm.initial_effect(c)
	Senya.SawawaCommonEffect(c,1,true,false,false)
--effects
   local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564216,1))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37564216)
	e1:SetCondition(Senya.CheckNoExtra)
	e1:SetCost(Senya.SawawaRemoveCost(1))
	e1:SetTarget(c37564216.tg)
	e1:SetOperation(c37564216.op)
	c:RegisterEffect(e1)
end
function c37564216.filter(c)
	return c:IsFaceup() and c:GetAttack()~=c:GetBaseAttack() and c:IsAbleToRemove()
end
function c37564216.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c37564216.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c37564216.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c37564216.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local atk=math.abs(tc:GetAttack()-tc:GetBaseAttack())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,atk)
end
function c37564216.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk=math.abs(tc:GetAttack()-tc:GetBaseAttack())
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end