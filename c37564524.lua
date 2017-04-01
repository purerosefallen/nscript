local m=37564524
local cm=_G["c"..m]
--
cm.desc_with_nanahira=true
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_SINGLE)
	e22:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e22:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e22)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.xyzcon)
	e2:SetOperation(cm.xyzop)
	e2:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e2)
	senya.nnhr(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(cm.atkop)
	c:RegisterEffect(e1)
	senya.scopy(c,LOCATION_DECK+LOCATION_GRAVE,0,cm.check_nnhr,nil,nil,1,EFFECT_COUNT_CODE_SINGLE,nil,false)
end
function cm.check_nnhr(c)
	return c.desc_with_nanahira
end
function cm.mfilter(c,xyzc)
	return c:IsFaceup() and c:IsCanBeXyzMaterial(xyzc) and c:IsCode(37564765)
end
function cm.xyzcon(e,c,og,min,max)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local minc=4
	local maxc=4
	if min then
		minc=math.max(minc,min)
		maxc=math.min(maxc,max)
	end
	local ct=math.max(minc-1,-ft)
	local mg=nil
	if og then
		mg=og:Filter(cm.mfilter,nil,c)
	else
		mg=Duel.GetMatchingGroup(cm.mfilter,tp,LOCATION_MZONE,0,nil,c)
	end
	return maxc>=minc and senya.selectdiff(tp,HINTMSG_XMATERIAL,mg,TYPE_RITUAL+TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO,4,Card.GetType,nil,true)
end
function cm.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local g=nil
	if og and not min then
		g=og
	else
		local mg=nil
		if og then
			mg=og:Filter(cm.mfilter,nil,c)
		else
			mg=Duel.GetMatchingGroup(cm.mfilter,tp,LOCATION_MZONE,0,nil,c)
		end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local minc=4
		local maxc=4
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		local ct=math.max(minc-1,-ft)
		g=senya.selectdiff(tp,HINTMSG_XMATERIAL,mg,TYPE_RITUAL+TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO,4,Card.GetType,nil)
	end
	c:SetMaterial(g)
	senya.overlaygroup(c,g,true,true)
end
function cm.rmfilter(c)
	return c:IsAbleToRemove()
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(cm.rmfilter,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()==0 then return end
	Duel.ConfirmCards(tp,g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local gc=g:Select(tp,1,1,nil):GetFirst()
	Duel.Remove(gc,POS_FACEUP,REASON_EFFECT)
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc then
			local cd=tc:GetOriginalCode()
			senya.CopyEffectExtraCount(c,7,cd,RESET_EVENT+0x1fe0000,1)
		end
end