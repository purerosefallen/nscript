--残留的愿望·Coconatsu
local m=37564324
local cm=_G["c"..m]
--
function cm.initial_effect(c)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(cm.FConditionCode2)
	e1:SetOperation(cm.FOperationCode2)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.drtg)
	e1:SetOperation(cm.drop)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetSummonType()==SUMMON_TYPE_FUSION and cm.material
	end)
	e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local code1=cm.material[1]
		local code2=cm.material[2]
		local f=Card.RegisterEffect
		Card.RegisterEffect=function(c,e,forced)
			if e:IsHasType(0x7e0) then
				e:SetCondition(aux.TRUE)
			end
			f(c,e,forced)
		end
		e:GetHandler():CopyEffect(code1,RESET_EVENT+0x1fe0000,1)
		e:GetHandler():CopyEffect(code2,RESET_EVENT+0x1fe0000,1)
		Card.RegisterEffect=f
	end)
	c:RegisterEffect(e0)
end
function cm.ctfilter(c,code)
	return c:GetOriginalCode()==code
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsFacedown() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end
function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_EXTRA,2,nil)
	end
end
function cm.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)
	if g:GetCount()<2 then return end
	local sg=g:RandomSelect(tp,2)
	Duel.ConfirmCards(tp,sg)
	local s1=sg:GetFirst():GetOriginalCode()
	local s2=sg:GetNext():GetOriginalCode()
	cm.material={s1,s2}
	cm.material_count=2
	local ex=Effect.CreateEffect(e:GetHandler())
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_PHASE+PHASE_END)
	ex:SetOperation(function(e)
		cm.material=nil
		cm.material_count=nil
		e:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
function cm.FConditionCode2(e,g,gc,chkfnf)
				if g==nil then return true end
				if not cm.material then return false end
				local code1=cm.material[1]
				local code2=cm.material[2]
				local sub=true
				local chkf=bit.band(chkfnf,0xff)
				local mg=g:Filter(Card.IsCanBeFusionMaterial,gc,e:GetHandler())
				if gc then
					if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
					local b1=0 local b2=0 local bw=0
					if gc:IsFusionCode(code1) then b1=1 end
					if gc:IsFusionCode(code2) then b2=1 end
					if sub and gc:CheckFusionSubstitute(e:GetHandler()) then bw=1 end
					if b1+b2+bw==0 then return false end
					if chkf~=PLAYER_NONE and not Auxiliary.FConditionCheckF(gc,chkf) then
						mg=mg:Filter(Auxiliary.FConditionCheckF,nil,chkf)
					end
					if b1+b2+bw>1 then
						return mg:IsExists(Auxiliary.FConditionFilter22,1,nil,code1,code2,sub,e:GetHandler())
					elseif b1==1 then
						return mg:IsExists(Auxiliary.FConditionFilter12,1,nil,code2,sub,e:GetHandler())
					elseif b2==1 then
						return mg:IsExists(Auxiliary.FConditionFilter12,1,nil,code1,sub,e:GetHandler())
					else
						return mg:IsExists(Auxiliary.FConditionFilter21,1,nil,code1,code2)
					end
				end
				local b1=0 local b2=0 local bw=0
				local ct=0
				local fs=chkf==PLAYER_NONE
				local tc=mg:GetFirst()
				while tc do
					local match=false
					if tc:IsFusionCode(code1) then b1=1 match=true end
					if tc:IsFusionCode(code2) then b2=1 match=true end
					if sub and tc:CheckFusionSubstitute(e:GetHandler()) then bw=1 match=true end
					if match then
						if Auxiliary.FConditionCheckF(tc,chkf) then fs=true end
						ct=ct+1
					end
					tc=mg:GetNext()
				end
				return ct>1 and b1+b2+bw>1 and fs
end
function cm.FOperationCode2(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
				local code1=cm.material[1]
				local code2=cm.material[2]
				local chkf=bit.band(chkfnf,0xff)
				local sub=true
				local g=eg:Filter(Card.IsCanBeFusionMaterial,gc,e:GetHandler())
				local tc=gc
				local g1=nil
				if gc then
					if chkf~=PLAYER_NONE and not Auxiliary.FConditionCheckF(gc,chkf) then
						g=g:Filter(Auxiliary.FConditionCheckF,nil,chkf)
					end
				else
					local sg=g:Filter(Auxiliary.FConditionFilter22,nil,code1,code2,sub,e:GetHandler())
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
					if chkf~=PLAYER_NONE then g1=sg:FilterSelect(tp,Auxiliary.FConditionCheckF,1,1,nil,chkf)
					else g1=sg:Select(tp,1,1,nil) end
					tc=g1:GetFirst()
					g:RemoveCard(tc)
				end
				local b1=0 local b2=0 local bw=0
				if tc:IsFusionCode(code1) then b1=1 end
				if tc:IsFusionCode(code2) then b2=1 end
				if sub and tc:CheckFusionSubstitute(e:GetHandler()) then bw=1 end
				local g2=nil
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				if b1+b2+bw>1 then
					g2=g:FilterSelect(tp,Auxiliary.FConditionFilter22,1,1,nil,code1,code2,sub,e:GetHandler())
				elseif b1==1 then
					g2=g:FilterSelect(tp,Auxiliary.FConditionFilter12,1,1,nil,code2,sub,e:GetHandler())
				elseif b2==1 then
					g2=g:FilterSelect(tp,Auxiliary.FConditionFilter12,1,1,nil,code1,sub,e:GetHandler())
				else
					g2=g:FilterSelect(tp,Auxiliary.FConditionFilter21,1,1,nil,code1,code2)
				end
				if g1 then g2:Merge(g1) end
				Duel.SetFusionMaterial(g2)
end