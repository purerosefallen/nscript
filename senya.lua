senya=senya or {}
local cm=senya
os=require('os')
table=require('table')
io=require('io')
--7CG universal scripts
--test parts
aux.BeginPuzzle=aux.TRUE
cm.delay=0x14000
cm.fix=0x40400
cm.m=37564765
function cm.desc(id)
	id=id or 0
	return 37564765*16+id
end
cm.loaded_metatable_list=cm.loaded_metatable_list or {}
function cm.load_metatable(code)
	local m1=_G["c"..code]
	if m1 then return m1 end
	local m2=cm.loaded_metatable_list[code]
	if m2 then return m2 end
	_G["c"..code]={}
	if pcall(function() dofile("expansions/script/c"..code..".lua") end) or pcall(function() dofile("script/c"..code..".lua") end) then
		local mt=_G["c"..code]
		_G["c"..code]=nil
		if mt then
			cm.loaded_metatable_list[code]=mt
			return mt
		end
	else
		_G["c"..code]=nil
	end
end
function cm.check_set(c,setcode,v,f,...)	
	local codet=nil
	if type(c)=="number" then
		codet={c}
	elseif type(c)=="table" then
		codet=c
	elseif type(c)=="userdata" then
		local f=f or Card.GetCode
		codet={f(c)}
	end
	local ncodet={...}
	for i,code in pairs(codet) do
		for i,ncode in pairs(ncodet) do
			if code==ncode then return true end
		end
		local mt=cm.load_metatable(code)
		if mt and mt["named_with_"..setcode] and (not v or mt["named_with_"..setcode]==v) then return true end
	end
	return false
end
function cm.check_set_elem(c)
	return cm.check_set(c,"elem")
end
function cm.check_fusion_set_elem(c)
	if c:IsHasEffect(6205579) then return false end
	return cm.check_set(c,"elem",nil,Card.GetFusionCode)
end
function cm.check_set_rose(c)
	return cm.check_set(c,"rose")
end
function cm.check_set_sawawa(c)
	return cm.check_set(c,"sawawa")
end
function cm.check_set_prism(c)
	return cm.check_set(c,"prism")
end
function cm.check_fusion_set_prism(c)
	if c:IsHasEffect(6205579) then return false end
	return cm.check_set(c,"prism",nil,Card.GetFusionCode)
end
function cm.check_set_prim(c)
	return cm.check_set(c,"prim")
end
function cm.check_set_sayuri(c)
	return cm.check_set(c,"sayuri") or c:IsHasEffect(37564900)
end
function cm.check_set_remix(c)
	return cm.check_set(c,"remix")
end
function cm.check_set_3L(c)
	if c:IsHasEffect(37564800) then return true end
	local codet={c:GetCode()}
	for j,code in pairs(codet) do
		local mt=cm.load_metatable(code)
		if mt then
			for str,v in pairs(mt) do   
				if type(str)=="string" and str:find("_3L") and v  then return true end
			end
		end
	end
	return false
end
function cm.check_fusion_set_3L(c)
	if c:IsHasEffect(6205579) then return false end
	if c:IsHasEffect(37564800) then return true end
	local codet={c:GetFusionCode()}
	for j,code in pairs(codet) do
		local mt=cm.load_metatable(code)
		if mt then
			for str,v in pairs(mt) do   
				if type(str)=="string" and str:find("_3L") and v  then return true end
			end
		end
	end
	return false
end
function cm.sgreg(c,setcd)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(setcd)
	c:RegisterEffect(e1)
	return e1
end
--updated overlay
function cm.overlaycard(c,tc,xm,nchk)
	if not nchk and (not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or not c:IsType(TYPE_XYZ) or tc:IsType(TYPE_TOKEN)) then return end
	if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
		tc:CancelToGrave()
	end
	if tc:GetOverlayCount()>0 then
		local og=tc:GetOverlayGroup()
		if xm then
			Duel.Overlay(c,og)
		else
			Duel.SendtoGrave(og,REASON_RULE)
		end
	end
	Duel.Overlay(c,tc)
end
function cm.overlayfilter(c,nchk)
	return nchk or not c:IsType(TYPE_TOKEN)
end
function cm.overlaygroup(c,g,xm,nchk)
	if not nchk and (not c:IsLocation(LOCATION_MZONE) or c:IsFacedown() or g:GetCount()<=0 or not c:IsType(TYPE_XYZ)) then return end
	local tg=g:Filter(cm.overlayfilter,nil,nchk)
	if tg:GetCount()==0 then return end
	local og=Group.CreateGroup()
	for tc in aux.Next(tg) do
		if tc:IsStatus(STATUS_LEAVE_CONFIRMED) then
			tc:CancelToGrave()
		end
		og:Merge(tc:GetOverlayGroup())
	end
	if og:GetCount()>0 then
		if xm then
			Duel.Overlay(c,og)
		else
			Duel.SendtoGrave(og,REASON_RULE)
		end
	end
	Duel.Overlay(c,tg)
end
--xyz summon of prim
function cm.rxyz1(c,rk,f,minct,maxct,xm,...)
	local ext_params={...}
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.xyzcon1(rk,f,minct,maxct,ext_params))
	e1:SetOperation(cm.xyzop1(rk,f,minct,maxct,xm,ext_params))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	return e1
end
function cm.mfilter(c,xyzc,rk,f,ext_params)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeXyzMaterial(xyzc) and (not rk or c:GetRank()==rk) and (not f or f(c,xyzc,table.unpack(ext_params)))
end
function cm.xyzfilter1(c,g,ct)
	return g:IsExists(cm.xyzfilter2,ct,c,c:GetRank())
end
function cm.xyzfilter2(c,rk)
	return c:GetRank()==rk
end
function cm.xyzcon1(rk,f,minct,maxct,ext_params)
return function(e,c,og,min,max)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local minc=minct or 2
	local maxc=maxct or minct or 63
	if min then
		minc=math.max(minc,min)
		maxc=math.min(maxc,max)
	end
	local ct=math.max(minc-1,-ft)
	local mg=nil
	if og then
		mg=og:Filter(cm.mfilter,nil,c,rk,f,ext_params)
	else
		mg=Duel.GetMatchingGroup(cm.mfilter,tp,LOCATION_MZONE,0,nil,c,rk,f,ext_params)
	end
	return maxc>=minc and mg:IsExists(cm.xyzfilter1,1,nil,mg,ct)
end
end
function cm.xyzop1(rk,f,minct,maxct,xm,ext_params)
return function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local g=nil
	if og and not min then
		g=og
	else
		local mg=nil
		if og then
			mg=og:Filter(cm.mfilter,nil,c,rk,f,ext_params)
		else
			mg=Duel.GetMatchingGroup(cm.mfilter,tp,LOCATION_MZONE,0,nil,c,rk,f,ext_params)
		end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local minc=minct or 2
		local maxc=maxct or minct or 63
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		local ct=math.max(minc-1,-ft)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		g=mg:FilterSelect(tp,cm.xyzfilter1,1,1,nil,mg,ct)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g2=mg:FilterSelect(tp,cm.xyzfilter2,ct,maxc-1,g:GetFirst(),g:GetFirst():GetRank())
		g:Merge(g2)
	end
	c:SetMaterial(g)
	cm.overlaygroup(c,g,xm,true)
end
end

function cm.rxyz2(c,rk,f,ct,xm,...)
	return cm.rxyz1(c,rk,f,ct,ct,xm,...)
end
function cm.rxyz3(c,func,minc,maxc,xm,...)
	local ext_params={...}
	c:EnableReviveLimit()
	local maxc=maxc or minc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.rxyz3Condition(func,minc,maxc,ext_params))
	e1:SetOperation(cm.rxyz3Operation(func,minc,maxc,xm,ext_params))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	return e1
end
function cm.rxyz3Filter(c,xyzcard,func,ext_params)
	if c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsCanBeXyzMaterial(xyzcard) and (not func or func(c,xyzcard,table.unpack(ext_params)))
