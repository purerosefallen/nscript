--樱华月想 -SDVX Remix-
local m=37564316
local cm=_G["c"..m]
--if not pcall(function() require("expansions/script/c37564765") end) then require("script/c37564765") end
function cm.initial_effect(c)
	senya.enable_kaguya_check_3L()
	senya.setreg(c,m,37564876)
	c:SetUniqueOnField(1,0,m)
	aux.AddXyzProcedure(c,aux.FALSE,1,5,senya.RemainFilter(3),aux.Stringid(m,0))
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetOperation(cm.skipop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(senya.desccost())
	e1:SetTarget(cm.target0)
	e1:SetOperation(cm.operation0)
	c:RegisterEffect(e1)
end
function cm.skipop(e,tp,eg,ep,ev,re,r,rp)
	local effect_list=senya.codelist_3L
	local avaliable_list={}
	local exile_list={}
	for i,code in pairs(effect_list) do
		local res=true
		if code==37564828 then res=false end
		if e:GetHandler():GetFlagEffect(code-4000)>0 then res=false end
		local mt=_G["c"..code]
		if mt then
			if res and mt.effect_operation_3L then table.insert(avaliable_list,i) end
		elseif res then
			_G["c"..code]={}
			table.insert(exile_list,code)
			if pcall(function() dofile("expansions/script/c"..code..".lua") end) or pcall(function() dofile("script/c"..code..".lua") end) then
				mt=_G["c"..code]
				if mt and mt.effect_operation_3L then
					table.insert(avaliable_list,i)
				end 
			end
		end  
	end
	if #avaliable_list>0 then
		Duel.Hint(HINT_CARD,0,e:GetHandler():GetOriginalCode())
		local option_list={}
		for i,v in pairs(avaliable_list) do
			local descid=1
			local ccode=effect_list[v]
			local mt=_G["c"..ccode]
			local effct=mt.custom_effect_count_3L
			if effct and effct>1 then descid=effct+1 end
			table.insert(option_list,aux.Stringid(ccode,descid))
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local option=avaliable_list[Duel.SelectOption(tp,table.unpack(option_list))+1]
		local rcode=effect_list[option]
		local et=senya.lgeff(e:GetHandler(),rcode)
		if et then
			for i,te in pairs(et) do
				if te:IsHasType(0x7e0) then
					te:SetCost(cm.ccost(te:GetCost()))
				end
			end
			local mt=_G["c"..rcode]
			e:GetHandler():RegisterFlagEffect(m,RESET_EVENT+0x1fe0000,0,1,senya.order_table_new(mt))
		end
	end
	for i,ecode in pairs(exile_list) do
		_G["c"..ecode]=nil
	end
end
function cm.ccost(costf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and (not costf or costf(e,tp,eg,ep,ev,re,r,rp,0)) end
		if costf then costf(e,tp,eg,ep,ev,re,r,rp,1) end
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	end
end
function cm.filter(c,tp)
	return (c:IsControler(tp) or c:IsAbleToChangeControler()) and not c:IsType(TYPE_TOKEN)
end
function cm.target0(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and cm.filter(chkc,tp) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(cm.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cm.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),tp)
end
function cm.operation0(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		senya.overlaycard(c,tc,false)
	end
end