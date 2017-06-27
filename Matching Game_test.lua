--Made by purerosefallen
os=require('os')
Debug.SetAIName("Matching Game")
Debug.ReloadFieldBegin(DUEL_ATTACK_FIRST_TURN+DUEL_SIMPLE_AI)
Debug.SetPlayerInfo(0,8000,0,0)
Debug.SetPlayerInfo(1,8000,0,0)
Debug.ReloadFieldEnd()

CardList={
	29088922,
	71870152,
	82693917,
	82971335,
	55586621,
}

DIRECTION_UP=0x1
DIRECTION_DOWN=0x2
DIRECTION_LEFT=0x4
DIRECTION_RIGHT=0x8
DIRECTION_ALL=0xf
TIMES = 0
MAX_DM = 0
START_LP = 8000
START_TIME = os.clock()

function Group.MergeCard(g,p,loc,seq)
	local tc=Duel.GetFieldCard(p,loc,seq)
	if tc then
		g:AddCard(tc)
		return true
	else
		return false
	end
end
function Card.GetDirectionGroup(c,direction)
	local loc=c:GetLocation()
	local cp=c:GetControler()
	local seq=c:GetSequence()
	local g=Group.CreateGroup()
	if bit.band(direction,DIRECTION_LEFT)~=0 then
		if cp==0 and seq~=0 then
			g:MergeCard(cp,loc,seq-1)
		end
		if cp==1 and seq~=4 then
			g:MergeCard(cp,loc,seq+1)
		end
	end
	if bit.band(direction,DIRECTION_RIGHT)~=0 then
		if cp==0 and seq~=4 then
			g:MergeCard(cp,loc,seq+1)
		end
		if cp==1 and seq~=0 then
			g:MergeCard(cp,loc,seq-1)
		end
	end
	if bit.band(direction,DIRECTION_UP)~=0 then
		if loc==LOCATION_SZONE and cp==0 then
			g:MergeCard(0,LOCATION_MZONE,seq)
		elseif loc==LOCATION_MZONE and cp==0 then
			g:MergeCard(1,LOCATION_MZONE,4-seq)
		elseif loc==LOCATION_MZONE and cp==1 then
			g:MergeCard(1,LOCATION_SZONE,seq)
		end
	end
	if bit.band(direction,DIRECTION_DOWN)~=0 then
		if loc==LOCATION_SZONE and cp==1 then
			g:MergeCard(1,LOCATION_MZONE,seq)
		elseif loc==LOCATION_MZONE and cp==1 then
			g:MergeCard(0,LOCATION_MZONE,4-seq)
		elseif loc==LOCATION_MZONE and cp==0 then
			g:MergeCard(0,LOCATION_SZONE,seq)
		end
	end
	return g
end
function Card.IsCanMoveDownwards(c)
	return c:GetDirectionGroup(DIRECTION_DOWN):GetCount()==0
end
function Card.MoveDownwards(c)
	local loc=c:GetLocation()
	local cp=c:GetControler()
	local seq=c:GetSequence()
	if loc==LOCATION_SZONE and cp==1 then
		Duel.MoveToField(c,cp,cp,LOCATION_MZONE,POS_FACEUP_ATTACK,true)
		Duel.MoveSequence(c,seq)
	elseif loc==LOCATION_MZONE and cp==1 then
		Duel.GetControl(c,0)
		Duel.MoveSequence(c,4-seq)
	elseif loc==LOCATION_MZONE and cp==0 then
		Duel.MoveToField(c,0,cp,LOCATION_SZONE,POS_FACEUP_ATTACK,true)
		Duel.MoveSequence(c,seq)
	end
end
function Card.GetChangedCode(c)
	return c:GetFlagEffectLabel(10000000) or c:GetCode()
end
function Card.IsChangedCode(c,code)
	return c:GetChangedCode()==code
end
function Card.IsNeedToGrave(c)
	local code=c:GetChangedCode()
	return c:GetDirectionGroup(DIRECTION_UP+DIRECTION_DOWN):IsExists(Card.IsChangedCode,2,nil,code) or c:GetDirectionGroup(DIRECTION_LEFT+DIRECTION_RIGHT):IsExists(Card.IsChangedCode,2,nil,code)
end
function Card.filter(c,code)
	return c:IsCode(code)