end
function cm.rxyz3Condition(func,minct,maxct,ext_params)
	return function(e,c,og,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local minc=minct or 2
		local maxc=maxct or minct or 63
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		minc=math.max(minc,-ft+1)
		local mg=nil
		if og then
			mg=og:Filter(cm.rxyz3Filter,nil,c,func,ext_params)
		else
			mg=Duel.GetMatchingGroup(cm.rxyz3Filter,tp,LOCATION_MZONE,0,nil,c,func,ext_params)
		end
		return maxc>=minc and mg:GetCount()>=minc
	end
end
function cm.rxyz3Operation(func,minct,maxct,xm,ext_params)
	return function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
		local g=nil
		if og and not min then
			g=og
		else
			local mg=nil
			if og then
				mg=og:Filter(cm.rxyz3Filter,nil,c,func,ext_params)
			else
				mg=Duel.GetMatchingGroup(cm.rxyz3Filter,tp,LOCATION_MZONE,0,nil,c,func,ext_params)
			end
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local minc=minct or 2
			local maxc=maxct or minct or 63
			if min then
				minc=math.max(minc,min)
				maxc=math.min(maxc,max)
			end
			minc=math.max(minc,-ft+1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			g=mg:Select(tp,minc,maxc,nil)
		end
		c:SetMaterial(g)
		cm.overlaygroup(c,g,xm,true)
	end
end
function cm.rxyz4(c,lv,func,minc1,minc2,maxc2,xm,...)
	local ext_params={...}
	c:EnableReviveLimit()
	local maxc2=maxc2 or minc2
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.rxyz4Condition(func,lv,minc1,minc2,maxc2,ext_params))
	e1:SetOperation(cm.rxyz4Operation(func,lv,minc1,minc2,maxc2,xm,ext_params))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	return e1
end
function cm.rxyz4Filter1(c,xyzcard,lv)
	return c:IsFaceup() and c:IsCanBeXyzMaterial(xyzcard) and c:IsXyzLevel(xyzcard,lv)
end
function cm.rxyz4Condition(func,lv,minc1,minc2,maxc2,ext_params)
	func=func or aux.TRUE
	return function(e,c,og,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		local minc,maxc=minc1+minc2,minc1+maxc2
		local mg=nil
		if og then
			if min then
		if min>minc then minc=min end
		if max<maxc then maxc=max end
		if minc>maxc then return false end
			else
		local count=og:GetCount()
		return count>=minc and count<=maxc
			and og:FilterCount(cm.rxyz4Filter1,nil,c,lv)==count
			and og:IsExists(func,minc1,nil,c,table.unpack(ext_params))
			end
			mg=og:Filter(cm.rxyz4Filter1,nil,c,lv)
		else
			mg=Duel.GetMatchingGroup(cm.rxyz4Filter1,c:GetControler(),LOCATION_MZONE,0,nil,c,lv)
		end
		return mg:GetCount()>=minc and mg:IsExists(func,minc1,nil,c)
	end
end
function cm.rxyz4Operation(func,lv,minc1,minc2,maxc2,xm,ext_params)
	func=func or aux.TRUE
	return function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
		local mg=og or Duel.GetMatchingGroup(cm.rxyz4Filter1,tp,LOCATION_MZONE,0,nil,c,lv)
		local minc,maxc=minc1+minc2,minc1+maxc2
		if not og or min then
			if min then mg=og:Filter(cm.rxyz4Filter1,nil,c,lv) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local mg1=mg:FilterSelect(tp,func,minc1,minc1,nil,c,table.unpack(ext_params))
			mg:Sub(mg1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			mg=mg:Select(tp,minc2,maxc2,nil)
			mg:Merge(mg1)
		end
		c:SetMaterial(mg)
		cm.overlaygroup(c,mg,xm,true)
	end
end
function cm.rxyz5(c,func,rfunc,lv,minc,maxc,xm,...)
	local ext_params={...}
	c:EnableReviveLimit()
	local maxc=maxc or minc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(cm.rxyz5Condition(func,rfunc,lv,minc,maxc,ext_params))
	e1:SetOperation(cm.rxyz5Operation(func,rfunc,lv,minc,maxc,xm,ext_params))
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	return e1
end
function cm.rxyz5Filter(c,xyzcard,func,lv,ext_params)
	if c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsCanBeXyzMaterial(xyzcard) and (not func or func(c,xyzcard,table.unpack(ext_params))) and (not lv or c:IsXyzLevel(xyzcard,lv))
end
function cm.rxyz5ValCheck(c,rfunc,xyzc)  
	if rfunc and rfunc(c,xyzc) then
		return 0x10002
	else
		return 1
	end
end
function cm.rxyz5Condition(func,rfunc,lv,minct,maxct,ext_params)
	return function(e,c,og,min,max)
		if c==nil then return true end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local tp=c:GetControler()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local count=minct or 2
		local minc=math.max(1,-ft+1)
		local maxc=maxct or 63
		if min then
			minc=math.max(minc,min)
			maxc=math.min(maxc,max)
		end
		local mg=nil
		if og then
			mg=og:Filter(cm.rxyz5Filter,nil,c,func,lv,ext_params)
		else
			mg=Duel.GetMatchingGroup(cm.rxyz5Filter,tp,LOCATION_MZONE,0,nil,c,func,lv,ext_params)
		end
		return maxc>=minc and mg:CheckWithSumEqual(cm.rxyz5ValCheck,count,minc,maxc,rfunc,c)
	end
end
function cm.rxyz5Operation(func,rfunc,lv,minct,maxct,xm,ext_params)
	return function(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
		local g=nil
		if og and not min then
			g=og
		else
			local mg=nil
			if og then
				mg=og:Filter(cm.rxyz5Filter,nil,c,func,lv,ext_params)
			else
				mg=Duel.GetMatchingGroup(cm.rxyz5Filter,tp,LOCATION_MZONE,0,nil,c,func,lv,ext_params)
			end
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			local count=minct or 2
			local minc=math.max(1,-ft+1)
			local maxc=maxct or 63
			if min then
				minc=math.max(minc,min)
				maxc=math.min(maxc,max)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			g=mg:SelectWithSumEqual(cm.rxyz5ValCheck,tp,count,minc,maxc,rfunc,c)
			maxc=maxc-g:GetCount()
			mg:Sub(g)
			if maxc>0 and mg:GetCount()>0 and Duel.SelectYesNo(tp,93) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local g1=mg:Select(tp,1,maxc,nil)
				g:Merge(g1)
			end
		end
		c:SetMaterial(g)
		cm.overlaygroup(c,g,xm,true)
	end
end
cm.proc_check_list={
	[Duel.Destroy]=Card.IsDestructable,
	[Duel.SendtoDeck]=Card.IsAbleToDeckOrExtraAsCost,
	[Duel.SendtoExtraP]=Card.IsAbleToDeckOrExtraAsCost,
	[Duel.SendtoHand]=Card.IsAbleToHandAsCost,
	[Duel.SendtoGrave]=Card.IsAbleToGraveAsCost,
	[Duel.Remove]=Card.IsAbleToRemoveAsCost,
	[Duel.Release]=Card.IsReleasable,
}
cm.proc_param_list={
	[Duel.Destroy]={REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoDeck]={nil,2,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoExtraP]={nil,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoHand]={nil,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.SendtoGrave]={REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.Remove]={POS_FACEUP,REASON_COST+REASON_FUSION+REASON_MATERIAL},
	[Duel.Release]={REASON_COST+REASON_FUSION+REASON_MATERIAL},
}
--touch fusion proc using fusion material
function cm.fproc(c,loc,opf,fonly,sonly)
	local loc=loc or LOCATION_MZONE
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(cm.desc(0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(cm.gsprcon(loc,opf))
	e2:SetOperation(cm.gsprop(loc,opf))
	c:RegisterEffect(e2)
	if sonly then
		local e22=Effect.CreateEffect(c)
		e22:SetType(EFFECT_TYPE_SINGLE)
		e22:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e22:SetCode(EFFECT_SPSUMMON_CONDITION)
		c:RegisterEffect(e22)
	elseif fonly then
		local e22=Effect.CreateEffect(c)
		e22:SetType(EFFECT_TYPE_SINGLE)
		e22:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e22:SetCode(EFFECT_SPSUMMON_CONDITION)
		e22:SetValue(aux.fuslimit)
		c:RegisterEffect(e22)
	end
	return e2
end
function cm.gsprfilter(c,fc,opf)
	local f=cm.proc_check_list[opf]
	return c:IsCanBeFusionMaterial(fc) and (not f or f(c))
end
function cm.gsprcon(loc,opf)
return function(e,c)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
	local mg=Duel.GetMatchingGroup(cm.gsprfilter,tp,loc,0,c,c,opf)
	return c:CheckFusionMaterial(mg,nil,chkf)
end
end
function cm.gsprop(loc,opf)
return function(e,tp,eg,ep,ev,re,r,rp,c)
	local chkf=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and PLAYER_NONE or tp
	local mg=Duel.GetMatchingGroup(cm.gsprfilter,tp,loc,0,c,c,opf)
	local g=Duel.SelectFusionMaterial(tp,c,mg,nil,chkf)
	c:SetMaterial(g)
	local params=cm.proc_param_list[opf]
	opf(g,table.unpack(params))
end
end
--mokou reborn
function cm.mk(c,ct,cd,eff,con,exop,excon,comp)
	local comp=comp or false
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(ct,cd)
	e2:SetCondition(cm.mkcon(eff,con))
	e2:SetTarget(cm.mktg(comp))
	e2:SetOperation(cm.mkop(exop,excon,comp))
	c:RegisterEffect(e2)
	return e2
end
function cm.mkcon(eff,con)
	if eff then
		return function(e,tp,eg,ep,ev,re,r,rp)
			return bit.band(e:GetHandler():GetReason(),0x41)==0x41 and (not con or con(e,tp,eg,ep,ev,re,r,rp))
		end
	else
		return function(e,tp,eg,ep,ev,re,r,rp)
			return e:GetHandler():IsReason(REASON_DESTROY) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
		end
	end
end
function cm.mktg(comp)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,comp,comp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
end
function cm.mkop(exop,excon,comp)
return function(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,comp,comp) then return end
	if Duel.SpecialSummon(c,0,tp,tp,comp,comp,POS_FACEUP)>0 and exop and (not excon or excon(e,tp,eg,ep,ev,re,r,rp)) then
		exop(e,tp,eg,ep,ev,re,r,rp)
	end
	if comp then c:CompleteProcedure() end
end
end
--code lists
cm.csetlist={
"elem",
"sawawa",
"prism",
"prim",
"3L",
"sayuri",
}
function cm.cgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cm.cgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function cm.cgfilter(c)
	return cm.unifilter(c) and c:IsFaceup()
end
function cm.unifilter(c)
	if not c:IsType(TYPE_MONSTER) then return false end
	if c:IsCode(37564765) then return true end
	for i,v in pairs(cm.csetlist) do
		local chkf=cm["check_set_"..v]
		if chkf(c) then return true end
	end
	return false
end
--rm mat cost
function cm.rmovcost(ct)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
end
--discard hand cost
function cm.discost(ct,f,...)
	local ext_params={...}
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(cm.discostf,tp,LOCATION_HAND,0,ct,e:GetHandler(),f,ext_params) end
		Duel.DiscardHand(tp,cm.discostf,ct,ct,REASON_COST+REASON_DISCARD,e:GetHandler(),f,ext_params)
	end
end
function cm.discostf(c,f,ext_params)
	return c:IsDiscardable() and (not f or f(c,table.unpack(ext_params)))
end
--release cost
function cm.serlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function cm.sermcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function cm.setdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckOrExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function cm.setgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function cm.sethcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHandAsCost() end
	Duel.SendtoHand(e:GetHandler(),nil,REASON_COST)
end
function cm.sedescost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
--for ss effects
function cm.spfilter(c,e,tp,f,ig,stype)
	return c:IsCanBeSpecialSummoned(e,stype,tp,ig,ig) and (not f or f(c,e,tp)) and c:IsType(TYPE_MONSTER)
end
function cm.tgsptg(loc,f,opp,ig,stype)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	stype=stype or 0
	if not ig then ig=false end
	local oploc=opp and loc or 0
	if chkc then return chkc:IsLocation(loc) and cm.spfilter(chkc,e,tp,f,ig,stype) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(cm.spfilter,tp,loc,oploc,1,nil,e,tp,f,ig,stype) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,cm.spfilter,tp,loc,oploc,1,1,nil,e,tp,f,ig,stype)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
end
function cm.tgspop(ig,stype,exop)
return function(e,tp,eg,ep,ev,re,r,rp)
	ig=ig or false
	stype=stype or 0
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,stype,tp,tp,ig,ig,POS_FACEUP) then
		if exop then exop(e,tp,tc,e:GetHandler()) end
		Duel.SpecialSummonComplete()
	end
end
end
function cm.sesptg(loc,f,opp,ig,stype)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	stype=stype or 0
	ig=ig or false
	local oploc=opp and loc or 0
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.spfilter,tp,loc,oploc,1,nil,e,tp,f,ig,stype) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
end
function cm.sespop(loc,f,opp,ig,stype,exop)
return function(e,tp,eg,ep,ev,re,r,rp)
	stype=stype or 0
	ig=ig or false
	local oploc=opp and loc or 0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.spfilter,tp,loc,oploc,1,1,nil,e,tp,f,ig,stype)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummonStep(tc,stype,tp,tp,ig,ig,POS_FACEUP) then
		if exop then exop(e,tp,tc,e:GetHandler()) end
		Duel.SpecialSummonComplete()
	end
end
end
--for search effects
function cm.srfilter(c,f)
	return c:IsAbleToHand() and (not f or f(c))
end
function cm.sesrtg(loc,f)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.srfilter,tp,loc,0,1,nil,f) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,loc)
end
end
function cm.sesrop(loc,f)
return function(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.srfilter,tp,loc,0,1,1,nil,f)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
end
function cm.tgsrtg(loc,f)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetControler()==tp and chkc:GetLocation()==loc and cm.srfilter(chkc,f) end
	if chk==0 then return Duel.IsExistingTarget(cm.srfilter,tp,loc,0,1,nil,f) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,cm.srfilter,tp,loc,0,1,1,nil,f)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
end
function cm.tgsrop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--arrival condition
function cm.arcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
---check date dt="Mon" "Tue" etc
function cm.dtcon(dt,excon)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return dt==os.date("%a") and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
	end
end
--copy effect c=getcard(nil=orcard) tc=sourcecard ht=showcard(bool) res=reset event(nil=no reset)
--ctlm=extra count limit
function cm.copy(e,c,tc,ht,res,resct,ctlm)
		c=c or e:GetHandler()
		res=res or RESET_EVENT+0x1fe0000
		local cid=nil
		if tc and c:IsFaceup() and c:IsRelateToEffect(e) then
			local code=tc:GetOriginalCode()
			local atk=tc:GetBaseAttack()
			local def=tc:GetBaseDefense()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(res,resct)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(code)
			c:RegisterEffect(e1)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetReset(res,resct)
			e3:SetCode(EFFECT_SET_BASE_ATTACK)
			e3:SetValue(atk)
			c:RegisterEffect(e3)
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetReset(res,resct)
			e4:SetCode(EFFECT_SET_BASE_DEFENSE)
			e4:SetValue(def)
			c:RegisterEffect(e4)
			if not tc:IsType(TYPE_TRAPMONSTER) then
				if ctlm then
					cm.CopyEffectExtraCount(c,ctlm,code,res,resct)
				else
					c:CopyEffect(code,res,resct)
				end
			end
			if ht then
				Duel.Hint(HINT_CARD,0,code)
			end
		end
		return cid
end
--copyeffect with extra count limit
function cm.CopyEffectExtraCount(c,ctlm,code,res,resct)
	if not ctlm then return c:CopyEffect(code,res,resct) end
	local et={}
	local ef=Effect.SetCountLimit
	local rf=Card.RegisterEffect
	Effect.SetCountLimit=cm.replace_set_count_limit(et)
	Card.RegisterEffect=cm.replace_register_effect(et,ctlm,ef,rf)
	c:RegisterFlagEffect(37564768,res,0,resct,ctlm)
	local cid=c:CopyEffect(code,res,resct)
	Effect.SetCountLimit=ef
	Card.RegisterEffect=rf
	c:ResetFlagEffect(37564768)
	return cid
end
function cm.replace_set_count_limit(et)
return function(e,ct,cd)
	et[e]={ct,cd}
end
end
function cm.replace_register_effect(et,ctlm,ef,rf)
return function(c,e,forced)
	local t=et[e]   
	if t then
		if e:IsHasType(0x7e0) then
			t[1]=math.max(t[1],ctlm)
		end
		ef(e,table.unpack(t))
	end
	rf(c,e,forced)
end
end

--universals for sww

--swwss(ct=discount exf=extra function)
function cm.sww(c,ct,ctxm,ctsm,exf)
	--cm.setreg(c,nil,37564299)
	if ctxm then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
	if ctsm then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetValue(1)
		c:RegisterEffect(e3)
	end
	--ss
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(37564765,0)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e4:SetCost(cm.swwsscost(ct,exf))
	e4:SetTarget(cm.swwsstg)
	e4:SetOperation(cm.swwssop)
	c:RegisterEffect(e4)
	return e4
end
function cm.swwsscost(ct,exf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
			   if e:GetHandler():IsLocation(LOCATION_HAND) and Duel.IsPlayerAffectedByEffect(tp,37564218) then return true end
			   if chk==0 then return Duel.IsExistingMatchingCard(cm.swwssfilter,tp,LOCATION_HAND,0,ct,e:GetHandler(),e,exf) end
			   Duel.DiscardHand(tp,cm.swwssfilter,ct,ct,REASON_COST,e:GetHandler(),e,exf)
		   end
end
function cm.swwsstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.swwssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function cm.swwssfilter(c,e,exf)
	return (cm.check_set_sawawa(c) or (exf and exf(c))) and not c:IsCode(e:GetHandler():GetOriginalCode()) and c:IsAbleToGraveAsCost()
end
--for judge blank extra
function cm.swwblex(e,tp)
	tp=tp or e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,0)==0
end
--for sww rm grave
function cm.swwcostfilter(c)
	return cm.check_set_sawawa(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cm.swwrmcost(ct)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
			   if chk==0 then return Duel.IsExistingMatchingCard(cm.swwcostfilter,tp,LOCATION_GRAVE,0,ct,nil) end
			   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			   local g=Duel.SelectMatchingCard(tp,cm.swwcostfilter,tp,LOCATION_GRAVE,0,ct,ct,nil)
			   Duel.Remove(g,POS_FACEUP,REASON_COST)
		   end
end

--universals for bm

--bmss ctg=category istg=is-target-effect

function cm.bm(c,tg,op,istg,ctg)
	--cm.setreg(c,nil,37564573)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37564765,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET) 
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCost(cm.bmssct(c:GetOriginalCode()))
	e4:SetTarget(cm.bmsstg)
	e4:SetOperation(cm.bmssop)
	c:RegisterEffect(e4)
	local e1=nil
	if op then
		e1=Effect.CreateEffect(c)
		if ctg then e1:SetCategory(ctg) end
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)  
		if istg then
			e1:SetProperty(EFFECT_FLAG_CARD_TARGET+cm.delay)
		else
			e1:SetProperty(cm.delay)
		end
		e1:SetCondition(cm.bmsscon)
		if tg then e1:SetTarget(tg) end
		e1:SetOperation(op)
		c:RegisterEffect(e1)
	end
	return e1
end
function cm.bmssfilter(c)
   return c:IsAbleToHand() and cm.bmchkfilter(c) and c:IsFaceup()
end
function cm.bmssct(cd)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if not cd then return false end
	if chk==0 then return Duel.GetFlagEffect(tp,cd)==0 end
	Duel.RegisterFlagEffect(tp,cd,RESET_PHASE+PHASE_END,0,1)
end
end
function cm.bmsstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cm.bmssfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingTarget(cm.bmssfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cm.bmssfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function cm.bmssop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			if Duel.SpecialSummonStep(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP) then
				e:GetHandler():RegisterFlagEffect(37564499,RESET_EVENT+0x1fe0000,0,1)
				Duel.SpecialSummonComplete()
			end
		end
	end
end
function cm.bmsscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(37564499)>0
end
--check if is bm
function cm.bmchkfilter(c)
	return cm.check_set_prism(c) and c:IsType(TYPE_MONSTER)
end
--damage chk for bm
--1=remove 2=extraattack 3=atk3000 4=draw
function cm.bmdamchkop(e,tp,eg,ep,ev,re,r,rp)
local ct=e:GetLabel()
local c=e:GetHandler()
local bc=c:GetBattleTarget()
if ct==0 then return end
if c:IsRelateToEffect(e) and c:IsFaceup() then
	Duel.ConfirmDecktop(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct)
	local ag=g:Filter(cm.bmchkfilter,nil)
	if ag:GetCount()>0 then
		local val={0}
		for tc in aux.Next(ag) do
			val[1]=val[1]+tc:GetTextAttack()
			if tc.bm_check_operation and (not tc.bm_check_condition or tc.bm_check_condition(e,tp,eg,ep,ev,re,r,rp)) then
				Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
				tc.bm_check_operation(e,tp,eg,ep,ev,re,r,rp,val)
			end
		end
		if val[1]>0 and c:IsRelateToBattle() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(0x1fe1000+RESET_PHASE+PHASE_DAMAGE_CAL)
			e1:SetValue(val[1])
			c:RegisterEffect(e1)
		end
		if Duel.SelectYesNo(tp,aux.Stringid(37564765,2)) then
			local thg=ag:Filter(cm.adfilter,nil)
			if thg:GetCount()>0 then
				local thc=thg:Select(tp,1,1,nil)
				Duel.SendtoHand(thc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,thc)
			end
		end
	end
	Duel.ShuffleDeck(tp)
end
end
function cm.adfilter(c)
	return c:IsAbleToHand() and c:IsLocation(LOCATION_DECK)
end
--bm attack oppolimit
function cm.bmdamchk(c,lm)
	local e2=nil
	if lm then
	e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(cm.bmaclimit)
	e2:SetCondition(cm.bmactcon)
	c:RegisterEffect(e2)
	end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(cm.bmexat)
	c:RegisterEffect(e4)
	return e4,e2
end
function cm.bmaclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function cm.bmactcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function cm.bmexat(e,c)
	return c:GetFlagEffect(37564498)
end
--for condition of damchk
function cm.bmdamchkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
--for cost of rmex
function cm.bmrmcostfilter(c)
	return cm.bmchkfilter(c) and c:IsAbleToRemoveAsCost()
end
function cm.bmrmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.bmrmcostfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.bmrmcostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)

end
--for release bm L5
--fr=must be ssed
function cm.bmrl(c,fr)
	--cm.setreg(c,nil,37564573)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37564765,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cm.bmrlcon)
	e1:SetOperation(cm.bmrlop)
	c:RegisterEffect(e1)
	if fr then
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+  EFFECT_FLAG_UNCOPYABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SPSUMMON_CONDITION)
		c:RegisterEffect(e2)
	end
	return e1
end
function cm.bmrlcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1 and Duel.CheckReleaseGroup(tp,cm.bmchkfilter,1,nil)
end
function cm.bmrlop(e,tp,eg,ep,ev,re,r,rp,c)
	local tp=c:GetControler()
	local g=Duel.SelectReleaseGroup(tp,cm.bmchkfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
--xyz monster atk drain effect
--con(usual)=condition tg(battledcard,card)=filter
--cost=cost
--xm=drain mat
function cm.atkdr(c,con,tg,cost,ctlm,ctlmid,xm)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_START)
	if ctlm then e5:SetCountLimit(ctlm,ctlmid) end
	e5:SetCondition(cm.atkdrcon(con,tg))
	if cost then e5:SetCost(cost) end
	e5:SetTarget(cm.atkdrtg)
	e5:SetOperation(cm.atkdrop(xm))
	c:RegisterEffect(e5)