end
function Card.CreateRandomCard()
	local code=CardList[math.random(#CardList)]
	local g = Duel.GetMatchingGroup(Card.filter,0,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,code)
	if g:GetCount() >= 1 then
		local c=Group.GetFirst(g)
		c:ResetEffect(c:GetOriginalCode(),RESET_CARD)
		return c
	end
	local c=Duel.CreateToken(0,code)
	c:ResetEffect(c:GetOriginalCode(),RESET_CARD)
	return c
end
function Duel.CheckTop()
	while Duel.GetFieldGroupCount(0,0,LOCATION_SZONE)<5 do
		Duel.MoveToField(Card.CreateRandomCard(),1,1,LOCATION_SZONE,POS_FACEUP_ATTACK,true)
	end
end
function Duel.CheckMoveDownwards()
	local g=Duel.GetMatchingGroup(Card.IsCanMoveDownwards,0,LOCATION_MZONE,LOCATION_ONFIELD,nil)
	while g:GetCount()>0 do
		for tc in aux.Next(g) do
			tc:MoveDownwards()
		end
		g=Duel.GetMatchingGroup(Card.IsCanMoveDownwards,0,LOCATION_MZONE,LOCATION_ONFIELD,nil)
	end
end
function Duel.CheckToGrave()
	local g=Duel.GetMatchingGroup(Card.IsNeedToGrave,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tg=g:Clone()
	for tc in aux.Next(g) do
		local code=tc:GetCode()
		local g1=tc:GetDirectionGroup(DIRECTION_UP+DIRECTION_DOWN)
		local g2=tc:GetDirectionGroup(DIRECTION_LEFT+DIRECTION_RIGHT)
		if g1:IsExists(Card.IsCode,2,nil,code) then tg:Merge(g1) end
		if g2:IsExists(Card.IsCode,2,nil,code) then tg:Merge(g2) end
	end
	TIMES = TIMES + 1
	return Duel.SendtoGrave(tg,REASON_RULE)
end
function Duel.CheckScore(ct,mul)
	local score=200*(ct-2)*mul
	MAX_DM = math.max(score,MAX_DM)
	Duel.Damage(1,score,REASON_RULE)
	Duel.Recover(0,score/5,REASON_RULE)
end
function Duel.RefreshField()
	local finish=true
	local mul=1
	while true do
		while Duel.GetFieldGroupCount(0,LOCATION_ONFIELD,LOCATION_ONFIELD)<20 do
			Duel.CheckMoveDownwards()
			Duel.CheckTop()
		end
		local ct=Duel.CheckToGrave()
		if ct>0 then
			Duel.CheckScore(ct,mul)
			mul=mul*2
		else break end
	end
end
function Card.IsExchangable(c,tc)
	c:RegisterFlagEffect(10000000,0,0,0,tc:GetCode())
	tc:RegisterFlagEffect(10000000,0,0,0,c:GetCode())
	local res=Duel.IsExistingMatchingCard(Card.IsNeedToGrave,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	c:ResetFlagEffect(10000000)
	tc:ResetFlagEffect(10000000)
	return res
end
function Group.IsFitToExchange(g)
	local c1=g:GetFirst()
	local c2=g:GetNext()
	return c1:IsExchangable(c2)
end
function Card.IsCanBeSelected(c)
	return c:GetDirectionGroup(DIRECTION_ALL):IsExists(Card.IsExchangable,1,c,c)
end
function Group.Exchange(g)
	local c1=g:GetFirst()
	local c2=g:GetNext()
	local loc1=c1:GetLocation()
	local cp1=c1:GetControler()
	local seq1=c1:GetSequence()
	local loc2=c2:GetLocation()
	local cp2=c2:GetControler()
	local seq2=c2:GetSequence()
	if cp1==cp2 then
		if loc1==LOCATION_MZONE and loc2==LOCATION_MZONE and Duel.SwapSequence then
			Duel.SwapSequence(c1,c2)
		else
			Duel.SendtoDeck(c1,nil,-1,REASON_RULE)
			Duel.MoveToField(c2,cp1,cp1,loc1,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(c2,seq1)
			Duel.MoveToField(c1,cp2,cp2,loc2,POS_FACEUP_ATTACK,true)
			Duel.MoveSequence(c1,seq2)
		end
	else
		Duel.SwapControl(c1,c2)
	end
end
function Duel.ReloadField()
	for p=0,1 do
		for loc=4,8,4 do
			for i=0,4 do
				Duel.MoveToField(Card.CreateRandomCard(),0,p,loc,POS_FACEUP_ATTACK,true)
			end
		end
	end
end
function Duel.WinMsg()
	local end_time = os.clock()
	local s = string.format("You Win!\nStart LP: %d\nMax Damage: %d\nTotal Time: %d second\n",START_LP,MAX_DM,end_time-START_TIME) 
	Debug.ShowHint(s)
end
function Duel.StartGame()
	Debug.ShowHint("Created By purerosefallen.\nYGOPro1 recommanded.")
	START_LP = Duel.AnnounceNumber(0,8000,16000,40000,80000)
	Duel.SetLP(1,START_LP)
	Duel.ReloadField()
	local RemainTime=Duel.GetLP(0)
	START_TIME = os.clock()
	while true do
		Duel.RefreshField()
		if Duel.GetLP(1) <= 0 then
			Duel.WinMsg()
			return
		end
		local g=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
		while not g:IsExists(Card.IsCanBeSelected,1,nil) do
			Debug.ShowHint("No more available moves")
			Duel.Remove(g,POS_FACEUP,REASON_RULE)
			Duel.ReloadField()
			Duel.RefreshField()
			if Duel.GetLP(1) <= 0 then
				Duel.WinMsg()
				return
			end
			g=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD)
		end
		local sg=Group.CreateGroup()
		local t1=os.clock()
		repeat
			sg:Clear()
			local g1=g:Select(0,1,1,nil)
			sg:Merge(g1)
			local g2=g1:GetFirst():GetDirectionGroup(DIRECTION_ALL):Select(0,1,1,nil)
			sg:Merge(g2)
		until sg:IsFitToExchange()
		local t2=os.clock()
		--RemainTime=math.max(RemainTime-((t2-t1)*300),0)
		RemainTime=math.max(((t2-t1)*300),0)
		Duel.SetLP(0,Duel.GetLP(0) - RemainTime)
		if Duel.GetLP(0)==0   then
			Debug.ShowHint("Game Over.")
			return
		end
		--Duel.SetLP(0,RemainTime)
		--if RemainTime==0 then return end
		sg:Exchange()
	end
end

math.randomseed(os.time()+os.clock())
for i=1,100 do
	math.random()
end
local e=Effect.GlobalEffect()
e:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e:SetCode(EVENT_ADJUST)
e:SetOperation(Duel.StartGame)
Duel.RegisterEffect(e,0)