end
function cm.atkdrcon(con,tg)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local bc=c:GetBattleTarget()
		return (not con or con(e,tp,eg,ep,ev,re,r,rp)) and bc and (not tg or tg(bc,c)) and not bc:IsType(TYPE_TOKEN) and bc:IsAbleToChangeControler()
	end
end
function cm.atkdrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
end
function cm.atkdrop(xm)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local tc=c:GetBattleTarget()
		if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
			cm.overlaycard(c,tc,xm)
		end
	end
end
--nanahira parts
function cm.nnhr(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e2:SetValue(37564765)
	c:RegisterEffect(e2)
end
function cm.nnhrp(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e2:SetValue(37564765)
	c:RegisterEffect(e2)
	local e6=e2:Clone()
	e6:SetRange(LOCATION_PZONE)
	c:RegisterEffect(e6)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(cm.desc(8))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,10000000)
	e1:SetCondition(cm.PendConditionNanahira())
	e1:SetOperation(cm.PendOperationNanahira())
	e1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(e1)
	--register by default
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(1160)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	c:RegisterEffect(e2)
end
function cm.nnhrexp(c,scon)
	cm.nnhrp(c)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNSUMMONABLE_CARD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_REVIVE_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(function(e)
		if e:GetHandler():IsLocation(LOCATION_EXTRA) and e:GetHandler():IsFaceup() then return false end
		return true
	end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(function(e,se,sp,st)
		if scon and not scon(e,se,sp,st) then return false end
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_FUSION) and bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION then return false end
		return c:IsHasEffect(EFFECT_REVIVE_LIMIT) or c:IsStatus(STATUS_PROC_COMPLETE) or bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
	end)
	c:RegisterEffect(e2)
end
function cm.PConditionFilterNanahira(c,e,tp,lscale,rscale,f,te)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	return lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)
		and not c:IsForbidden() and (not f or f(c,te))
end
function cm.PConditionFilterExtra(c)
	return c:IsHasEffect(37564541) and c.pendulum_info
end
function cm.PendConditionNanahira()
	return  function(e,c,og)
				if c==nil then return true end
				local tp=c:GetControler()
				if c:GetSequence()~=6 then return false end
				local rpz=Duel.GetFieldCard(tp,LOCATION_SZONE,7)
				if rpz==nil then return false end
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				if ft<=0 then return false end
				local g=nil
				if og then
					g=og:Filter(aux.PConditionFilter,1,nil,e,tp,lscale,rscale)
				else
					g=Duel.GetMatchingGroup(aux.PConditionFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,e,tp,lscale,rscale)
				end
				if Card.GetAffectingEffect then
					local ext={c:GetAffectingEffect(37564541),rpz:GetAffectingEffect(37564541)}
					for i,te in pairs(ext) do
						local t=cm.order_table[te:GetValue()]
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te)
						g:Merge(exg)
					end
				else
					local cg=Group.FromCards(c,rpz):Filter(cm.PConditionFilterExtra,nil)
					for tc in aux.Next(cg) do
						local t=tc.pendulum_info
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te)
						g:Merge(exg)
					end
				end
				return g:GetCount()>0
			end
end
function cm.PendOperationNanahira()
	return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
				local rpz=Duel.GetFieldCard(tp,LOCATION_SZONE,7)
				local lscale=c:GetLeftScale()
				local rscale=rpz:GetRightScale()
				if lscale>rscale then lscale,rscale=rscale,lscale end
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
				local tg=nil
				local maxlist={}
				if og then
					tg=og:Filter(aux.PConditionFilter,1,nil,e,tp,lscale,rscale)
				else
					tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil,e,tp,lscale,rscale)
				end
				if Card.GetAffectingEffect then
					local ext={c:GetAffectingEffect(37564541),rpz:GetAffectingEffect(37564541)}
					for i,te in pairs(ext) do
						local t=cm.order_table[te:GetValue()]
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te)
						tg:Merge(exg)
						local mct=t.max_count
						if mct and mct>0 and mct<ft then
							maxlist[t.location]=mct
						end
					end
				else
					local cg=Group.FromCards(c,rpz):Filter(cm.PConditionFilterExtra,nil)
					for tc in aux.Next(cg) do
						local t=tc.pendulum_info
						local exg=Duel.GetMatchingGroup(cm.PConditionFilterNanahira,tp,t.location,0,nil,e,tp,lscale,rscale,t.filter,te)
						tg:Merge(exg)
						local mct=t.max_count
						if mct and mct>0 and mct<ft then
							maxlist[t.location]=mct
						end
					end
				end
				local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
				if ect and ect>0 and ect<ft and (not maxlist[LOCATION_EXTRA] or maxlist[LOCATION_EXTRA]>ect) then
					 maxlist[LOCATION_EXTRA]=ect
				end
				local exit_permit=false
				repeat
					local ct=ft
					for loc,lct in pairs(maxlist) do
						if tg:FilterCount(Card.IsLocation,nil,loc)>0 and lct>0 then ct=math.min(ct,lct) end
					end
					if ct==ft then exit_permit=true end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=tg:Select(tp,1,ct,nil)
					tg:Sub(g)
					sg:Merge(g)
					ft=ft-g:GetCount()
					for loc,lct in pairs(maxlist) do
						local remain=lct-g:FilterCount(Card.IsLocation,nil,loc)
						maxlist[loc]=remain
						if remain<=0 then
							tg:Remove(Card.IsLocation,nil,loc)
						end
					end
				until ft==0 or tg:GetCount()==0 or exit_permit or not Duel.SelectYesNo(tp,210)
				Duel.HintSelection(Group.FromCards(c))
				Duel.HintSelection(Group.FromCards(rpz))
			end
end
function cm.nnexpcon(e)
	local seq=e:GetHandler():GetSequence()
	local tc=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_SZONE,13-seq)
	return tc and tc.desc_with_nanahira
end
function cm.nncon(og)
return function(e,tp)
	tp=tp or e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(cm.nnfilter,tp,LOCATION_ONFIELD,0,1,nil,og)
end
end
function cm.nnfilter(c,og)
	if not c:IsFaceup() then return false end
	return c:GetOriginalCode()==37564765 or (c:IsCode(37564765) and not og)
end
function cm.nnhrset(c,setcd)
	cm.nnhr(c)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_ONFIELD+LOCATION_GRAVE)
	e5:SetCondition(function(e)
		return e:GetHandler():IsCode(37564765)
	end)
	e5:SetCode(setcd)
	c:RegisterEffect(e5)
	return e5
end
function cm.nntrap(c,...)
	local t={...}
	for i,te in pairs(t) do
		local e1=te:Clone()
		if te:GetDescription()==0 then
			e1:SetDescription(37564553*16)
		end
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetRange(LOCATION_MZONE)
		if te:GetCode()==EVENT_FREE_CHAIN then
			e1:SetHintTiming(0x1e0)
		end
		e1:SetCost(cm.serlcost)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
			if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
			return bit.band(e:GetHandler():GetSummonType(),0x553)==0x553
		end)
		local op=te:GetOperation()
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			e:GetHandler():ReleaseEffectRelation(e)
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end)
		c:RegisterEffect(e1)
	end
end
--for infinity negate effect
function cm.neg(c,lmct,lmcd,cost,excon,exop,loc,force)
	local e3=Effect.CreateEffect(c)
	local loc=loc or LOCATION_MZONE
	e3:SetDescription(aux.Stringid(37564765,5))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	if force then
		e3:SetType(EFFECT_TYPE_QUICK_F)
	else
		e3:SetType(EFFECT_TYPE_QUICK_O)
	end
	e3:SetCode(EVENT_CHAINING)
	if lmct then e3:SetCountLimit(lmct,lmcd) end
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(loc)
	e3:SetCondition(cm.negcon(excon))
	if cost then e3:SetCost(cost) end
	e3:SetTarget(cm.negtg)
	e3:SetOperation(cm.negop(exop))
	c:RegisterEffect(e3)
	return e3
end
function cm.negcon(excon)
return function(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cm.negop(exop)
return function(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		if exop then
			exop(e,tp,eg,ep,ev,re,r,rp)
		end
	end   
end
end
function cm.negtrap(c,lmct,lmcd,cost,excon,exop)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(lmct,lmcd)
	e1:SetCondition(cm.negcon(excon))
	if cost then e1:SetCost(cost) end
	e1:SetTarget(cm.negtg)
	e1:SetOperation(cm.negop(exop))
	c:RegisterEffect(e1)
	return e1
end
function cm.drawtg(ct)
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
end
function cm.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function cm.prsyfilter(c)
	return cm.check_set_prim(c) and c:IsType(TYPE_SYNCHRO)
end
function cm.prl4(c,cd)
	aux.AddSynchroProcedure(c,nil,cm.check_set_prim,1)
	c:EnableReviveLimit()
end
function cm.xmcon(ct,excon)
return function(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>=ct and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
end
end
--counter summon effect universals
--n=normal f=flip s=special o=opponent only
function cm.negs(c,tpcode,ctlm,ctlmid,con,cost)
	if not tpcode or bit.band(tpcode,7)==0 then return end
	ctlmid=ctlmid or 1
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37564765,4))
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON)
	if ctlm then e3:SetCountLimit(ctlm,ctlmid) end
	if bit.band(tpcode,8)==8 then
		e3:SetLabel(2)
	else
		e3:SetLabel(1)
	end
	e3:SetCondition(cm.negsdiscon(con))
	if cost then e3:SetCost(cost) end
	e3:SetTarget(cm.negsdistg)
	e3:SetOperation(cm.negsdisop)
	local e2=e3:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	local e1=e3:Clone()
	e1:SetCode(EVENT_SUMMON)
	local t={}
	if bit.band(tpcode,1)==1 then
		c:RegisterEffect(e1)
		table.insert(t,e1)
	end
	if bit.band(tpcode,2)==2 then
		c:RegisterEffect(e2)
		table.insert(t,e2)
	end
	if bit.band(tpcode,4)==4 then
		c:RegisterEffect(e3)
		table.insert(t,e3)
	end
	return table.unpack(t)
end
function cm.negsfilter(c,tp,e)
	return c:GetSummonPlayer()==tp or e:GetLabel()==1
end
function cm.negsdiscon(con)
return function(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0 and eg:IsExists(cm.negsfilter,1,nil,e,1-tp) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.negsdistg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(cm.filter,nil,e,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function cm.negsdisop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(cm.negsfilter,nil,e,1-tp)
	Duel.NegateSummon(g)
	Duel.Destroy(g,REASON_EFFECT)
end
--for copying spell
function cm.scopy(c,loc1,loc2,f,con,cost,ctlm,ctlmid,eloc,x)
	local e2=Effect.CreateEffect(c)
	eloc=eloc or LOCATION_MZONE
	ctlmid=ctlmid or 1
	e2:SetDescription(aux.Stringid(37564765,6))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(eloc)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0x3c0)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	if ctlm then e2:SetCountLimit(ctlm,ctlmid) end
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.CheckEvent(EVENT_CHAINING) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
	end)
	e2:SetCost(cm.fbdcost(cost))
	e2:SetTarget(cm.scopytg1(loc1,loc2,f,x))
	e2:SetOperation(cm.scopyop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37564765,6))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	if ctlm then e3:SetCountLimit(ctlm,ctlmid) end
	e3:SetCost(cm.fbdcost(cost))
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not con or con(e,tp,eg,ep,ev,re,r,rp)
	end)
	e3:SetTarget(cm.scopytg2(loc1,loc2,f,x))
	e3:SetOperation(cm.scopyop)
	c:RegisterEffect(e3)
	return e2,e3
end
function cm.fbdcost(costf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		e:SetLabel(1)
		if not costf then return true end
		return costf(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function cm.scopyf1(c,f,e,tp)
	return (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY
		or c:GetType()==TYPE_TRAP or c:GetType()==TYPE_TRAP+TYPE_COUNTER) 
		and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false) and (not f or f(c,e,tp))
end
function cm.scopytg1(loc1,loc2,f,x)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local og=Duel.GetFieldGroup(tp,loc1,loc2)
	if x then og:Merge(e:GetHandler():GetOverlayGroup()) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return og:IsExists(cm.scopyf1,1,nil,f,e,tp)
	end
	e:SetLabel(te:GetLabel())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=og:FilterSelect(tp,cm.scopyf1,1,1,nil,f,e,tp)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
end
end
function cm.scopyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if te:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:GetHandler():ReleaseEffectRelation(e)
	end
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function cm.scopyf2(c,e,tp,eg,ep,ev,re,r,rp,f)
	if (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY
		or c:GetType()==TYPE_TRAP or c:GetType()==TYPE_TRAP+TYPE_COUNTER) and c:IsAbleToRemoveAsCost() and (not f or f(c,e,tp,eg,ep,ev,re,r,rp)) then
		if c:CheckActivateEffect(true,true,false) then return true end
		local te=c:GetActivateEffect()
		if te:GetCode()~=EVENT_CHAINING then return false end
		local tg=te:GetTarget()
		if tg and not tg(e,tp,eg,ep,ev,re,r,rp,0) then return false end
		return true
	else return false end
end
function cm.scopytg2(loc1,loc2,f,x)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local og=Duel.GetFieldGroup(tp,loc1,loc2)
	if x then og:Merge(e:GetHandler():GetOverlayGroup()) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return og:IsExists(cm.scopyf2,1,nil,e,tp,eg,ep,ev,re,r,rp,f)
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=og:FilterSelect(tp,cm.scopyf2,1,1,nil,e,tp,eg,ep,ev,re,r,rp,f)
	local tc=g:GetFirst()
	local te,ceg,cep,cev,cre,cr,crp
	local fchain=cm.scopyf1(tc)
	if fchain then
		te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(true,true,true)
	else
		te=tc:GetActivateEffect()
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then
		if fchain then
			tg(e,tp,ceg,cep,cev,cre,cr,crp,1)
		else
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
end
end
function cm.icopy(c,lmct,lmcd,cost,excon,loc)
	local e3=Effect.CreateEffect(c)
	loc=loc or LOCATION_MZONE
	e3:SetDescription(aux.Stringid(37564765,7))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	if lmct then e3:SetCountLimit(lmct,lmcd) end
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(loc)
	e3:SetCondition(cm.iccon(excon))
	e3:SetCost(cm.fbdcost(cost))
	e3:SetTarget(cm.ictg)
	e3:SetOperation(cm.scopyop)
	c:RegisterEffect(e3)
	return e3
end
function cm.iccon(excon)
return function(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.ictg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local te=re:Clone()
	local tg=te:GetTarget()
	local code=te:GetCode()
	local tres,teg,tep,tev,tre,tr,trp
	if code>0 and code~=EVENT_FREE_CHAIN and code~=EVENT_CHAINING and Duel.CheckEvent(code) then
		tres,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(code,true)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		local res=false
		if not tg then return true end
		if not pcall(function()
			if tres then res=tg(e,tp,teg,tep,tev,tre,tr,trp,0)
			else res=tg(e,tp,eg,ep,ev,re,r,rp,0) end
		end) then return false end
		return res
	end
	e:SetLabel(0)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	if tg then
		if tres then
			tg(e,tp,teg,tep,tev,tre,tr,trp,1)
		else
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	local ex=Effect.GlobalEffect()
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_CHAIN_END)
	ex:SetLabelObject(e)
	ex:SetOperation(function()
		e:SetLabel(0)
		ex:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
function cm.cneg(c,con,cost,exop,desc,des,loc)
	local e3=Effect.CreateEffect(c)
	loc=loc or LOCATION_MZONE
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(loc)
	e3:SetCondition(cm.cnegcon(con))
	e3:SetOperation(cm.cnegop(cost,exop,desc,des))
	c:RegisterEffect(e3)
	return e3
end
function cm.cnegcon(con)
return function(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainDisablable(ev) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.cnegop(cost,exop,desc,des)
return function(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,desc) then return end
	Duel.Hint(HINT_CARD,0,e:GetHandler():GetOriginalCode())
	if cost then cost(e,tp,eg,ep,ev,re,r,rp) end
	local chk=Duel.NegateEffect(ev)
	if re:GetHandler():IsRelateToEffect(re) and des then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
	if chk and exop then
		exop(e,tp,eg,ep,ev,re,r,rp)
	end
end
end
--3L fusion monster, c=card, m=code
--exf=extra function
function cm.lfus(c,m,exf,...)
	cm.enable_kaguya_check_3L()
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	--cm.setreg(c,m,37564800)
	c:EnableReviveLimit()
	local mt=cm.load_metatable(m)
	local att=mt.fusion_att_3L
	local ext_params={...}
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(cm.lfuscon(att,exf,ext_params))
	e1:SetOperation(cm.lfusop(att,exf,ext_params))
	c:RegisterEffect(e1)
end
function cm.lattf(att,exf,ext_params)
return function(c)
	if c:IsHasEffect(6205579) then return false end
	if exf and not exf(c,table.unpack(ext_params)) then return false end
	if not att then return true end
	return cm.attf(c,att) or c:IsHasEffect(37564828)
end
end
function cm.lchkffilter(c,f,chkf,fs)
	if f and not f(c) then return false end
	return fs or aux.FConditionCheckF(c,chkf)
end
function cm.filter_suika(c,ec,chkfnf)
	if bit.band(chkfnf,0x100)~=0 then return false end
	--for checking izayoi (no extra materials)
	return c:IsHasEffect(37564841) and c:IsFaceup() and c:IsCanBeFusionMaterial(ec)
end
function cm.filter_sayuri_3L(c,ec,chkfnf)
	if bit.band(chkfnf,0x100)~=0 then return false end
	--for checking izayoi (no extra materials)
	if c:IsHasEffect(6205579) then return false end
	local chkf=bit.band(chkfnf,0xff)
	return ec:GetLevel()==7 and c:IsHasEffect(37564914) and c:IsCanBeFusionMaterial(ec) and (chkf==PLAYER_NONE or aux.FConditionCheckF(c,chkf))
end
function cm.lfuscheck_gc(mg,gc,f1,f2,chkf)
	local fs=(chkf==PLAYER_NONE or aux.FConditionCheckF(gc,chkf))
	return (f1(gc) and mg:IsExists(cm.lchkffilter,1,gc,f2,chkf,fs)) or (f2(gc) and mg:IsExists(cm.lchkffilter,1,gc,f1,chkf,fs))
end
function cm.lfuscheck(mg,f1,f2,chkf)
	local g1=Group.CreateGroup() local g2=Group.CreateGroup() local fs=false
	for tc in aux.Next(mg) do
		if f1(tc) then g1:AddCard(tc) if aux.FConditionCheckF(tc,chkf) then fs=true end end
		if f2(tc) then g2:AddCard(tc) if aux.FConditionCheckF(tc,chkf) then fs=true end end
	end
	if chkf~=PLAYER_NONE then
		return fs and g1:IsExists(aux.FConditionFilterF2,1,nil,g2)
	else return g1:IsExists(aux.FConditionFilterF2,1,nil,g2) end
end
function cm.lfuscon(att,exf,ext_params)
return function(e,g,gc,chkfnf)
	if g==nil then return true end
	local f1=cm.check_fusion_set_3L
	local f2=cm.lattf(att,exf,ext_params)
	local chkf=bit.band(chkfnf,0xff)
	local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local tp=e:GetHandlerPlayer()
	local exg=Duel.GetMatchingGroup(cm.filter_suika,tp,0,LOCATION_MZONE,nil,e:GetHandler(),chkfnf)
	mg:Merge(exg)
	if gc then
		if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
		return cm.lfuscheck_gc(mg,gc,f1,f2,chkf) or cm.filter_sayuri_3L(gc,e:GetHandler(),chkfnf)
	end
	return cm.lfuscheck(mg,f1,f2,chkf) or mg:IsExists(cm.filter_sayuri_3L,1,nil,e:GetHandler(),chkfnf)
end
end
function cm.lfusop(att,exf,ext_params)
return function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
	local f1=cm.check_fusion_set_3L
	local f2=cm.lattf(att,exf,ext_params)
	local chkf=bit.band(chkfnf,0xff)
	local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local exg=Duel.GetMatchingGroup(cm.filter_suika,tp,0,LOCATION_MZONE,nil,e:GetHandler(),chkfnf)
	g:Merge(exg)
	if gc then
		if cm.filter_sayuri_3L(gc,e:GetHandler(),chkfnf) and (not cm.lfuscheck_gc(g,gc,f1,f2,chkf) or Duel.SelectYesNo(tp,37564914*16)) then
			Duel.SetFusionMaterial(Group.FromCards(gc))
			return
		end
		local fs=(chkf==PLAYER_NONE or aux.FConditionCheckF(gc,chkf))
		local sg=Group.CreateGroup()
		if f1(gc) then sg:Merge(g:Filter(f2,gc)) end
		if f2(gc) then sg:Merge(g:Filter(f1,gc)) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=sg:FilterSelect(tp,cm.lchkffilter,1,1,nil,nil,chkf,fs)
		Duel.SetFusionMaterial(g1)
		return
	end
	if g:IsExists(cm.filter_sayuri_3L,1,nil,e:GetHandler(),chkfnf) and (not cm.lfuscheck(g,f1,f2,chkf) or Duel.SelectYesNo(tp,37564914*16)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=g:FilterSelect(tp,cm.filter_sayuri_3L,1,1,nil,e:GetHandler(),chkfnf)
		Duel.SetFusionMaterial(g1)
		return
	end
	local sg=g:Filter(aux.FConditionFilterF2c,nil,f1,f2)
	local g1=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	if chkf~=PLAYER_NONE then
		g1=sg:FilterSelect(tp,aux.FConditionCheckF,1,1,nil,chkf)
	else g1=sg:Select(tp,1,1,nil) end
	local tc1=g1:GetFirst()
	sg:RemoveCard(tc1)
	local b1=f1(tc1)
	local b2=f2(tc1)
	if b1 and not b2 then sg:Remove(aux.FConditionFilterF2r,nil,f1,f2) end
	if b2 and not b1 then sg:Remove(aux.FConditionFilterF2r,nil,f2,f1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g2=sg:Select(tp,1,1,nil)
	g1:Merge(g2)
	Duel.SetFusionMaterial(g1)
end
end
function cm.attf(c,att)
	local f=Card.IsFusionAttribute or Card.IsAttribute
	return f(c,att)
end
function cm.tpf(c,tp)
	local f=Card.IsFusionType or Card.IsType
	return f(c,tp)
end
--for 3L*N or custom fusion condition* cc ~ mcc
function cm.lfusm(c,f,cc,mcc)
	cm.enable_kaguya_check_3L()
	if c:IsStatus(STATUS_COPYING_EFFECT) then return end
	local f=f or cm.check_fusion_set_3L
	local mcc=mcc or cc
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(cm.lfusmcon(f,cc,mcc))
	e1:SetOperation(cm.lfusmop(f,cc,mcc))
	c:RegisterEffect(e1)
end
function cm.lfusmcheck_gc(mg,gc,f,cc,mcc,chkf)
	if not f(gc) then return false end
	local fs=(chkf==PLAYER_NONE or aux.FConditionCheckF(gc,chkf))
	local g1=mg:Filter(f,gc)
	if g1:GetCount()<cc-1 then return false end
	if cc==1 and not fs then
		return mcc>1 and g1:IsExists(aux.FConditionCheckF,1,nil,chkf)
	end
	return fs or g1:IsExists(aux.FConditionCheckF,1,nil,chkf)   
end
function cm.lfusmcheck(mg,f,cc,mcc,chkf)
	local g1=mg:Filter(f,nil)
		if chkf~=PLAYER_NONE then
			return g1:IsExists(aux.FConditionCheckF,1,nil,chkf) and g1:GetCount()>=cc
		else return g1:GetCount()>=cc end 
end
function cm.lfusmcon(f,cc,mcc)
return function(e,g,gc,chkfnf)
	if g==nil then return true end
	local chkf=bit.band(chkfnf,0xff)
	local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local tp=e:GetHandlerPlayer()
	local exg=Duel.GetMatchingGroup(cm.filter_suika,tp,0,LOCATION_MZONE,nil,e:GetHandler(),chkfnf)
	mg:Merge(exg)
		if gc then
			if not gc:IsCanBeFusionMaterial(e:GetHandler()) then return false end
			return cm.lfusmcheck_gc(mg,gc,f,cc,mcc,chkf) or cm.filter_sayuri_3L(gc,e:GetHandler(),chkfnf)
		end
		return cm.lfusmcheck(mg,f,cc,mcc,chkf) or mg:IsExists(cm.filter_sayuri_3L,1,nil,e:GetHandler(),chkfnf)
end
end
function cm.lfusmop(f,cc,mcc)
return function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
	local chkf=bit.band(chkfnf,0xff)
	local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,e:GetHandler())
	local exg=Duel.GetMatchingGroup(cm.filter_suika,tp,0,LOCATION_MZONE,nil,e:GetHandler(),chkfnf)
	g:Merge(exg)
	if gc then
		if cm.filter_sayuri_3L(gc,e:GetHandler(),chkfnf) and (not cm.lfusmcheck_gc(g,gc,f,cc,mcc,chkf) or Duel.SelectYesNo(tp,37564914*16)) then
			Duel.SetFusionMaterial(Group.FromCards(gc))
			return
		end
		local fs=(chkf==PLAYER_NONE or aux.FConditionCheckF(gc,chkf))
		if fs then
			if cc>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local g1=g:FilterSelect(tp,f,cc-1,mcc-1,gc)
				Duel.SetFusionMaterial(g1)
			elseif mcc>1 and Duel.SelectYesNo(tp,210) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local g1=g:FilterSelect(tp,f,1,mcc-1,gc)
				Duel.SetFusionMaterial(g1)
			else
				Duel.SetFusionMaterial(Group.CreateGroup())
			end
			return
		end
		local sg=g:Filter(f,gc)
		if cc==1 and mcc>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local g1=sg:FilterSelect(tp,aux.FConditionCheckF,1,1,nil,chkf)
			if mcc>2 and Duel.SelectYesNo(tp,210) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local g2=sg:Select(tp,1,mcc-2,g1:GetFirst())
				g1:Merge(g2)
			end
			Duel.SetFusionMaterial(g1)
			return
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=sg:FilterSelect(tp,aux.FConditionCheckF,1,1,nil,chkf)  
		if cc>2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local g2=sg:Select(tp,cc-2,mcc-2,g1:GetFirst())
			g1:Merge(g2)
		elseif mcc>2 and Duel.SelectYesNo(tp,210) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local g2=sg:Select(tp,1,mcc-2,g1:GetFirst())
			g1:Merge(g2)
		end
		Duel.SetFusionMaterial(g1)
		return
	end
	if g:IsExists(cm.filter_sayuri_3L,1,nil,e:GetHandler(),chkfnf) and (not cm.lfusmcheck(g,f,cc,mcc,chkf) or Duel.SelectYesNo(tp,37564914*16)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=g:FilterSelect(tp,cm.filter_sayuri_3L,1,1,nil,e:GetHandler(),chkfnf)
		Duel.SetFusionMaterial(g1)
		return
	end
	local sg=g:Filter(f,nil)
	if chkf==PLAYER_NONE or sg:GetCount()==cc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g1=sg:Select(tp,cc,mcc,nil)
		Duel.SetFusionMaterial(g1)
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g1=sg:FilterSelect(tp,aux.FConditionCheckF,1,1,nil,chkf)
	if cc>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g2=sg:Select(tp,cc-1,mcc-1,g1:GetFirst())
		g1:Merge(g2)
	elseif mcc>1 and Duel.SelectYesNo(tp,210) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
		local g2=sg:Select(tp,1,mcc-1,g1:GetFirst())
		g1:Merge(g2)
	end
	Duel.SetFusionMaterial(g1)
end
end
function cm.enable_kaguya_check_3L()
	if cm.kaguya_check_3L then return end
	cm.kaguya_check_3L={}
	cm.previous_chain_info={}
	cm.kaguya_check_3L[0]=0
	cm.kaguya_check_3L[1]=0
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		cm.kaguya_check_3L[ep]=cm.kaguya_check_3L[ep]+1
		if cm.kaguya_check_3L[ep]==7 then
			Duel.RaiseEvent(eg,EVENT_CUSTOM+37564829,re,r,rp,ep,ev)
		end
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		local ceg=eg:Clone()
		ceg:KeepAlive()
		cm.previous_chain_info[cid]={ceg,ep,ev,re,r,rp}
	end)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e2:SetOperation(function()
		cm.kaguya_check_3L[0]=0
		cm.kaguya_check_3L[1]=0
	end)
	Duel.RegisterEffect(e2,0)
end
function cm.leff(c,m)
	cm.enable_kaguya_check_3L()
	--cm.setreg(c,m,37564800)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return bit.band(r,REASON_FUSION)~=0
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local rc=e:GetHandler():GetReasonCard()
		if rc:GetFlagEffect(m-4000)>0 or not cm.check_set_3L(rc) then return end
		local mt=cm.load_metatable(m)
		local ctlm=rc.custom_ctlm_3L or 1
		local efft={mt.effect_operation_3L(rc,ctlm)}
		if not rc:IsType(TYPE_EFFECT) then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+0x1fe0000)
			rc:RegisterEffect(e2,true)
		end
		rc:RegisterFlagEffect(m-4000,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,cm.order_table_new(efft),m*16+1)
	end)
	c:RegisterEffect(e2)
	return e2
end
--filter for effect gaining
--chkc=card to check if it can gain c's effect, nil for not checking
function cm.lefffilter(c,chkc)
	local cd=c:GetOriginalCode()
	local mt=cm.load_metatable(cd)
	return cm.check_set_3L(c) and c:IsType(TYPE_MONSTER) and mt and mt.effect_operation_3L and (not chkc or chkc:GetFlagEffect(cd-4000)==0)
end
--3L get effect by other cards
--c=target_card, tc=source_card/code, pres=reset on the next turn, pctlm=count_limit(before custom_ctlm_3L)
function cm.lgeff(c,tc,pres,pctlm)
	local cd=0
	if type(tc)=="number" then
		cd=tc
	else
		cd=tc:GetOriginalCode()
	end
	local mt=cm.load_metatable(cd)
	if not mt or c:GetFlagEffect(cd-4000)>0 or not mt.effect_operation_3L then return end
	local ctlm=pctlm or c.custom_ctlm_3L or 1
	local efft={mt.effect_operation_3L(c,ctlm)}
	c:RegisterFlagEffect(cd-4000,RESET_EVENT+0x1fe0000,EFFECT_FLAG_CLIENT_HINT,1,cm.order_table_new(efft),cd*16+1)
	if pres then
		local info_list={
			elist=efft,
			code=cd,
		}
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(pres)
		e1:SetCondition(function(e)
			local tc=e:GetOwner()
			local effm=tc:GetFlagEffectLabel(info_list.code-4000)
			if not effm then e:Reset() return false end
			local efft=cm.order_table[effm]
			if efft~=info_list.elist then e:Reset() return false end
			return true
		end)
		e1:SetOperation(function(e)
			local tct=e:GetLabel()-1
			if tct>0 then
				e:SetLabel(tct)
			else
				cm.lreseff(e:GetOwner(),info_list.code)
				e:Reset()
			end
		end)
		Duel.RegisterEffect(e1,c:GetControler())
	end
	return efft
end
function cm.lgetcdfilter(c,ec)
	local cd=c:GetOriginalCode()
	local mt=cm.load_metatable(cd)
	return mt and mt.effect_operation_3L and ec:GetFlagEffect(cd-4000)>0
end
function cm.lrmefffilter(c,code)
	return c:GetOriginalCode()==code
end
--create the codelist for checking effects
if not cm.codelist_3L then
	cm.codelist_3L={37564519,37564914}
	for i=37564800,37564899 do
		table.insert(cm.codelist_3L,i)
	end
end
--returns a table, which shows all the codes the effect tc gets
function cm.lgetcd(tc)
	local t={}
	for i,code in pairs(cm.codelist_3L) do
		if tc:GetFlagEffect(code-4000)>0 then
			table.insert(t,code)
		end
	end
	return t
end
--returns the effect_count of the effect tc gets
function cm.lgetct(tc)
	local t=cm.lgetcd(tc)
	local v=0
	for i,cd in pairs(t) do
		local mt=cm.load_metatable(cd)
		local mct=mt.custom_effect_count_3L or 1
		v=v+mct
	end
	return v
end
--reset gained effect from 3L
function cm.lreseff(tc,code)
	local effm=tc:GetFlagEffectLabel(code-4000)
	if not effm then return false end
	local mt=cm.load_metatable(code)
	Duel.Hint(tc:GetControler(),HINT_OPSELECTED,cm.desc(10))
	local efft=cm.order_table[effm]
	for i,te in pairs(efft) do
		if mt and mt.reset_operation_3L and mt.reset_operation_3L[i] then
			mt.reset_operation_3L[i](te,tc)
		end
		te:Reset()
	end
	tc:ResetFlagEffect(code-4000)
	return true
end
--remove ct~maxct of the effect(s) from 3L
--[...]shows the code omitted
function cm.lrmeff(tp,tc,ct,maxct,chk,...)
	local maxct=maxct or ct
	local effect_list=cm.lgetcd(tc)
	local avaliable_list={}
	local omit_list={...}
	if Card.GetAffectingEffect then
		local oe=tc:GetAffectingEffect(37564827)
		if oe then
			local of=cm.order_table[oe:GetValue()]
			local og=of(tc)
			for oc in aux.Next(og) do
				table.insert(omit_list,oc:GetOriginalCode())
			end
		end
	elseif tc:IsHasEffect(37564827) and tc.omit_group_3L then
		local og=tc:omit_group_3L()
		for oc in aux.Next(og) do
			table.insert(omit_list,oc:GetOriginalCode())
		end
	end
	for i,code in pairs(effect_list) do
		local res=true
		for j,ocode in pairs(omit_list) do
			if code==ocode then res=false end
		end
		if res then table.insert(avaliable_list,i) end  
	end
	if chk then return #avaliable_list>=ct end
	local result_count=0
	while #avaliable_list>0 and result_count<maxct and not (result_count>=ct and not Duel.SelectYesNo(tp,210)) do
		local option_list={}
		for i,v in pairs(avaliable_list) do
			local descid=1
			local ccode=effect_list[v]
			local mt=cm.load_metatable(ccode)
			local effct=mt.custom_effect_count_3L
			if effct and effct>1 then descid=effct+1 end
			table.insert(option_list,aux.Stringid(ccode,descid))
		end
		Duel.Hint(HINT_SELECTMSG,tp,cm.desc(9))
		local option=table.remove(avaliable_list,Duel.SelectOption(tp,table.unpack(option_list))+1)
		cm.lreseff(tc,effect_list[option])
		result_count=result_count+1
	end
	return result_count
end
--cost for self removing effect
--... stands for omit codes
function cm.lsermeffcost(ct,...)
local omit_list={...}
return function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetHandler():IsHasEffect(37564827) then return false end
		return cm.lrmeff(tp,e:GetHandler(),ct,ct,true,table.unpack(omit_list))
	end
	cm.lrmeff(tp,e:GetHandler(),ct,ct,false,table.unpack(omit_list))
end
end
function cm.selectdiff(tp,desc,g,maxatt,maxct,chkf,f,chk,...)
	local ext_params={...}
	local gg=g:Filter(cm.selectf1,nil,chkf,maxatt,f,ext_params)
	local att=maxatt
	if chk then return gg:IsExists(cm.selectf2,1,nil,g,att,1,maxct,chkf) end
	local tg=Group.CreateGroup()
	for i=1,maxct do
		Duel.Hint(HINT_SELECTMSG,tp,desc)
		local sg=gg:FilterSelect(tp,cm.selectf2,1,1,nil,g,att,i,maxct,chkf)
		att=att-bit.band(att,chkf(sg:GetFirst()))
		gg:Sub(sg)
		tg:Merge(sg)
	end
	return tg
end
function cm.selectf1(c,chkf,maxatt,f,ext_params)
	return bit.band(chkf(c),maxatt)~=0 and (not f or f(c,table.unpack(ext_params)))
end
function cm.selectf2(c,g,att,ct,maxct,chkf) 
	if bit.band(chkf(c),att)==0 then return false end
	if ct==maxct then return true end
	local cg=g:Clone()
	att=att-bit.band(att,chkf(c))
	cg:RemoveCard(c)
	return cg:IsExists(cm.selectf2,1,nil,cg,att,ct+1,maxct,chkf)
end
function cm.PreExile(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	c:RegisterEffect(e1,true)
	local t={EFFECT_CANNOT_TO_DECK,EFFECT_CANNOT_REMOVE,EFFECT_CANNOT_TO_GRAVE}
	for i,code in pairs(t) do
		local ex=e1:Clone()
		ex:SetCode(code)
		c:RegisterEffect(ex,true)
	end
	Duel.SendtoGrave(c:GetOverlayGroup(),REASON_RULE)
end
function cm.ExileCard(c)
	cm.PreExile(c)
	Duel.SendtoDeck(c,nil,-1,REASON_RULE)
	c:ResetEffect(0xfff0000,RESET_EVENT)
end
function cm.ExileGroup(g)
	for c in aux.Next(g) do
		cm.PreExile(c)
	end
	Duel.SendtoDeck(g,nil,-1,REASON_RULE)
	for c in aux.Next(g) do
		c:ResetEffect(0xfff0000,RESET_EVENT)
	end
end
function cm.desccost(costf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return (not costf or costf(e,tp,eg,ep,ev,re,r,rp,0)) end
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		if costf then costf(e,tp,eg,ep,ev,re,r,rp,1) end		
	end
end
function cm.fuscate()
	local cat=CATEGORY_FUSION_SUMMON
	if cat then return cat+CATEGORY_SPECIAL_SUMMON end
	return CATEGORY_SPECIAL_SUMMON
end
function cm.splimit(c,v,rlimit)
	if rlimit then
		c:EnableReviveLimit()
	end
	v=v or 0
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_SINGLE)
	e22:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e22:SetCode(EFFECT_SPSUMMON_CONDITION)
	e22:SetValue(v)
	c:RegisterEffect(e22)
	return e22
end
function cm.splimitcost(f,m,cost,...)
	local ext_params={...}
	Duel.AddCustomActivityCounter(m,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(f,...))
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetCustomActivityCount(m,tp,ACTIVITY_SPSUMMON)==0 and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0)) end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		e1:SetTarget(cm.splimit_filter(f,ext_params))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
	end
end
function cm.splimit_filter(f,ext_params)
	return function(e,c)
		return not f(c,table.unpack(ext_params))
	end
end
function cm.multi_choice_target(m,...)
	local function_list={...}
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then
			local pr=e:GetProperty()
			return bit.band(pr,EFFECT_FLAG_CARD_TARGET)~=0 and function_list[e:GetLabel()](e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		end
		local avaliable_list={}
		for i,tg in pairs(function_list) do
			if tg(e,tp,eg,ep,ev,re,r,rp,0) then
				table.insert(avaliable_list,i)
			end
		end
		if chk==0 then return #avaliable_list>0 end
		local option_list={}
		for i,v in pairs(avaliable_list) do
			table.insert(option_list,aux.Stringid(m,v-1))
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local option=avaliable_list[Duel.SelectOption(tp,table.unpack(option_list))+1]
		e:SetLabel(option)
		function_list[option](e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function cm.multi_choice_operation(...)
	local function_list={...}
	return function(e,tp,eg,ep,ev,re,r,rp)
		local op=function_list[e:GetLabel()]
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
--order_table system
--allows storing value of any type by Label or FlagEffectLabel
--cm.order_table_new will create a new space in cm.order_table and returns the address
--usually stores the address in Label and uses them by using the Label as the key to cm.order_table
cm.order_table=cm.order_table or {}
cm.order_count=cm.order_count or 0
function cm.order_table_new(v)
	cm.order_count=cm.order_count+1
	cm.order_table[cm.order_count]=v
	return cm.order_count
end
function cm.enable_get_all_cards()
	if not cm.get_all_cards then
		cm.get_all_cards=Group.CreateGroup()
		cm.get_all_cards:KeepAlive()
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetOperation(function()
			local g=Duel.GetFieldGroup(0,0xff,0xff)
			local g1=g:Clone()
			g:ForEach(function(tc)
				g1:Merge(tc:GetOverlayGroup())
			end)
			cm.get_all_cards:Merge(g1)
		end)
		Duel.RegisterEffect(e1,0)
		return true
	end
	return false
end
--AddFusionProcFunMulti from the newest git ut
--might be useful in some particular cards
--also included in fus.lua in thc (but without hana_mat)
function cm.AddFusionProcFunMulti(c,insf,...)
	local funs={...}
	local n=#funs
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_FUSION_MATERIAL)
	e1:SetCondition(cm.FConditionFunMulti(funs,n,insf))
	e1:SetOperation(cm.FOperationFunMulti(funs,n,insf))
	c:RegisterEffect(e1)
end
function cm.FConditionFilterMultiOr(c,funs,n)
	for i=1,n do
		if funs[i](c) then return true end
	end
	return false
end
function cm.FConditionFilterMulti(c,mg,funs,n,tbt)
	for i=1,n do
		local tp=2^(i-1)
		if bit.band(tbt,tp)~=0 and funs[i](c) then
			local t2=tbt-tp
			if t2==0 then return true end
			local mg2=mg:Clone()
			mg2:RemoveCard(c)
			if mg2:IsExists(cm.FConditionFilterMulti,1,nil,mg2,funs,n,t2) then return true end
		end
	end
	return false
end
function cm.CloneTable(g)
	local ng={}
	for i=1,#g do
		local sg=g[i]:Clone()
		table.insert(ng,sg)
	end
	return ng
end
function cm.FConditionFilterMulti2(c,gr)
	local gr2=cm.CloneTable(gr)
	for i=1,#gr2 do
		gr2[i]:RemoveCard(c)
	end
	table.remove(gr2,1)
	if #gr2==1 then
		return gr2[1]:IsExists(aux.TRUE,1,nil)
	else
		return gr2[1]:IsExists(cm.FConditionFilterMulti2,1,nil,gr2)
	end
end
function cm.FConditionFilterMultiSelect(c,funs,n,mg,sg)
	local valid=cm.FConditionFilterMultiValid(sg,funs,n)
	if not valid then valid={0} end 
	local all = (2^n)-1
	for k,v in pairs(valid) do
		v=bit.bxor(all,v)
		if cm.FConditionFilterMulti(c,mg,funs,n,v) then return true end
	end
	return false
end
function cm.FConditionFilterMultiValid(g,funs,n)
	local tp={}
	local tc=g:GetFirst()
	while tc do
		local tp1={}
		for i=1,n do
			if funs[i](tc) then table.insert(tp1,2^(i-1)) end
		end
		table.insert(tp,tp1)
		tc=g:GetNext()
	end
	return cm.FConditionMultiGenerateValids(tp,n)
end
function cm.FConditionMultiGenerateValids(vs,n)
	local c=2
	while #vs > 1 do
		local v1=vs[1]
		table.remove(vs,1)
		local v2=vs[1]
		table.remove(vs,1)
		table.insert(vs,1,cm.FConditionMultiCombine(v1,v2,n,c))
		c=c+1
	end
	return vs[1]
end
function cm.FConditionMultiCombine(t1,t2,n,c)
	local res={}
	for k1,v1 in pairs(t1) do
		for k2,v2 in pairs(t2) do
			table.insert(res,bit.bor(v1,v2))
		end
	end 
	res=cm.FConditionMultiCheckCount(res,n)
	return cm.FConditionFilterMultiClean(res)
end
function cm.FConditionMultiCheckCount(vals,n)
	local res={} local flags={}
	for k,v in pairs(vals) do
		local c=0
		for i=1,n do
			if bit.band(v,2^(i-1))~=0 then c=c+1 end
		end
		if not flags[c] then
			res[c] = {v}
			flags[c] = true
		else
			table.insert(res[c],v)
		end
	end
	local mk=0
	for k,v in pairs(flags) do
		if k>mk then mk=k end
	end
	return res[mk]
end
function cm.FConditionFilterMultiClean(vals)
	local res={} local flags={}
	for k,v in pairs(vals) do
		if not flags[v] then
			table.insert(res,v)
			flags[v] = true
		end
	end
	return res
end
function cm.FConditionFunMulti(funs,n,insf)
	return function(e,g,gc,chkfnf)
		local c=e:GetHandler()
		if g==nil then return insf end
		if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
		local chkf=bit.band(chkfnf,0xff)
		local mg=g:Filter(Card.IsCanBeFusionMaterial,nil,c):Filter(cm.FConditionFilterMultiOr,nil,funs,n)
		if gc then
			if not gc:IsCanBeFusionMaterial(c) then return false end
			local check_tot=(2^n)-1
			local mg2=mg:Clone()
			mg2:RemoveCard(gc)
			for i=1,n do
				if funs[i](gc) then
					local tbt=check_tot-2^(i-1)
					if mg2:IsExists(cm.FConditionFilterMulti,1,nil,mg2,funs,n,tbt) then return true end
				end
			end
			return false
		end
		local fs=false
		local groups={}
		for i=1,n do
			table.insert(groups,Group.CreateGroup())
		end
		local tc=mg:GetFirst()
		while tc do
			for i=1,n do
				if funs[i](tc) then
					groups[i]:AddCard(tc)
					if aux.FConditionCheckF(tc,chkf) then fs=true end
				end
			end
			tc=mg:GetNext()
		end
		local gr2=cm.CloneTable(groups)
		if chkf~=PLAYER_NONE then
			return fs and gr2[1]:IsExists(cm.FConditionFilterMulti2,1,nil,gr2)
		else
			return gr2[1]:IsExists(cm.FConditionFilterMulti2,1,nil,gr2)
		end
	end
end
function cm.FOperationFunMulti(funs,n,insf)
	return function(e,tp,eg,ep,ev,re,r,rp,gc,chkfnf)
		local c=e:GetHandler()
		local chkf=bit.band(chkfnf,0xff)
		local g=eg:Filter(Card.IsCanBeFusionMaterial,nil,c):Filter(cm.FConditionFilterMultiOr,nil,funs,n)
		if gc then
			local sg=Group.FromCards(gc)
			local mg=g:Clone()
			mg:RemoveCard(gc)
			for i=1,n-1 do
				local mg2=mg:Filter(cm.FConditionFilterMultiSelect,nil,funs,n,mg,sg)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
				local sg2=mg2:Select(tp,1,1,nil)
				sg:AddCard(sg2:GetFirst())
				mg:RemoveCard(sg2:GetFirst())
			end
			Duel.SetFusionMaterial(sg)
			return
		end
		local sg=Group.CreateGroup()
		local mg=g:Clone()
		for i=1,n do
			local mg2=mg:Filter(cm.FConditionFilterMultiSelect,nil,funs,n,mg,sg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local sg2=nil
			if i==1 and chkf~=PLAYER_NONE then
				sg2=mg2:FilterSelect(tp,aux.FConditionCheckF,1,1,nil,chkf)
			else
				sg2=mg2:Select(tp,1,1,nil)
			end
			sg:AddCard(sg2:GetFirst())
			mg:RemoveCard(sg2:GetFirst())
		end
		Duel.SetFusionMaterial(sg)
	end
end

function cm.stypecon(t,con)
return function(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),t)==t and (not con or con(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.NonImmuneFilter(c,e)
	return not c:IsImmuneToEffect(e)
end
function cm.FusionMaterialFilter(c,oppo)
	if oppo and c:IsLocation(LOCATION_ONFIELD+LOCATION_REMOVED) and c:IsFacedown() then return false end
	return c:IsCanBeFusionMaterial() and c:IsType(TYPE_MONSTER)
end
function cm.GetFusionMaterial(tp,loc,oloc,f,gc,e,...)
	local g1=Duel.GetFusionMaterial(tp)
	if loc then
		local floc=bit.band(loc,LOCATION_ONFIELD+LOCATION_HAND)
		if floc~=0 then
			g1=g1:Filter(Card.IsLocation,nil,floc)
		else
			g1:Clear()
		end
		local eloc=loc-floc
		if eloc~=0 then
			local g2=Duel.GetMatchingGroup(cm.FusionMaterialFilter,tp,eloc,0,nil)
			g1:Merge(g2)
		end
	end
	if oloc and oloc~=0 then
		local g3=Duel.GetMatchingGroup(cm.FusionMaterialFilter,tp,0,oloc,nil,true)
		g1:Merge(g3)
	end
	if f then g1=g1:Filter(f,nil,...) end
	if gc then g1:RemoveCard(gc) end
	if e then g1=g1:Filter(cm.NonImmuneFilter,nil,e) end
	return g1
end
function cm.ChainLimitCost(original_cost)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
					local effect_code=e:GetHandler():GetFlagEffectLabel(37564766)
					if chk==0 then
						if original_cost and not original_cost(e,tp,eg,ep,ev,re,r,rp,0) then return false end
						if not effect_code then return true end
						local effect_list=cm.order_table[effect_code]
						for i,te in pairs(effect_list) do
							if e==te then return false end
						end
						return true
					end
					if original_cost then original_cost(e,tp,eg,ep,ev,re,r,rp,1) end
					if effect_code then
						local effect_list=cm.order_table[effect_code]
						table.insert(effect_list,e)
					else
						e:GetHandler():RegisterFlagEffect(37564766,RESET_EVENT+0x1fe0000+RESET_CHAIN,0,1,cm.order_table_new({e}))
					end
				end
end
function cm.RemainFilter(ct,ignorefaceup)
	if not cm.RemainCheck then
		cm.RemainCheck=true
		local ex=Effect.GlobalEffect()
		ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ex:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ex:SetOperation(cm.RemainCheckOperation)
		Duel.RegisterEffect(ex,0)
	end
	return function(c)
		 return c:GetFlagEffect(37564767)>=ct and (ignorefaceup or c:IsFaceup())
	end
end
function cm.RemainCheckFilter(c)
	return not c:IsType(TYPE_TOKEN)
end
function cm.RemainCheckOperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.RemainCheckFilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	g:ForEach(function(tc)
		tc:RegisterFlagEffect(37564767,RESET_EVENT+0x1fc0000,0,1)
	end)
end
--for sayuri
cm.sayuri_fit_monster=cm.sayuri_fit_monster or {}
function cm.sayuri_ritual(m)
	local mt=cm.load_metatable(m)
	mt.named_with_sayuri=true
	table.insert(cm.sayuri_fit_monster,m)
	return m,mt
end
function cm.sayuri_spell(m)
	local mt=cm.load_metatable(m)
	mt.named_with_sayuri=true
	mt.fit_monster=cm.sayuri_fit_monster
	return m,mt
end
function cm.sayuri_return(c,m)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(cm.desc(11))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCountLimit(1,37564900)
	e2:SetCost(cm.sayurithcost)
	e2:SetTarget(cm.drawtg(1))
	e2:SetOperation(cm.drawop)
	c:RegisterEffect(e2)
	return e2
end
function cm.sayurithfilter(c)
	return cm.check_set_sayuri(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function cm.sayurithcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckOrExtraAsCost()
		and Duel.IsExistingMatchingCard(cm.sayurithfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cm.sayurithfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function cm.sayuri_check_trigger(c,e,tp,eg,ep,ev,re,r,rp)
	if not c.sayuri_trigger_operation then return end
	if c.sayuri_trigger_condition and not c:sayuri_trigger_condition(e,tp,eg,ep,ev,re,r,rp) then return end
	if not (c.sayuri_trigger_forced or Duel.SelectEffectYesNo(tp,c)) then return end
	Duel.Hint(HINT_CARD,0,c:GetOriginalCode())
	Duel.BreakEffect()
	c:sayuri_trigger_operation(e,tp,eg,ep,ev,re,r,rp)
end
function cm.sayuri_mat_filter_8(c)
	if c:GetLevel()==8 and c:IsLocation(LOCATION_GRAVE) then return false end
	return true
end
function cm.sayuri_mat_filter_12(c)
	return cm.check_set_sayuri(c) and c:GetLevel()==4
end

function cm.clone_table(t)
	local rt={}
	for i,v in pairs(t) do
		rt[i]=v
	end
	return rt
end
