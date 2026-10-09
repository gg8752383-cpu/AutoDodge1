--==============================================================
-- AUTO DODGE  PRODUCTION  (capability-aware, single-file)
--==============================================================
-- Client predictive dodge for Roblox. Primary: Humanoid.
-- Custom controllers via MovementAdapter. Honest capability model.
--
-- Flow: Config→Registry→Detection(budget)→Tracking/Fusion
--      →Prediction(+unc)→Risk→Planner(3D)→Validator→Executor
-- FSM: IDLE→OBSERVE→THREAT→EVAL→DODGE/PANIC→RECOVERY
--
-- StarterPlayer→StarterPlayerScripts (LocalScript)
-- Module: require(...):Start()  |  shared.AutoDodge
--==============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local Workspace         = game:GetService("Workspace")

local IS_CLIENT = RunService:IsClient()
local LocalPlayer = Players.LocalPlayer

--==============================================================
-- CONFIG (schema-validated, restart-safe)
--==============================================================
local DEFAULTS = {
	ENABLED = true, START_ENABLED = true, SHOW_UI = true, DEBUG = false,
	MODE = "BALANCED", LANGUAGE = "ru",
	THINK_RATE = 0.033, THINK_RATE_MIN = 0.022, THINK_RATE_MAX = 0.08,
	HORIZON = 0.85, STEP = 0.06, MIN_STEP = 0.025,
	MARGIN = 2.8, TRIGGER_TIME = 0.42, PANIC_TIME = 0.22,
	HOLD_TIME = 0.30, RECOVERY_TIME = 0.32, COMBO_WATCH = 0.45,
	COMMIT_TIME = 0.10, PANIC_COMMIT_TIME = 0.05,
	SWITCH_GAIN = 0.35, HYSTERESIS = 0.22, DEAD_ZONE = 0.12,
	VALIDATE_ACTIONS = true, VALIDATE_LOOKAHEAD = 0.16,
	DETECT_RADIUS = 55, MAX_THREATS = 14, NEAR_CACHE = 22,
	PERF_BUDGET_MS = 3.5, DETECTOR_BUDGET_MS = 2.0,
	MANUAL_BIAS = 1.45, SMOOTH = 20,
	ENABLE_SPEED_BOOST = true, SPEED_MULT = 1.22, SPEED_BOOST_CAP = 1.45,
	DASH_ENABLED = true, DASH_SPEED = 72, DASH_TIME = 0.14,
	DASH_COOLDOWN = 0.85, DASH_NEED = 0.35, DASH_GAIN = 1.1, DASH_IN_AIR = false,
	DASH_HOOK = nil, JUMP_COOLDOWN = 0.55,
	WALL_RAY = 5.5, LEDGE_CHECK = true, LEDGE_DEPTH = 6,
	DETECT_BEAMS = true, DETECT_ATTACHMENTS = true, DETECT_AIM = true,
	DETECT_PROJECTILES = true, DETECT_ACTORS = true, DETECT_PARTS = true,
	USE_ACTION_ANIMATIONS = false,
	AUTO_LEARN = true, LEARN_MIN_HITS = 3, LEARN_COOLDOWN = 0.15,
	LEARN_EARLY = 0.05, LEARN_LATE = 0.12, LEARN_TAGS_ON_HIT = false,
	COMBO_LEARN = true, COMBO_MIN_OBS = 3, COMBO_DECAY = 0.92,
	THREAT_CONFIDENCE_MIN = 0.32, SOFT_TEAM_IGNORE = true, SOFT_NAME_IGNORE = true,
	PING_COMP = true, REACTION_LAG = 0.04,
	PLANNER_3D = true, ADAPTIVE_SAMPLE = true,
	COARSE_DIRS = 12, REFINE_DIRS = 8, REFINE_SPREAD = 18,
	TOGGLE_KEY = Enum.KeyCode.K, PAUSE_KEY = Enum.KeyCode.LeftAlt,
	DANGER_TAGS = {"Danger","Hitbox","Attack","Projectile","Hazard","Damage","Blade"},
	DANGER_NAME_WORDS = {"hitbox","hurtbox","slash","swing","blade","projectile","bullet","missile","beam","laser","explosion","aoe","hazard","danger","spike"},
	IGNORE_NAME_WORDS = {"effect","vfx","sfx","trail_cosmetic","highlight","billboard","gui","decal","texture"},
	GUN_TOOL_WORDS = {"gun","rifle","pistol","blaster","bow","crossbow","launcher"},
	CUSTOM_ROOT_NAMES = {"HumanoidRootPart","RootPart","Root","PrimaryPart"},
	ATTACK_ANIMATION_IDS = {}, LEARNED_SEED = {}, KEYFRAME_SEED = {},
	IsThreatHook = nil, FilterThreatHook = nil, ActionHook = nil,
	MovementAdapter = nil, StateAdapter = nil,
}
local MODES = {
	CALM = {MARGIN=2.2,TRIGGER_TIME=0.32,PANIC_TIME=0.16,DETECT_RADIUS=42,THREAT_CONFIDENCE_MIN=0.45,MANUAL_BIAS=1.8,SPEED_MULT=1.12,USE_ACTION_ANIMATIONS=false},
	BALANCED = {},
	PARANOID = {MARGIN=3.6,TRIGGER_TIME=0.55,PANIC_TIME=0.30,DETECT_RADIUS=70,THREAT_CONFIDENCE_MIN=0.22,MANUAL_BIAS=0.9,SPEED_MULT=1.32,USE_ACTION_ANIMATIONS=true,HOLD_TIME=0.38,HYSTERESIS=0.15},
}
local CFG, DEFAULT_CFG = {}, {}
local function deepCopy(t)
	if type(t)~="table" then return t end
	local n={} for k,v in pairs(t) do n[k]=type(v)=="table" and deepCopy(v) or v end return n
end
local function applyDefaults() for k,v in pairs(DEFAULTS) do CFG[k]=type(v)=="table" and deepCopy(v) or v end end
local function applyMode(name) local m=MODES[name or CFG.MODE]; if m then for k,v in pairs(m) do CFG[k]=v end end end
local function finiteNumber(x,lo,hi,fb)
	if type(x)~="number" or x~=x or x==math.huge or x==-math.huge then return fb end
	if lo and x<lo then return lo end; if hi and x>hi then return hi end; return x
end
local function validateConfig()
	CFG.THINK_RATE=finiteNumber(CFG.THINK_RATE,0.016,0.2,0.033)
	CFG.HORIZON=finiteNumber(CFG.HORIZON,0.2,2.5,0.85)
	CFG.STEP=finiteNumber(CFG.STEP,0.02,0.15,0.06)
	CFG.MARGIN=finiteNumber(CFG.MARGIN,0.5,12,2.8)
	CFG.TRIGGER_TIME=finiteNumber(CFG.TRIGGER_TIME,0.08,1.5,0.42)
	CFG.PANIC_TIME=finiteNumber(CFG.PANIC_TIME,0.05,1.0,0.22)
	CFG.DETECT_RADIUS=finiteNumber(CFG.DETECT_RADIUS,10,200,55)
	CFG.MAX_THREATS=math.floor(finiteNumber(CFG.MAX_THREATS,4,40,14))
	CFG.PERF_BUDGET_MS=finiteNumber(CFG.PERF_BUDGET_MS,1,12,3.5)
	CFG.DETECTOR_BUDGET_MS=finiteNumber(CFG.DETECTOR_BUDGET_MS,0.5,8,2.0)
	CFG.MANUAL_BIAS=finiteNumber(CFG.MANUAL_BIAS,0,4,1.45)
	CFG.SMOOTH=finiteNumber(CFG.SMOOTH,4,60,20)
	CFG.SPEED_MULT=finiteNumber(CFG.SPEED_MULT,1,2,1.22)
	CFG.LEARN_MIN_HITS=math.floor(finiteNumber(CFG.LEARN_MIN_HITS,1,20,3))
	CFG.THREAT_CONFIDENCE_MIN=finiteNumber(CFG.THREAT_CONFIDENCE_MIN,0.05,0.9,0.32)
	CFG.HYSTERESIS=finiteNumber(CFG.HYSTERESIS,0.05,1.5,0.22)
	CFG.REACTION_LAG=finiteNumber(CFG.REACTION_LAG,0,0.25,0.04)
	if CFG.PANIC_TIME>CFG.TRIGGER_TIME then CFG.PANIC_TIME=CFG.TRIGGER_TIME*0.55 end
end
applyDefaults(); applyMode(CFG.MODE); validateConfig(); DEFAULT_CFG=deepCopy(CFG)

--==============================================================
-- MATH
--==============================================================
local CAP, FAR, ZERO, UP = 8, 1e6, Vector3.zero, Vector3.yAxis
local function clamp01(x) if x<0 then return 0 elseif x>1 then return 1 end return x end
local function unit(v)
	if not v then return ZERO end local m=v.Magnitude
	if m<1e-5 or m~=m then return ZERO end return v/m
end
local function flat(v) return Vector3.new(v.X,0,v.Z) end
local function safeUnit(v,fb) local u=unit(v); if u.Magnitude<0.05 then return fb or Vector3.new(0,0,-1) end return u end
local function closestApproach(pA,vA,pB,vB)
	local dp,dv=pA-pB,vA-vB; local a=dv:Dot(dv)
	if a<1e-8 then return 0,dp.Magnitude end
	local t=-dp:Dot(dv)/a; if t~=t or t<0 then t=0 end
	return t,(dp+dv*t).Magnitude
end
local function travelAt(t,speed,lag,dash)
	local tl=math.max(t-(lag or 0),0)
	if dash and tl<=(dash.time or 0) then
		return speed*math.min(t,lag or 0)+(dash.speed or speed)*math.min(tl,dash.time or 0)
	end
	return speed*math.max(t-(lag or 0),0)+speed*math.min(t,lag or 0)*0.35
end
local function containsToken(name,words)
	if type(name)~="string" or name=="" or type(words)~="table" then return false end
	local lower=string.lower(name)
	local norm=string.gsub(lower,"(%l)(%u)","%1_%2"); norm=string.gsub(norm,"[^%a%d]+","_"); norm="_"..norm.."_"
	for _,w in ipairs(words) do
		if type(w)=="string" and #w>=2 then
			local lw=string.lower(w)
			if string.find(norm,"_"..lw.."_",1,true) then return true end
			if #lw>=5 and string.find(lower,lw,1,true) then return true end
		end
	end
	return false
end
local function finiteVec(v)
	if typeof(v)~="Vector3" then return false end
	return v.X==v.X and v.Y==v.Y and v.Z==v.Z and math.abs(v.X)<1e6 and math.abs(v.Y)<1e6 and math.abs(v.Z)<1e6
end
local function runSelfTests()
	local ok=true
	local function check(n,c) if not c then warn("[AutoDodge] self-test FAIL:",n); ok=false end end
	local t,d=closestApproach(Vector3.new(0,0,0),Vector3.new(10,0,0),Vector3.new(5,0,1),ZERO)
	check("closestApproach",t>=0 and d<2); check("unit0",unit(ZERO).Magnitude<1e-6)
	check("travelAt",travelAt(0.2,16,0.05)>0); check("finiteVec",finiteVec(Vector3.new(1,2,3)))
	return ok
end

--==============================================================
-- STATE / SESSION / FSM
--==============================================================
local AutoDodgeModule = {}
local running, sessionId, enabled = false, 0, true
local FSM = {IDLE="IDLE",OBSERVE="OBSERVE",THREAT="THREAT",EVAL="EVAL",DODGE="DODGE",PANIC="PANIC",RECOVERY="RECOVERY",PAUSED="PAUSED",DISABLED="DISABLED"}
local fsmState = FSM.IDLE
local Character, Humanoid, Root, Move
local baseSpeed, boosted, charScale = 16, false, 1
local threats, active, panic = {}, false, false
local targetDir, curDir, finalDir = ZERO, ZERO, ZERO
local dodgeUntil, lastChoose, lastThink = 0, 0, 0
local lastJump, lastDash = -1e9, -1e9
local dashDir, dashUntil, dashWas = ZERO, 0, false
local jumpPlanned, recoveryUntil, recoveryDir = false, 0, ZERO
local lastManual, lastManualTime = ZERO, 0
local holdPause, suspendHeld, hardPauseUntil, busyUntil = false, false, 0, 0
local toolDown, lastStats = {}, {threats=0,tHit=nil}
local lastDecision = {score=nil,worst=nil,reason="",rejected={}}
local lastError, thinkAvg, perfLow, pingValue, lastPingAt = nil, 0, false, 0, 0
local trackStore, learned, comboGraph = {}, {}, {}
local lastLearnedAnim, lastLearnedAt, predictedNextAnim, predictedNextUntil = nil, -1e9, nil, 0
local learnedCount = 0
local flaggedParts, dynamicParts, beamThreats, attachmentThreats = {}, {}, {}, {}
local actorCache, manualThreats, ownerCache = {}, {}, {}
local rootConns, charConns, registryConns = {}, {}, {}
local detectorState = {
	actor={period=0.033,last=0,avgMs=0.3,fails=0},
	projectile={period=0.033,last=0,avgMs=0.4,fails=0},
	parts={period=0.05,last=0,avgMs=0.3,fails=0},
	beam={period=0.08,last=0,avgMs=0.2,fails=0},
	aim={period=0.1,last=0,avgMs=0.15,fails=0},
	attachment={period=0.12,last=0,avgMs=0.15,fails=0},
}
local detectorSkip, lastDetectorMs = {}, {}
local diagnostics = {detectorMs={},skipped={},threatsBySource={},plannerCandidates=0,chosen=nil,rejects={}}
local gameCaps = {
	ARCHETYPE="UNKNOWN",HAS_HUMANOID=true,HAS_DASH=true,HAS_JUMP=true,HAS_VELOCITY_CTRL=true,
	HAS_ANIM_MARKERS=false,HAS_TAGS=false,HAS_PROJECTILES=false,HAS_BEAMS=false,
	SPEED_OWNED_BY_GAME=false,CAN_MOVE=true,CAN_JUMP=true,CAN_DASH=true,
}
local TXT = {threats="угрозы",learned="выучено",on="ВКЛ",off="ВЫКЛ"}
local rayParams, bootstrapDone, gui, hudLabel, toggleBtn = nil, false, nil, nil, nil

--==============================================================
-- MOVEMENT ADAPTER
--==============================================================
local function humanoidAdapter()
	return {
		GetPosition=function() return Root and Root.Position or ZERO end,
		GetVelocity=function() return Root and Root.AssemblyLinearVelocity or ZERO end,
		GetMoveDirection=function() return Humanoid and Humanoid.MoveDirection or ZERO end,
		GetSpeed=function() return Humanoid and Humanoid.WalkSpeed or baseSpeed end,
		SetSpeed=function(s) if Humanoid and not gameCaps.SPEED_OWNED_BY_GAME then Humanoid.WalkSpeed=s end end,
		Move=function(dir) if Humanoid and dir then Humanoid:Move(dir,false) end end,
		Jump=function() if Humanoid then Humanoid.Jump=true end end,
		CanJump=function()
			if not Humanoid then return false end
			local st=Humanoid:GetState()
			return st~=Enum.HumanoidStateType.Freefall and st~=Enum.HumanoidStateType.Flying and st~=Enum.HumanoidStateType.Dead
		end,
		GetCFrame=function() return Root and Root.CFrame or CFrame.new() end,
		GetLookVector=function() return Root and Root.CFrame.LookVector or Vector3.new(0,0,-1) end,
		SupportsDash=function() return true end,
		SupportsVelocity=function() return true end,
		Dash=function(dir,speed)
			if not Root or not dir then return end
			local v=unit(dir)*speed
			Root.AssemblyLinearVelocity=Vector3.new(v.X, Root.AssemblyLinearVelocity.Y, v.Z)
		end,
	}
end
local function validateAdapter(ad)
	if type(ad)~="table" then return false end
	for _,k in ipairs({"GetPosition","GetVelocity","Move","GetSpeed"}) do
		if type(ad[k])~="function" then warn("[AutoDodge] adapter missing",k); return false end
	end
	return true
end
local function bindMovementAdapter(custom)
	local base=humanoidAdapter()
	if type(custom)=="table" then
		for k,v in pairs(base) do if custom[k]==nil then custom[k]=v end end
		Move=custom
	else Move=base end
end
local function stateFlags(now)
	local f={DEAD=false,INVULNERABLE=false,STUNNED=false,BUSY=false,CAN_MOVE=true,CAN_JUMP=true,CAN_DASH=true}
	if Humanoid then
		f.DEAD=Humanoid.Health<=0 or Humanoid:GetState()==Enum.HumanoidStateType.Dead
		f.CAN_JUMP=Humanoid.FloorMaterial~=Enum.Material.Air or CFG.DASH_IN_AIR
	end
	if type(CFG.StateAdapter)=="function" then
		local ok,ex=pcall(CFG.StateAdapter,Character,Humanoid,now)
		if ok and type(ex)=="table" then for k,v in pairs(ex) do f[k]=v end end
	end
	f.BUSY=f.BUSY or now<busyUntil or holdPause or suspendHeld
	for _,d in pairs(toolDown) do if d then f.BUSY=true break end end
	f.CAN_MOVE=f.CAN_MOVE and gameCaps.CAN_MOVE and not f.DEAD
	f.CAN_JUMP=f.CAN_JUMP and gameCaps.CAN_JUMP and not f.DEAD
	f.CAN_DASH=f.CAN_DASH and gameCaps.CAN_DASH and CFG.DASH_ENABLED and not f.DEAD
	return f
end

--==============================================================
-- ROOT / SCALE
--==============================================================
local function getRoot(model)
	if not model then return nil end
	local scores={}
	local function add(part,conf) if part and part:IsA("BasePart") then scores[#scores+1]={part=part,conf=conf} end end
	local hum=model:FindFirstChildOfClass("Humanoid")
	if hum and hum.RootPart then add(hum.RootPart,1.0) end
	if model.PrimaryPart then add(model.PrimaryPart,0.95) end
	for _,n in ipairs(CFG.CUSTOM_ROOT_NAMES or {}) do
		local risky=(n=="Hitbox" or n=="Body" or n=="Core" or n=="Main" or n=="Center")
		add(model:FindFirstChild(n), risky and 0.45 or 0.85)
	end
	table.sort(scores,function(a,b) return a.conf>b.conf end)
	return scores[1] and scores[1].part or nil
end
local function updateCharScale()
	if not Root then charScale=1 return end
	charScale=math.clamp(((Root.Size.X+Root.Size.Z)*0.5)/2.0, 0.6, 2.5)
end
local function marginOf(th)
	local base=CFG.MARGIN*charScale
	if th and th.uncertainty then base=base+th.uncertainty*0.5 end
	return base
end

--==============================================================
-- REGISTRY (event-driven)
--==============================================================
local function classifyPart(part)
	if not part or not part:IsA("BasePart") then return end
	if containsToken(part.Name, CFG.IGNORE_NAME_WORDS) then return end
	local danger=false
	for _,tag in ipairs(CollectionService:GetTags(part)) do
		if table.find(CFG.DANGER_TAGS,tag) then danger=true break end
	end
	if not danger then danger=containsToken(part.Name, CFG.DANGER_NAME_WORDS) end
	if danger then flaggedParts[part]=true; gameCaps.HAS_TAGS=true
	else dynamicParts[part]=true end
end
local function onDescendantAdded(obj)
	if obj:IsA("BasePart") then classifyPart(obj)
	elseif obj:IsA("Beam") or obj:IsA("Trail") then beamThreats[obj]=true; if obj:IsA("Beam") then gameCaps.HAS_BEAMS=true end
	elseif obj:IsA("Attachment") then
		local n=string.lower(obj.Name)
		if string.find(n,"muzzle",1,true) or string.find(n,"fire",1,true) or string.find(n,"barrel",1,true) then
			attachmentThreats[obj]=true
		end
	elseif obj:IsA("Model") then
		local hum=obj:FindFirstChildOfClass("Humanoid")
		if hum and obj~=Character then actorCache[obj]={hum=hum,root=getRoot(obj),last=0} end
	end
end
local function onDescendantRemoving(obj)
	flaggedParts[obj]=nil; dynamicParts[obj]=nil; beamThreats[obj]=nil; attachmentThreats[obj]=nil
	if obj:IsA("Model") then actorCache[obj]=nil end
end
local function startRegistries()
	for _,c in ipairs(registryConns) do pcall(function() c:Disconnect() end) end
	table.clear(registryConns)
	for _,obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Attachment") or obj:IsA("Model") then
			onDescendantAdded(obj)
		end
	end
	registryConns[#registryConns+1]=Workspace.DescendantAdded:Connect(onDescendantAdded)
	registryConns[#registryConns+1]=Workspace.DescendantRemoving:Connect(onDescendantRemoving)
	for _,tag in ipairs(CFG.DANGER_TAGS) do
		registryConns[#registryConns+1]=CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
			if inst:IsA("BasePart") then flaggedParts[inst]=true; gameCaps.HAS_TAGS=true end
		end)
	end
end

--==============================================================
-- PREDICTION
--==============================================================
local function totalLag()
	return CFG.REACTION_LAG + (CFG.PING_COMP and pingValue*0.5 or 0)
end
local function updatePing(now)
	if now-lastPingAt<1 then return end
	lastPingAt=now
	local ok,p=pcall(function() return LocalPlayer:GetNetworkPing() end)
	if ok and type(p)=="number" and p==p then pingValue=math.clamp(p,0,0.5) end
end
local function threatPosition(th,t)
	if not th.cf then return ZERO end
	local a=th.accel or ZERO
	return th.cf.Position + (th.vel or ZERO)*t + a*(0.5*t*t)
end
local function clearanceAt(th,point,t)
	if not th or not point then return CAP end
	local tp=threatPosition(th,t)
	if th.kind=="ell" then
		local rf,rs,ry=(th.rf or 2)+(th.uncertainty or 0),(th.rs or 2)+(th.uncertainty or 0)*0.5,th.ry or 3
		local off=th.cf and th.cf:VectorToObjectSpace(point-tp) or (point-tp)
		local d=math.sqrt((off.X/math.max(rs,0.1))^2+(off.Y/math.max(ry,0.1))^2+(off.Z/math.max(rf,0.1))^2)
		return (d-1)*math.min(rf,rs)
	elseif th.kind=="box" then
		local half=th.half or Vector3.new(2,2,2)
		local o=th.cf and th.cf:VectorToObjectSpace(point-tp) or (point-tp)
		local dx=math.max(math.abs(o.X)-half.X,0)
		local dy=math.max(math.abs(o.Y)-half.Y,0)
		local dz=math.max(math.abs(o.Z)-half.Z,0)
		return math.sqrt(dx*dx+dy*dy+dz*dz)
	elseif th.kind=="lane" then
		local origin=th.cf.Position; local look=th.look or Vector3.new(0,0,-1)
		local toP=point-origin; local along=toP:Dot(look)
		if along<-1 or along>(th.maxLen or FAR)+2 then return CAP end
		return (toP-look*along).Magnitude-(th.width or 2)-(th.uncertainty or 0)
	end
	return (point-tp).Magnitude-((th.radius or 2)+(th.uncertainty or 0))
end

--==============================================================
-- DETECTION (budgeted)
--==============================================================
local function addThreat(list,th)
	if not th or not th.cf or not finiteVec(th.cf.Position) then return end
	th.existence=th.existence or th.confidence or 0.5
	th.intent=th.intent or 0.5; th.hitProb=th.hitProb or 0.5; th.severity=th.severity or 0.5
	th.uncertainty=th.uncertainty or 0.5; th.velUnc=th.velUnc or 2; th.timeUnc=th.timeUnc or 0.05
	th.from=th.from or 0; th.to=th.to or CFG.HORIZON
	if th.to<th.from then th.to=th.from+0.1 end
	th.confidence=th.existence*(0.4+0.6*th.intent)
	if th.confidence<CFG.THREAT_CONFIDENCE_MIN and not th.urgent then return end
	if type(CFG.FilterThreatHook)=="function" then
		local ok,keep=pcall(CFG.FilterThreatHook,th); if ok and keep==false then return end
	end
	list[#list+1]=th
end
local function ownerOf(part)
	local c=ownerCache[part]
	if c and os.clock()-c.t<2 then return c.owner end
	local model=part:FindFirstAncestorOfClass("Model")
	local owner=model
	if model then local plr=Players:GetPlayerFromCharacter(model); if plr then owner=plr end end
	ownerCache[part]={owner=owner,t=os.clock()}; return owner
end
local function softIgnore(part,model)
	if not part then return false end
	if CFG.SOFT_NAME_IGNORE and containsToken(part.Name,CFG.IGNORE_NAME_WORDS) then return true end
	if CFG.SOFT_TEAM_IGNORE and LocalPlayer.Team and model then
		local plr=Players:GetPlayerFromCharacter(model)
		if plr and plr.Team==LocalPlayer.Team and plr~=LocalPlayer then return true end
	end
	return false
end
local function detectActors(list,myPos,now)
	if not CFG.DETECT_ACTORS then return end
	local R=CFG.DETECT_RADIUS
	for model,rec in pairs(actorCache) do
		if not model.Parent then actorCache[model]=nil
		else
			local root=rec.root
			if not root or not root.Parent then root=getRoot(model); rec.root=root end
			if root then
				local d=(root.Position-myPos).Magnitude
				if d<=R and not softIgnore(root,model) then
					local hum=rec.hum
					local attackConf,hitFrom,hitTo,attackType=0,nil,nil,"melee"
					local animator=hum and hum:FindFirstChildOfClass("Animator")
					if animator then
						for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
							if track.IsPlaying then
								local id=""
								pcall(function() id=track.Animation and tostring(track.Animation.AnimationId):match("%d+") or "" end)
								local L=learned[id]
								local known=id~="" and (CFG.ATTACK_ANIMATION_IDS[id] or (L and L.n>=CFG.LEARN_MIN_HITS))
								local isAction=track.Priority==Enum.AnimationPriority.Action
									or track.Priority==Enum.AnimationPriority.Action2
									or track.Priority==Enum.AnimationPriority.Action3
									or track.Priority==Enum.AnimationPriority.Action4
								if known or (CFG.USE_ACTION_ANIMATIONS and isAction and not track.Looped) then
									local len=track.Length>0 and track.Length or 1
									local pos,spd=track.TimePosition,math.max(track.Speed,0.05)
									local meanHit=(L and L.mean) or 0.35
									local tth=(meanHit-pos)/spd
									if track.Looped and tth<-0.05 then tth=tth+len/spd end
									if tth>=-0.1 and tth<CFG.HORIZON+0.2 then
										attackConf=math.max(attackConf, known and 0.82 or 0.45)
										hitFrom=math.max(0,tth-CFG.LEARN_EARLY); hitTo=tth+CFG.LEARN_LATE
									end
								end
							end
						end
					end
					local look=unit(flat(root.CFrame.LookVector))
					local toMe=flat(myPos-root.Position)
					local facing=0
					if look.Magnitude>0.1 and toMe.Magnitude>0.1 then facing=look:Dot(unit(toMe)) end
					local vel=root.AssemblyLinearVelocity
					local approach=0
					if toMe.Magnitude>0.1 then approach=math.clamp((-vel):Dot(unit(toMe))/24,0,1) end
					local reach=4.5*charScale
					local tool=model:FindFirstChildOfClass("Tool")
					if tool then
						local h=tool:FindFirstChild("Handle")
						if h and h:IsA("BasePart") then reach=math.max(reach,(h.Position-root.Position).Magnitude+2) end
						if containsToken(tool.Name,CFG.GUN_TOOL_WORDS) then attackType="ranged"; reach=math.max(reach,40) end
					end
					local intent=clamp01(0.25+facing*0.45+approach*0.35+attackConf*0.4)
					local existence=attackConf>0.4 and 0.85 or (facing>0.3 and d<reach*1.4 and 0.55 or 0.25)
					if existence>=0.3 or attackConf>=0.3 then
						local half=Vector3.new(reach*0.35,3*charScale,reach*0.55)
						local cf=CFrame.lookAt(root.Position, root.Position+(look.Magnitude>0.1 and look or Vector3.new(0,0,-1)))
						addThreat(list,{
							kind="box",cf=cf,half=half,vel=vel,accel=ZERO,
							from=hitFrom or 0, to=hitTo or (d/28+0.25), dist=d,
							urgent=attackConf>0.6 and facing>0.4 and d<reach*1.2,
							existence=existence,intent=intent,
							hitProb=clamp01(attackConf*0.7+facing*0.3), severity=attackType=="ranged" and 0.7 or 0.6,
							uncertainty=0.8+(1-attackConf)*1.5,
							source="actor",attackType=attackType,instance=root,owner=model,look=look,
						})
					end
				end
			end
		end
	end
end
local function detectParts(list,myPos,now,myVel)
	if not CFG.DETECT_PARTS then return end
	local R=CFG.DETECT_RADIUS
	local function consider(part,baseExist)
		if not part or not part.Parent then return end
		if softIgnore(part, part:FindFirstAncestorOfClass("Model")) then return end
		local pos=part.Position; local d=(pos-myPos).Magnitude
		if d>R+8 then return end
		local vel=part.AssemblyLinearVelocity; local speed=vel.Magnitude
		local size=part.Size; local reach=math.max(size.X,size.Y,size.Z)*0.5
		local approaching=0
		if d>0.2 and speed>1 then approaching=math.clamp((-(vel):Dot(unit(myPos-pos)))/30,0,1) end
		local existence=baseExist
		if speed>20 then existence=math.max(existence,0.7) end
		if approaching>0.5 then existence=math.max(existence,0.65) end
		local isStatic=speed<1.5
		addThreat(list,{
			kind="ell",cf=part.CFrame,rf=reach+1,rs=reach+0.5,ry=math.max(size.Y*0.5,2),
			vel=vel,accel=ZERO,from=0,to=isStatic and FAR or (d/math.max(speed,4)+0.4),dist=d,
			urgent=not isStatic and approaching>0.6 and d<18,
			existence=existence,intent=isStatic and 0.4 or clamp01(0.3+approaching*0.6),
			hitProb=clamp01(0.4+approaching*0.4),severity=0.55,
			uncertainty=isStatic and 0.4 or 1.2,
			source="part",attackType=isStatic and "aoe" or "projectile",instance=part,owner=ownerOf(part),
		})
	end
	for part in pairs(flaggedParts) do
		if not part.Parent then flaggedParts[part]=nil else consider(part,0.75) end
	end
	local n=0
	for part in pairs(dynamicParts) do
		if n>40 then break end
		if not part.Parent then dynamicParts[part]=nil
		elseif (part.Position-myPos).Magnitude<CFG.NEAR_CACHE and part.AssemblyLinearVelocity.Magnitude>12 then
			consider(part,0.4); n+=1
		end
	end
end
local function detectProjectiles(list,myPos,now,myVel)
	if not CFG.DETECT_PROJECTILES then return end
	local R,checked=CFG.DETECT_RADIUS,0
	for part in pairs(dynamicParts) do
		if checked>30 then break end
		if part.Parent then
			local vel=part.AssemblyLinearVelocity
			if vel.Magnitude>=28 then
				local d=(part.Position-myPos).Magnitude
				if d<=R then
					checked+=1
					local eta,dist=closestApproach(part.Position,vel,myPos,myVel)
					local size=math.max(part.Size.X,part.Size.Y,part.Size.Z)*0.5
					local willHit=dist<(size+3*charScale) and eta<CFG.HORIZON
					addThreat(list,{
						kind="ell",cf=part.CFrame,rf=size+1.2,rs=size+0.8,ry=size+0.8,
						vel=vel,accel=Vector3.new(0,-workspace.Gravity*0.15,0),
						from=math.max(0,eta-0.05),to=eta+0.2,dist=d,
						urgent=willHit and eta<CFG.PANIC_TIME*1.5,
						existence=0.8,intent=willHit and 0.85 or 0.5,hitProb=willHit and 0.8 or 0.35,
						severity=0.75,uncertainty=1.0+vel.Magnitude*0.01,velUnc=4,
						source="projectile",attackType="projectile",instance=part,owner=ownerOf(part),
					})
					gameCaps.HAS_PROJECTILES=true
				end
			end
		end
	end
end
local function beamWidth(beam)
	if beam:IsA("Beam") then
		return math.max(1.0, (((tonumber(beam.Width0) or 1)+(tonumber(beam.Width1) or 1))*0.5))
	end
	if beam:IsA("Trail") then
		local ok,scale=pcall(function()
			local ws=beam.WidthScale
			if ws and ws.Keypoints and #ws.Keypoints>0 then
				local s=0 for _,kp in ipairs(ws.Keypoints) do s+=kp.Value end return s/#ws.Keypoints
			end return 1
		end)
		return math.max(1.0,(ok and type(scale)=="number" and scale or 1)*1.4)
	end
	return 1.8
end
local function detectBeams(list,myPos,now)
	if not CFG.DETECT_BEAMS then return end
	for beam in pairs(beamThreats) do
		if not beam.Parent then beamThreats[beam]=nil
		else
			local a0,a1=beam.Attachment0,beam.Attachment1
			if a0 and a1 then
				local p0,p1=a0.WorldPosition,a1.WorldPosition
				local mid=(p0+p1)*0.5; local d=(mid-myPos).Magnitude
				if d<=CFG.DETECT_RADIUS+25 then
					local dir=p1-p0; local len=dir.Magnitude
					if len>1 then
						local look3=unit(dir); local lookU=unit(flat(dir))
						if lookU.Magnitude<0.05 then lookU=safeUnit(Vector3.new(look3.X,0,look3.Z),Vector3.new(0,0,-1)) end
						addThreat(list,{
							kind="lane",cf=CFrame.new(p0),look=look3,maxLen=len,width=beamWidth(beam),
							vel=ZERO,from=0,to=FAR,dist=d,urgent=d<12,
							existence=beam:IsA("Beam") and 0.75 or 0.5,intent=0.7,hitProb=0.65,severity=0.7,
							uncertainty=0.8,source="beam",attackType="beam",instance=beam,
						})
					end
				end
			end
		end
	end
end
local function detectAim(list,myPos)
	if not CFG.DETECT_AIM then return end
	local R=CFG.DETECT_RADIUS*0.7
	for model,rec in pairs(actorCache) do
		if model.Parent and rec.root then
			local root=rec.root; local d=(root.Position-myPos).Magnitude
			if d>6 and d<=R then
				local look=unit(root.CFrame.LookVector)
				local aim=look:Dot(unit(myPos-root.Position))
				if aim>0.88 then
					addThreat(list,{
						kind="lane",cf=CFrame.new(root.Position),look=look,maxLen=d+5,width=1.8*charScale,
						vel=ZERO,from=0.05,to=0.55,dist=d,urgent=false,
						existence=0.4,intent=clamp01((aim-0.85)*5),hitProb=0.35,severity=0.5,
						uncertainty=1.5,source="aim",attackType="ranged",instance=root,owner=model,
					})
				end
			end
		end
	end
end
local function detectAttachments(list,myPos,now)
	if not CFG.DETECT_ATTACHMENTS then return end
	for att in pairs(attachmentThreats) do
		if not att.Parent then attachmentThreats[att]=nil
		else
			local p=att.WorldPosition; local d=(p-myPos).Magnitude
			if d<CFG.DETECT_RADIUS*0.5 then
				local parent=att.Parent
				local vel=(parent and parent:IsA("BasePart")) and parent.AssemblyLinearVelocity or ZERO
				addThreat(list,{
					kind="ell",cf=CFrame.new(p),rf=2,rs=2,ry=2,vel=vel,from=0,to=0.4,dist=d,
					existence=0.35,intent=0.4,hitProb=0.3,severity=0.5,uncertainty=2,
					source="attachment",attackType="ranged",instance=att,
				})
			end
		end
	end
end
local function runDetector(name,fn,budgetLeft)
	local st=detectorState[name]
	if not st then return budgetLeft end
	if detectorSkip[name] then diagnostics.skipped[name]=(diagnostics.skipped[name] or 0)+1; return budgetLeft end
	local now=os.clock()
	if now-st.last<st.period then return budgetLeft end
	if budgetLeft<0.08 and st.avgMs>0.15 and now-st.last<0.35 then
		diagnostics.skipped[name]=(diagnostics.skipped[name] or 0)+1; return budgetLeft
	end
	local t0=os.clock()
	local ok,err=pcall(fn)
	local ms=(os.clock()-t0)*1000
	st.last=now; st.avgMs=st.avgMs*0.8+ms*0.2; lastDetectorMs[name]=ms
	if not ok then
		st.fails+=1
		if st.fails>=3 then detectorSkip[name]=true; warn("[AutoDodge] detector disabled:",name,err)
		elseif lastError~=tostring(err) then lastError=tostring(err); warn("[AutoDodge] detector",name,err) end
	else st.fails=0 end
	if ms>1.2 then st.period=math.min(0.25,st.period*1.15)
	elseif ms<0.25 and st.period>0.033 then st.period=math.max(0.033,st.period*0.92) end
	return budgetLeft-ms
end

--==============================================================
-- TRACKING + FUSION (spatial/temporal/semantic, stable IDs)
--==============================================================
local function stableIdFor(th)
	if th.instance and th.instance.Parent then
		local ok,id=pcall(function() return th.instance:GetDebugId() end)
		if ok then return "i:"..tostring(id) end
	end
	if th.owner and typeof(th.owner)=="Instance" then
		local pos=th.cf and th.cf.Position or ZERO
		local ok,id=pcall(function() return th.owner:GetDebugId() end)
		return string.format("o:%s:%.0f:%.0f:%s", ok and tostring(id) or "?", pos.X//6, pos.Z//6, th.attackType or "?")
	end
	local pos=th.cf and th.cf.Position or ZERO
	return string.format("s:%.0f:%.0f:%.0f:%s", pos.X//5, pos.Y//5, pos.Z//5, th.attackType or "?")
end
local function fuseThreats(raw,now)
	local clusters={}
	for _,th in ipairs(raw) do
		th.threatId=stableIdFor(th)
		local placed=false
		for _,cl in ipairs(clusters) do
			local rep=cl.rep
			local dp=(th.cf.Position-rep.cf.Position).Magnitude
			local sameType=th.attackType==rep.attackType
			local timeOverlap=not (th.to<rep.from-0.15 or th.from>rep.to+0.15)
			local sameOwner=th.owner and th.owner==rep.owner
			local sameInst=th.instance and th.instance==rep.instance
			if sameInst or (dp<7 and timeOverlap and (sameType or sameOwner)) then
				cl.members[#cl.members+1]=th
				rep.existence=math.max(rep.existence,th.existence)
				rep.intent=math.max(rep.intent,th.intent)
				rep.hitProb=math.max(rep.hitProb,th.hitProb)
				rep.severity=math.max(rep.severity,th.severity)
				rep.uncertainty=math.min(rep.uncertainty,th.uncertainty)
				rep.from=math.min(rep.from,th.from); rep.to=math.max(rep.to,th.to)
				rep.urgent=rep.urgent or th.urgent
				if th.dist and (not rep.dist or th.dist<rep.dist) then
					rep.dist=th.dist; rep.cf=th.cf; rep.vel=th.vel
				end
				rep.existence=math.min(1,rep.existence+0.08)
				placed=true; break
			end
		end
		if not placed then clusters[#clusters+1]={rep=th,members={th}} end
	end
	local seen,out={},{}
	for _,cl in ipairs(clusters) do
		local th=cl.rep; local id=th.threatId; seen[id]=true
		local prev=trackStore[id]
		if prev then
			th.existence=math.max(th.existence, prev.existence*0.7)
			th.confidence=th.existence*(0.4+0.6*th.intent)
			if prev.vel and th.vel then th.vel=prev.vel*0.35+th.vel*0.65 end
			prev.last=now; prev.existence=th.existence; prev.vel=th.vel; prev.cf=th.cf
		else
			trackStore[id]={id=id,last=now,existence=th.existence,vel=th.vel,cf=th.cf,born=now}
		end
		out[#out+1]=th
	end
	for id,tr in pairs(trackStore) do
		if not seen[id] then
			tr.existence*=0.65
			if tr.existence<0.12 or now-tr.last>1.2 then trackStore[id]=nil end
		end
	end
	return out
end
local function riskOf(th)
	local conf=(th.existence or 0.5)*(th.hitProb or 0.5)
	local sev=th.severity or 0.5
	local eta=math.max(th.from or 0.05, 0.04)
	local urg=th.urgent and 1.4 or 1
	local unc=1+(th.uncertainty or 0.5)*0.15
	local tb=1
	if th.attackType=="projectile" then tb=1.15
	elseif th.attackType=="beam" then tb=1.1
	elseif th.attackType=="aoe" then tb=1.2 end
	return (conf*sev*urg*tb*unc)/eta
end

--==============================================================
-- PLANNER (3D adaptive)
--==============================================================
local function makeDirs()
	local dirs={}
	local n=CFG.COARSE_DIRS or 12
	for i=0,n-1 do
		local a=(i/n)*math.pi*2
		dirs[#dirs+1]=Vector3.new(math.cos(a),0,math.sin(a))
	end
	if CFG.PLANNER_3D then
		dirs[#dirs+1]=Vector3.new(0,1,0)
		for i=0,3 do
			local a=(i/4)*math.pi*2
			dirs[#dirs+1]=unit(Vector3.new(math.cos(a),0.55,math.sin(a)))
		end
	end
	dirs[#dirs+1]=ZERO
	return dirs
end
local function pathClearance(dir,myPos,speed,ths,lift,dash,myVel)
	local worst,endClear,pen=CAP,CAP,0
	local lag=totalLag(); local flatVel=myVel and flat(myVel) or ZERO
	for _,th in ipairs(ths) do
		local rel=(th.vel or ZERO).Magnitude
		if rel>=25 and th.cf then
			local pVel=dir*speed+flatVel*0.25
			local eta,dist=closestApproach(th.cf.Position,th.vel or ZERO,myPos,pVel)
			if eta and eta>=(th.from or 0) and eta<=math.min(th.to or CFG.HORIZON,CFG.HORIZON) then
				local reach=2
				if th.kind=="box" and th.half then reach=math.max(th.half.X,th.half.Y,th.half.Z)
				elseif th.kind=="ell" then reach=math.max(th.rf or 0,th.rs or 0)
				elseif th.kind=="lane" then reach=th.width or 2 end
				local c=dist-reach-marginOf(th)
				if c<worst then worst=c end
				if c<0 then pen+=-c*0.15 end
			end
		end
	end
	local maxRel=0
	for _,th in ipairs(ths) do if th.vel then maxRel=math.max(maxRel,th.vel.Magnitude) end end
	local step=CFG.STEP
	if maxRel>45 then step=math.max(CFG.MIN_STEP,CFG.STEP*0.4)
	elseif maxRel>25 then step=math.max(CFG.MIN_STEP,CFG.STEP*0.65) end
	local t=0
	while t<=CFG.HORIZON do
		local travel=travelAt(t,speed,lag,dash)
		local blend=math.clamp(1-t/0.12,0,1)
		local point=myPos+dir*travel+flatVel*(t*blend*0.5)
		if lift and dir.Y>=0 then
			local tj=math.max(t-0.03,0)
			point+=Vector3.new(0,math.max(lift.v0*tj-0.5*lift.g*tj*tj,0),0)
		end
		if CFG.PLANNER_3D and math.abs(dir.Y)>0.05 then
			point+=Vector3.new(0,dir.Y*travel*0.35,0)
		end
		for _,th in ipairs(ths) do
			local c=clearanceAt(th,point,t)-marginOf(th)
			if c<worst then worst=c end
			if c<0 then pen+=-c*step end
			if t+step>CFG.HORIZON and c<endClear then endClear=c end
		end
		t+=step
	end
	return worst,endClear,pen
end
local function wallRisk(dir,myPos,speed)
	if not rayParams or dir.Magnitude<0.1 then return 0 end
	local dist=math.min(CFG.WALL_RAY,3+speed*0.12)*charScale
	local hit=Workspace:Spherecast(myPos+Vector3.new(0,1.5*charScale,0),1.1*charScale,unit(flat(dir))*dist,rayParams)
	if hit then return math.clamp(1-hit.Distance/dist,0,1) end
	return 0
end
local function ledgeRisk(dir,myPos)
	if not CFG.LEDGE_CHECK or not rayParams or dir.Magnitude<0.1 then return 0 end
	local probe=myPos+unit(flat(dir))*(3.5*charScale)+Vector3.new(0,1,0)
	local ground=Workspace:Raycast(probe,Vector3.new(0,-CFG.LEDGE_DEPTH*charScale,0),rayParams)
	return ground and 0 or 1
end
local function scoreDirection(dir,myPos,speed,ths,manual,dash,myVel,isPanic)
	local lift=nil
	if dir.Y>0.3 then lift={v0=50,g=workspace.Gravity} end
	local worst,endClear,pen=pathClearance(dir,myPos,speed,ths,lift,dash,myVel)
	local survival=clamp01((worst+2)/6)
	local future=clamp01((endClear+1)/5)
	local wRisk=wallRisk(dir,myPos,speed)
	local lRisk=ledgeRisk(dir,myPos)
	local unc=0; for _,th in ipairs(ths) do unc+=(th.uncertainty or 0) end
	unc=unc/math.max(#ths,1)
	local mom=0
	if myVel then
		local fv=flat(myVel)
		if fv.Magnitude>8 and dir.Magnitude>0.1 then mom=unit(fv):Dot(unit(flat(dir))) end
	end
	local manualScore=0
	if manual and manual.Magnitude>0.1 and dir.Magnitude>0.1 then
		local bias=CFG.MANUAL_BIAS
		if isPanic then bias*=0.12 elseif worst<0.4 then bias*=0.35 elseif worst>2.5 then bias*=1.25 end
		manualScore=unit(flat(dir)):Dot(unit(flat(manual)))*bias
	end
	local standPen=0
	if dir.Magnitude<0.08 and worst<1.0 then standPen=isPanic and 6 or 3.5 end
	local score=survival*6.5+future*2.0-pen*2.2-wRisk*3.0-lRisk*4.0-unc*0.3+mom*0.6+manualScore-standPen
	if isPanic then score=survival*9-pen*3.5-wRisk*2-lRisk*3+mom*0.3-standPen end
	return score,worst
end
local function refineAround(bestDir,myPos,speed,ths,manual,myVel,isPanic)
	if not CFG.ADAPTIVE_SAMPLE or bestDir.Magnitude<0.1 then return bestDir,-1e9,CAP end
	local baseAng=math.atan2(bestDir.Z,bestDir.X)
	local spread=math.rad(CFG.REFINE_SPREAD or 18)
	local best,bestScore,bestWorst=bestDir,-1e9,CAP
	local n=CFG.REFINE_DIRS or 8
	for i=0,n-1 do
		local a=baseAng+(i/(n-1)-0.5)*2*spread
		local d=Vector3.new(math.cos(a),bestDir.Y*0.5,math.sin(a))
		local sc,w=scoreDirection(d,myPos,speed,ths,manual,nil,myVel,isPanic)
		if sc>bestScore then bestScore,best,bestWorst=sc,d,w end
	end
	return best,bestScore,bestWorst
end
local function chooseDirection(myPos,speed,ths,manual,dash,myVel,isPanic)
	local dirs=makeDirs()
	local best,bestScore,bestWorst=ZERO,-1e9,CAP
	local wantJump=false
	diagnostics.plannerCandidates=#dirs
	for _,dir in ipairs(dirs) do
		local sc,w=scoreDirection(dir,myPos,speed,ths,manual,dash,myVel,isPanic)
		if sc>bestScore then bestScore,best,bestWorst=sc,dir,w end
	end
	if best.Magnitude>0.1 then
		local rb,rs,rw=refineAround(best,myPos,speed,ths,manual,myVel,isPanic)
		if rs>bestScore then best,bestScore,bestWorst=rb,rs,rw end
	end
	if CFG.PLANNER_3D then
		local jDir=best.Magnitude>0.1 and unit(Vector3.new(best.X,0.7,best.Z)) or Vector3.new(0,1,0)
		local js,jw=scoreDirection(jDir,myPos,speed,ths,manual,nil,myVel,isPanic)
		if js>bestScore+0.4 and jw>bestWorst then wantJump=true; best,bestScore,bestWorst=jDir,js,jw end
	end
	lastDecision.score=bestScore; lastDecision.worst=bestWorst
	lastDecision.reason=wantJump and "jump" or (bestWorst<0 and "escape" or "avoid")
	return best,bestScore,bestWorst,wantJump
end

--==============================================================
-- VALIDATOR
--==============================================================
local function validateAction(kind,dir,myPos,speed,ths,myVel)
	if not CFG.VALIDATE_ACTIONS then return true,"ok" end
	if kind=="move" and (not dir or dir.Magnitude<0.05) then return false,"zero_dir" end
	local flags=stateFlags(os.clock())
	if flags.DEAD then return false,"dead" end
	if kind=="jump" and not flags.CAN_JUMP then return false,"cant_jump" end
	if kind=="dash" and not flags.CAN_DASH then return false,"cant_dash" end
	if not flags.CAN_MOVE and kind=="move" then return false,"cant_move" end
	if rayParams and dir and dir.Magnitude>0.1 then
		local hit=Workspace:Spherecast(myPos+Vector3.new(0,1.2*charScale,0),1.15*charScale,unit(flat(dir))*(2.2*charScale),rayParams)
		if hit and hit.Distance<1.6*charScale then return false,"wall" end
	end
	if kind~="jump" and ledgeRisk(dir or ZERO,myPos)>0.8 then return false,"ledge" end
	local look=CFG.VALIDATE_LOOKAHEAD or 0.16
	local lag=totalLag(); local worst,standWorst=CAP,CAP
	local t,step=0,math.max(0.03,CFG.STEP)
	while t<=look do
		local travel=travelAt(t,speed,lag,kind=="dash" and {speed=CFG.DASH_SPEED,time=CFG.DASH_TIME} or nil)
		local point=myPos+(dir or ZERO)*travel
		for _,th in ipairs(ths or {}) do
			local c=clearanceAt(th,point,t)-marginOf(th); if c<worst then worst=c end
			local cs=clearanceAt(th,myPos,t)-marginOf(th); if cs<standWorst then standWorst=cs end
		end
		t+=step
	end
	if worst<-0.6 and worst<standWorst-0.35 then return false,"deeper_into_threat" end
	return true,"ok"
end

--==============================================================
-- GATHER
--==============================================================
local function gather(now)
	local list={}
	local myPos=Move and Move:GetPosition() or (Root and Root.Position) or ZERO
	local myVel=Move and Move:GetVelocity() or ZERO
	local budget=CFG.DETECTOR_BUDGET_MS
	if perfLow then budget*=0.55 end
	for i=#manualThreats,1,-1 do
		local m=manualThreats[i]
		if now>m.endT then table.remove(manualThreats,i)
		else
			local d=(m.cf.Position-myPos).Magnitude
			if d-(m.reach or 2)<=CFG.DETECT_RADIUS then
				addThreat(list,{
					kind=m.kind,cf=m.cf,half=m.half,rf=m.rf,rs=m.rs,ry=m.ry,radius=m.radius,
					look=m.look,width=m.width,maxLen=m.maxLen,vel=m.vel or ZERO,
					from=math.max(0,m.startT-now),to=m.endT-now,dist=d,urgent=m.urgent,
					existence=m.confidence or 1,intent=1,hitProb=0.9,severity=0.8,uncertainty=0.2,
					source="manual",attackType=m.attackType or "manual",
				})
			end
		end
	end
	budget=runDetector("actor",function() detectActors(list,myPos,now) end,budget)
	budget=runDetector("projectile",function() detectProjectiles(list,myPos,now,myVel) end,budget)
	budget=runDetector("parts",function() detectParts(list,myPos,now,myVel) end,budget)
	budget=runDetector("beam",function() detectBeams(list,myPos,now) end,budget)
	budget=runDetector("aim",function() detectAim(list,myPos) end,budget)
	budget=runDetector("attachment",function() detectAttachments(list,myPos,now) end,budget)
	if perfLow then
		detectorSkip.attachment=true
		detectorSkip.aim=thinkAvg>CFG.PERF_BUDGET_MS*0.9
	else
		detectorSkip.attachment=false; detectorSkip.aim=false
		for name,st in pairs(detectorState) do
			if detectorSkip[name] and st.fails<3 and os.clock()-st.last>2 then
				detectorSkip[name]=false; st.fails=0
			end
		end
	end
	list=fuseThreats(list,now)
	table.sort(list,function(a,b) return riskOf(a)>riskOf(b) end)
	if #list>CFG.MAX_THREATS then
		local t={} for i=1,CFG.MAX_THREATS do t[i]=list[i] end; list=t
	end
	diagnostics.threatsBySource={}
	for _,th in ipairs(list) do
		local s=th.source or "?"
		diagnostics.threatsBySource[s]=(diagnostics.threatsBySource[s] or 0)+1
	end
	return list
end

--==============================================================
-- LEARNING (cautious)
--==============================================================
local function updateLearned(id,hitAt)
	if not id or id=="" then return end
	local L=learned[id]
	if not L then L={n=0,mean=hitAt,m2=0,last=os.clock()}; learned[id]=L end
	L.n+=1; local n=L.n; local delta=hitAt-L.mean
	L.mean+=delta/n; L.m2+=delta*(hitAt-L.mean); L.last=os.clock()
	if n>4 then
		local std=math.sqrt(math.max(L.m2/math.max(n-1,1),1e-6))
		if math.abs(hitAt-L.mean)>3*std then L.mean-=delta/n*0.5 end
	end
end
local function learnFromHit(myPos)
	if not CFG.AUTO_LEARN or perfLow then return end
	local now=os.clock()
	local candidates={}
	for model,rec in pairs(actorCache) do
		if model.Parent and rec.root and (rec.root.Position-myPos).Magnitude<28 then
			local animator=rec.hum and rec.hum:FindFirstChildOfClass("Animator")
			if animator then
				for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
					if track.IsPlaying then
						local id=""
						pcall(function() id=track.Animation and tostring(track.Animation.AnimationId):match("%d+") or "" end)
						if id~="" then
							local facing=0
							local look=unit(flat(rec.root.CFrame.LookVector))
							local toMe=flat(myPos-rec.root.Position)
							if look.Magnitude>0.1 and toMe.Magnitude>0.1 then facing=look:Dot(unit(toMe)) end
							candidates[#candidates+1]={id=id,dist=(rec.root.Position-myPos).Magnitude,pos=track.TimePosition,facing=facing}
						end
					end
				end
			end
		end
	end
	table.sort(candidates,function(a,b) return (a.facing*2-a.dist*0.05)>(b.facing*2-b.dist*0.05) end)
	local top=candidates[1]
	if top and top.facing>0.15 and top.dist<22 then
		updateLearned(top.id,top.pos)
		if CFG.COMBO_LEARN and lastLearnedAnim and lastLearnedAnim~=top.id and now-lastLearnedAt<1.3 then
			local g=comboGraph[lastLearnedAnim]; if not g then g={}; comboGraph[lastLearnedAnim]=g end
			local e=g[top.id]; if not e then e={n=0,last=now}; g[top.id]=e end
			e.n+=1; e.last=now
			local bestN,bestC=nil,0
			for nid,rec in pairs(g) do
				local weight=rec.n*(CFG.COMBO_DECAY^((now-(rec.last or now))/10))
				if weight>bestC then bestN,bestC=nid,weight end
			end
			if bestN and bestC>=CFG.COMBO_MIN_OBS then
				predictedNextAnim=bestN; predictedNextUntil=now+0.7
			end
		end
		lastLearnedAnim=top.id; lastLearnedAt=now
		learnedCount=0; for _ in pairs(learned) do learnedCount+=1 end
	end
end

--==============================================================
-- THINK / FSM / EXECUTION
--==============================================================
local function setFSM(s) fsmState=s end
local function getManualDirection(now)
	if not Move then return ZERO end
	local md=flat(Move:GetMoveDirection())
	if md.Magnitude>0.1 then lastManual,lastManualTime=unit(md),now; return lastManual end
	if now-lastManualTime<0.2 then return lastManual end
	return ZERO
end
local function dodgeSpeed()
	local s=Move and Move:GetSpeed() or baseSpeed
	if panic then return s*math.min(CFG.SPEED_MULT*1.08,CFG.SPEED_BOOST_CAP) end
	if active then return s*CFG.SPEED_MULT end
	return s
end
local function think(now)
	updatePing(now)
	if not enabled then
		setFSM(FSM.DISABLED); threats={}; active,panic,jumpPlanned=false,false,false; targetDir=ZERO; return
	end
	local flags=stateFlags(now)
	if flags.DEAD or flags.INVULNERABLE or flags.STUNNED or suspendHeld or now<hardPauseUntil or (flags.BUSY and not panic) then
		setFSM(FSM.PAUSED); threats={}; active,panic,jumpPlanned=false,false,false; targetDir=ZERO; dashUntil=0; return
	end
	if now<recoveryUntil and not panic then
		setFSM(FSM.RECOVERY)
		threats=gather(now)
		local myPos=Move:GetPosition(); local myVelFlat=flat(Move:GetVelocity())
		local urgentHit=nil
		for _,th in ipairs(threats) do
			if th.urgent or (th.existence or 0)*(th.hitProb or 0)>0.45 then
				local t=0
				while t<=CFG.PANIC_TIME+0.08 do
					if clearanceAt(th,myPos+myVelFlat*t,t)-marginOf(th)<0 then urgentHit=t; break end
					t+=CFG.STEP
				end
			end
		end
		if urgentHit and urgentHit<=CFG.PANIC_TIME then recoveryUntil=0
		else
			active=#threats>0 and now<dodgeUntil
			if not active then
				targetDir=ZERO
				if boosted and Move and CFG.ENABLE_SPEED_BOOST and not gameCaps.SPEED_OWNED_BY_GAME then
					local sp=Move:GetSpeed()
					if math.abs(sp-baseSpeed)<0.4 then Move:SetSpeed(baseSpeed); boosted=false
					else Move:SetSpeed(baseSpeed+(sp-baseSpeed)*0.5) end
				end
				lastStats={threats=#threats,tHit=nil}; return
			end
		end
	end
	local myPos=Move:GetPosition()
	setFSM(FSM.OBSERVE)
	threats=gather(now)
	local myVelFlat=flat(Move:GetVelocity())
	local tHit,tUrgent=nil,nil
	for _,th in ipairs(threats) do
		local step=math.max(CFG.STEP,0.025)
		local t,prevSafe=0,0
		while t<=CFG.HORIZON do
			if clearanceAt(th,myPos+myVelFlat*t,t)-marginOf(th)<0 then
				local lo,hi=prevSafe,t
				for _=1,4 do
					local mid=(lo+hi)*0.5
					if clearanceAt(th,myPos+myVelFlat*mid,mid)-marginOf(th)<0 then hi=mid else lo=mid end
				end
				if not tHit or hi<tHit then tHit=hi end
				if th.urgent and (not tUrgent or hi<tUrgent) then tUrgent=hi end
				break
			end
			prevSafe=t; t+=step
		end
	end
	lastStats={threats=#threats,tHit=tHit}
	if #threats==0 then
		if active or now<dodgeUntil then
			recoveryUntil=now+CFG.RECOVERY_TIME; recoveryDir=targetDir; dodgeUntil=0; setFSM(FSM.RECOVERY)
		else setFSM(FSM.IDLE) end
		active,panic=false,false; targetDir=ZERO; return
	end
	setFSM(FSM.THREAT)
	if tHit and tHit<=CFG.TRIGGER_TIME then dodgeUntil=now+CFG.HOLD_TIME end
	if CFG.COMBO_LEARN and predictedNextAnim and now<predictedNextUntil and tHit then
		dodgeUntil=math.max(dodgeUntil,now+0.08)
	end
	panic=tUrgent~=nil and tUrgent<=CFG.PANIC_TIME
	active=#threats>0 and now<dodgeUntil
	if not active then setFSM(FSM.OBSERVE); targetDir=ZERO; panic=false; return end
	setFSM(panic and FSM.PANIC or FSM.EVAL)
	local speed=dodgeSpeed()
	local manual=getManualDirection(now)
	local myVel=Move:GetVelocity()
	local commit=panic and CFG.PANIC_COMMIT_TIME or CFG.COMMIT_TIME
	local since=now-lastChoose
	local need=targetDir.Magnitude<0.1 or since>=commit
	if targetDir.Magnitude>0.1 and not need then
		local curScore,curWorst=scoreDirection(targetDir,myPos,speed,threats,manual,nil,myVel,panic)
		if curWorst<-0.2 then need=true
		elseif since>=0.06 then
			local trial=chooseDirection(myPos,speed,threats,manual,nil,myVel,panic)
			local trialScore=scoreDirection(trial,myPos,speed,threats,manual,nil,myVel,panic)
			if trialScore>curScore+CFG.HYSTERESIS then need=true end
		end
	end
	if need then
		local dir,sc,_,wantJump=chooseDirection(myPos,speed,threats,manual,nil,myVel,panic)
		if targetDir.Magnitude>0.1 and dir.Magnitude>0.1 then
			if unit(flat(dir)):Dot(unit(flat(targetDir)))>(1-CFG.DEAD_ZONE) then dir=targetDir end
		end
		local okV=validateAction("move",dir,myPos,speed,threats,myVel)
		if okV and dir.Magnitude>0.1 then targetDir=dir; lastChoose=now
		elseif not okV then
			diagnostics.rejects[#diagnostics.rejects+1]="move_rejected"
			if #diagnostics.rejects>8 then table.remove(diagnostics.rejects,1) end
		end
		jumpPlanned=wantJump; setFSM(FSM.DODGE)
	end
	if CFG.ENABLE_SPEED_BOOST and not gameCaps.SPEED_OWNED_BY_GAME and Move then
		Move:SetSpeed(baseSpeed*(panic and math.min(CFG.SPEED_MULT*1.08,CFG.SPEED_BOOST_CAP) or CFG.SPEED_MULT))
		boosted=true
	end
	if jumpPlanned and flags.CAN_JUMP and now-lastJump>=CFG.JUMP_COOLDOWN and Move:CanJump() then
		local okJ=validateAction("jump",targetDir.Magnitude>0.1 and targetDir or Vector3.new(0,0,-1),myPos,speed,threats,myVel)
		if okJ then
			Move:Jump()
			if type(CFG.ActionHook)=="function" then pcall(CFG.ActionHook,"jump",targetDir,1) end
			lastJump=now; diagnostics.chosen="jump"
		end
		jumpPlanned=false
	end
	if CFG.DASH_ENABLED and panic and flags.CAN_DASH and now>=dashUntil and now-lastDash>=CFG.DASH_COOLDOWN
		and now-lastJump>0.55 and (CFG.DASH_IN_AIR or Move:CanJump()) and targetDir.Magnitude>0.1 then
		local ns,nw=scoreDirection(targetDir,myPos,speed,threats,manual,nil,myVel,true)
		if nw<CFG.DASH_NEED then
			local dash={speed=CFG.DASH_SPEED,time=CFG.DASH_TIME}
			local dd,ds=chooseDirection(myPos,speed,threats,manual,dash,myVel,true)
			if dd.Magnitude>0.1 and ds>ns+CFG.DASH_GAIN then
				local okD=validateAction("dash",dd,myPos,speed,threats,myVel)
				if okD then
					dashDir=dd; dashUntil=now+CFG.DASH_TIME; lastDash=now
					targetDir,curDir,lastChoose=dd,dd,now
					dodgeUntil=math.max(dodgeUntil,dashUntil+0.1)
					if Move.Dash then Move:Dash(dd,CFG.DASH_SPEED) end
					if CFG.DASH_HOOK then pcall(CFG.DASH_HOOK,dd,1) end
					if type(CFG.ActionHook)=="function" then pcall(CFG.ActionHook,"dash",dd,1) end
					diagnostics.chosen="dash"
				end
			end
		end
	end
	if CFG.DEBUG then
		print(string.format("[AutoDodge] %s th=%d tHit=%s",fsmState,#threats,tHit and string.format("%.2f",tHit) or "-"))
	end
end
local function advanceMovement(dt)
	if not active or targetDir.Magnitude<0.05 then curDir=ZERO; finalDir=ZERO; return end
	local alpha=1-math.exp(-CFG.SMOOTH*dt)
	if curDir.Magnitude<0.05 then curDir=targetDir else curDir=curDir:Lerp(targetDir,alpha) end
	if (curDir-finalDir).Magnitude>=CFG.DEAD_ZONE*0.5 or finalDir.Magnitude<0.1 then finalDir=curDir end
	if dashWas or os.clock()<dashUntil then
		finalDir=dashDir.Magnitude>0.1 and dashDir or finalDir
		dashWas=os.clock()<dashUntil
	end
end
local function applyMove()
	if not Move or not active then return end
	if finalDir.Magnitude>0.1 then
		if dashWas and rayParams then
			local hit=Workspace:Spherecast(Move:GetPosition()+Vector3.new(0,1,0),1.1,unit(flat(finalDir))*2.5,rayParams)
			if hit and hit.Distance<1.4 then dashUntil=0; dashWas=false end
		end
		Move:Move(unit(flat(finalDir)))
		if type(CFG.ActionHook)=="function" then pcall(CFG.ActionHook,"move",finalDir,panic and 1 or 0.5) end
	end
end

--==============================================================
-- CHARACTER LIFECYCLE
--==============================================================
local function resetState()
	threats={}; active,panic,jumpPlanned=false,false,false
	targetDir,curDir,finalDir=ZERO,ZERO,ZERO
	dodgeUntil,lastChoose,lastThink=0,0,0; dashUntil,dashWas=0,false
	recoveryUntil=0; recoveryDir=ZERO; fsmState=FSM.IDLE; table.clear(trackStore)
end
local function setupCharacter(char)
	for _,c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
	table.clear(charConns)
	Character=char
	Humanoid=char:WaitForChild("Humanoid",5)
	Root=getRoot(char)
	if not Humanoid or not Root then return end
	rayParams=RaycastParams.new()
	rayParams.FilterType=Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances={char}
	bindMovementAdapter(CFG.MovementAdapter)
	baseSpeed=Move:GetSpeed(); updateCharScale(); resetState()
	local lastHp=Humanoid.Health
	charConns[#charConns+1]=Humanoid.HealthChanged:Connect(function(hp)
		if hp<lastHp-1 then learnFromHit(Move and Move:GetPosition() or Root.Position) end
		lastHp=hp
	end)
	charConns[#charConns+1]=Humanoid.Died:Connect(resetState)
	local function hookTool(tool)
		if not tool:IsA("Tool") then return end
		local function release() toolDown[tool]=nil end
		charConns[#charConns+1]=tool.Activated:Connect(function() toolDown[tool]=true end)
		charConns[#charConns+1]=tool.Deactivated:Connect(release)
		charConns[#charConns+1]=tool.Unequipped:Connect(release)
		charConns[#charConns+1]=tool.Destroying:Connect(release)
		charConns[#charConns+1]=tool.AncestryChanged:Connect(function()
			if not tool:IsDescendantOf(Character) then release() end
		end)
	end
	for _,ch in ipairs(char:GetChildren()) do hookTool(ch) end
	charConns[#charConns+1]=char.ChildAdded:Connect(hookTool)
end
local function buildGui()
	if not CFG.SHOW_UI or not IS_CLIENT then return end
	local pg=LocalPlayer:WaitForChild("PlayerGui",10); if not pg then return end
	local old=pg:FindFirstChild("AutoDodgeUI"); if old then old:Destroy() end
	gui=Instance.new("ScreenGui"); gui.Name="AutoDodgeUI"; gui.ResetOnSpawn=false; gui.Parent=pg
	toggleBtn=Instance.new("TextButton")
	toggleBtn.Size=UDim2.new(0,100,0,32); toggleBtn.Position=UDim2.new(1,-110,0,12)
	toggleBtn.BackgroundColor3=Color3.fromRGB(30,120,60); toggleBtn.TextColor3=Color3.new(1,1,1)
	toggleBtn.Font=Enum.Font.GothamBold; toggleBtn.TextSize=14; toggleBtn.Text="УВОРОТ"; toggleBtn.Parent=gui
	Instance.new("UICorner",toggleBtn).CornerRadius=UDim.new(0,6)
	hudLabel=Instance.new("TextLabel")
	hudLabel.Size=UDim2.new(0,200,0,54); hudLabel.Position=UDim2.new(1,-210,0,48)
	hudLabel.BackgroundTransparency=0.45; hudLabel.BackgroundColor3=Color3.fromRGB(0,0,0)
	hudLabel.TextColor3=Color3.new(1,1,1); hudLabel.Font=Enum.Font.Code; hudLabel.TextSize=12
	hudLabel.TextXAlignment=Enum.TextXAlignment.Left; hudLabel.Text=""; hudLabel.Parent=gui
	Instance.new("UICorner",hudLabel).CornerRadius=UDim.new(0,4)
	toggleBtn.MouseButton1Click:Connect(function() AutoDodgeModule.SetEnabled(not enabled) end)
end
local function updateHud()
	if not hudLabel then return end
	hudLabel.Text=string.format("%s | %s: %d\n%s | tHit:%s\n%s: %d | %s",
		enabled and TXT.on or TXT.off, TXT.threats, lastStats.threats, fsmState,
		lastStats.tHit and string.format("%.2f",lastStats.tHit) or "-",
		TXT.learned, learnedCount, gameCaps.ARCHETYPE)
	if toggleBtn then toggleBtn.BackgroundColor3=enabled and Color3.fromRGB(30,120,60) or Color3.fromRGB(100,40,40) end
end
local function autoBootstrap()
	if bootstrapDone then return end; bootstrapDone=true
	local tags,actors,beams=0,0,0
	for _ in pairs(flaggedParts) do tags+=1 end
	for _ in pairs(actorCache) do actors+=1 end
	for _ in pairs(beamThreats) do beams+=1 end
	gameCaps.HAS_TAGS=tags>0; gameCaps.HAS_BEAMS=beams>0; gameCaps.HAS_HUMANOID=Humanoid~=nil
	if actors>0 and gameCaps.HAS_PROJECTILES then gameCaps.ARCHETYPE="COMBAT_MIXED"
	elseif gameCaps.HAS_PROJECTILES then gameCaps.ARCHETYPE="RANGED"
	elseif beams>0 then gameCaps.ARCHETYPE="BEAM"
	elseif actors>0 then gameCaps.ARCHETYPE="MELEE"
	else gameCaps.ARCHETYPE="GENERIC" end
	if gameCaps.ARCHETYPE=="RANGED" then CFG.DETECT_RADIUS=math.max(CFG.DETECT_RADIUS,70); CFG.HORIZON=math.max(CFG.HORIZON,1.0)
	elseif gameCaps.ARCHETYPE=="MELEE" then CFG.TRIGGER_TIME=math.max(CFG.TRIGGER_TIME,0.38) end
	pcall(function() LocalPlayer:SetAttribute("AutoDodgeArchetype",gameCaps.ARCHETYPE) end)
end
local function cleanup()
	sessionId+=1
	pcall(function() RunService:UnbindFromRenderStep("AutoDodgeMove") end)
	for _,c in ipairs(rootConns) do pcall(function() c:Disconnect() end) end
	for _,c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
	for _,c in ipairs(registryConns) do pcall(function() c:Disconnect() end) end
	table.clear(rootConns); table.clear(charConns); table.clear(registryConns)
	table.clear(trackStore); table.clear(comboGraph); table.clear(lastDetectorMs); table.clear(detectorSkip)
	if gui then pcall(function() gui:Destroy() end); gui=nil end
	if boosted and Move and not gameCaps.SPEED_OWNED_BY_GAME then pcall(function() Move:SetSpeed(baseSpeed) end) end
	boosted=false; running=false; resetState(); Move=nil
end
local function setEnabled(v)
	enabled=v and true or false
	pcall(function() LocalPlayer:SetAttribute("AutoDodgeEnabled",enabled) end)
	if not enabled then
		active,panic=false,false; targetDir=ZERO
		if boosted and Move then Move:SetSpeed(baseSpeed); boosted=false end
	end
	updateHud()
end
function AutoDodgeModule.Start(overrides)
	if not IS_CLIENT then warn("[AutoDodge] client only"); return AutoDodgeModule end
	if running then return AutoDodgeModule end
	CFG=deepCopy(DEFAULT_CFG)
	if type(overrides)=="table" then for k,v in pairs(overrides) do CFG[k]=v end end
	if CFG.MODE then applyMode(CFG.MODE) end
	validateConfig()
	if not CFG.ENABLED then return AutoDodgeModule end
	enabled=CFG.START_ENABLED; running=true; sessionId+=1
	local mySession=sessionId; bootstrapDone=false
	runSelfTests(); bindMovementAdapter(CFG.MovementAdapter)
	pcall(function() LocalPlayer:SetAttribute("AutoDodgeEnabled",enabled) end)
	rootConns[#rootConns+1]=LocalPlayer:GetAttributeChangedSignal("AutoDodgeEnabled"):Connect(function()
		if sessionId~=mySession then return end
		local v=LocalPlayer:GetAttribute("AutoDodgeEnabled")
		if type(v)=="boolean" then setEnabled(v) end
	end)
	rootConns[#rootConns+1]=UserInputService.InputBegan:Connect(function(input,processed)
		if sessionId~=mySession or processed then return end
		if CFG.TOGGLE_KEY and input.KeyCode==CFG.TOGGLE_KEY then setEnabled(not enabled)
		elseif CFG.PAUSE_KEY and input.KeyCode==CFG.PAUSE_KEY then hardPauseUntil=os.clock()+0.4 end
	end)
	task.spawn(function() if sessionId==mySession then pcall(buildGui) end end)
	startRegistries()
	task.spawn(function()
		if sessionId~=mySession then return end; task.wait(0.5)
		if sessionId==mySession then pcall(autoBootstrap) end
	end)
	local function onChar(char) if sessionId==mySession then setupCharacter(char) end end
	if LocalPlayer.Character then onChar(LocalPlayer.Character) end
	rootConns[#rootConns+1]=LocalPlayer.CharacterAdded:Connect(onChar)
	rootConns[#rootConns+1]=RunService.Heartbeat:Connect(function()
		if sessionId~=mySession or not running or not Move or not Root then return end
		local now=os.clock()
		local rate=CFG.THINK_RATE
		if perfLow then rate=math.min(CFG.THINK_RATE_MAX,rate*1.6) end
		if now-lastThink<rate then return end
		local t0=os.clock()
		local ok,err=pcall(think,now)
		local ms=(os.clock()-t0)*1000
		thinkAvg=thinkAvg*0.85+ms*0.15
		perfLow=thinkAvg>CFG.PERF_BUDGET_MS
		if thinkAvg>CFG.PERF_BUDGET_MS then CFG.THINK_RATE=math.min(CFG.THINK_RATE_MAX,CFG.THINK_RATE*1.05)
		elseif thinkAvg<CFG.PERF_BUDGET_MS*0.5 then CFG.THINK_RATE=math.max(CFG.THINK_RATE_MIN,CFG.THINK_RATE*0.98) end
		lastThink=now
		if not ok and lastError~=tostring(err) then lastError=tostring(err); warn("[AutoDodge] think:",err) end
		updateHud()
	end)
	RunService:BindToRenderStep("AutoDodgeMove",Enum.RenderPriority.Last.Value,function(dt)
		if sessionId~=mySession or not running then return end
		advanceMovement(dt); applyMove()
	end)
	return AutoDodgeModule
end
function AutoDodgeModule.Stop() cleanup(); return AutoDodgeModule end
function AutoDodgeModule.SetEnabled(v) setEnabled(v); return AutoDodgeModule end
function AutoDodgeModule.IsEnabled() return enabled end
local function apiAdd(kind,cf,sizeOrRadius,duration,delay,extra)
	duration=duration or 0.4; delay=delay or 0; local now=os.clock()
	local th={kind=kind,cf=typeof(cf)=="CFrame" and cf or CFrame.new(cf),
		startT=now+delay,endT=now+delay+duration,vel=ZERO,urgent=true,confidence=1,reach=2,attackType="manual"}
	if kind=="box" then
		th.half=typeof(sizeOrRadius)=="Vector3" and sizeOrRadius*0.5 or Vector3.new(2,2,2); th.reach=th.half.Magnitude
	elseif kind=="sphere" or kind=="ell" then
		th.kind="ell"; local r=type(sizeOrRadius)=="number" and sizeOrRadius or 3
		th.rf,th.rs,th.ry=r,r,r; th.reach=r
	elseif kind=="ray" or kind=="lane" then
		th.kind="lane"; th.look=(extra and extra.look) or Vector3.new(0,0,-1)
		th.width=(extra and extra.width) or 2; th.maxLen=type(sizeOrRadius)=="number" and sizeOrRadius or 40; th.reach=th.width
	end
	if type(extra)=="table" then for k,v in pairs(extra) do th[k]=v end end
	manualThreats[#manualThreats+1]=th; return #manualThreats
end
AutoDodgeModule.AddBox=function(cf,size,duration,delay,extra) return apiAdd("box",cf,size,duration,delay,extra) end
AutoDodgeModule.AddSphere=function(cf,radius,duration,delay,extra) return apiAdd("sphere",cf,radius,duration,delay,extra) end
AutoDodgeModule.AddRay=function(origin,look,length,width,duration,delay)
	return apiAdd("lane",typeof(origin)=="CFrame" and origin or CFrame.new(origin),length,duration,delay,{look=unit(look or Vector3.new(0,0,-1)),width=width or 2})
end
AutoDodgeModule.RemoveThreat=function(idx) if type(idx)=="number" and manualThreats[idx] then table.remove(manualThreats,idx) end end
AutoDodgeModule.ClearThreats=function() table.clear(manualThreats) end
AutoDodgeModule.Busy=function(seconds) busyUntil=math.max(busyUntil,os.clock()+(seconds or 0.4)) end
AutoDodgeModule.Pause=function(seconds) hardPauseUntil=math.max(hardPauseUntil,os.clock()+(seconds or 1)) end
AutoDodgeModule.Resume=function() hardPauseUntil=0; suspendHeld=false; busyUntil=0 end
AutoDodgeModule.SetMovementAdapter=function(ad) CFG.MovementAdapter=ad; bindMovementAdapter(ad); if Move then baseSpeed=Move:GetSpeed() end end
AutoDodgeModule.GetMovementAdapter=function() return Move end
AutoDodgeModule.GetGameCapabilities=function() return gameCaps end
AutoDodgeModule.GetState=function()
	return fsmState,{active=active,panic=panic,recovery=os.clock()<recoveryUntil,threats=#threats,tHit=lastStats.tHit,thinkMs=thinkAvg}
end
AutoDodgeModule.SetConfig=function(patch)
	if type(patch)~="table" then return false end
	for k,v in pairs(patch) do CFG[k]=v end; validateConfig(); return true
end
AutoDodgeModule.GetComboGraph=function() return comboGraph end
AutoDodgeModule.GetDiagnostics=function()
	return {detectorMs=lastDetectorMs,skipped=diagnostics.skipped,threatsBySource=diagnostics.threatsBySource,
		plannerCandidates=diagnostics.plannerCandidates,chosen=diagnostics.chosen,rejects=diagnostics.rejects,
		thinkAvg=thinkAvg,fsm=fsmState,perfLow=perfLow}
end
AutoDodgeModule.Discover=function(radius)
	local L={string.format("===== AutoDodge Discover arch=%s =====",gameCaps.ARCHETYPE)}
	local n=0
	for part in pairs(flaggedParts) do
		if part.Parent then L[#L+1]="FLAG "..part:GetFullName(); n+=1; if n>40 then break end end
	end
	return table.concat(L,"\n")
end
AutoDodgeModule.DumpLearned=function()
	local L={"===== Learned ====="}
	for id,rec in pairs(learned) do L[#L+1]=string.format("%s n=%d mean=%.3f",id,rec.n,rec.mean) end
	return table.concat(L,"\n")
end
AutoDodgeModule.DumpProfile=function()
	return string.format("Place=%s Arch=%s Margin=%.2f Trigger=%.2f Think=%.3f Threats=%d Learned=%d",
		tostring(game.PlaceId),gameCaps.ARCHETYPE,CFG.MARGIN,CFG.TRIGGER_TIME,CFG.THINK_RATE,#threats,learnedCount)
end
AutoDodgeModule.HookRemote=function(remote,handler)
	if type(handler)~="function" then return end
	local sid=sessionId
	task.spawn(function()
		if type(remote)=="string" then
			local rs=game:GetService("ReplicatedStorage"); local name,t0=remote,os.clock(); remote=nil
			while not remote and os.clock()-t0<15 do
				if sessionId~=sid or not running then return end
				remote=rs:FindFirstChild(name,true); if not remote then task.wait(0.5) end
			end
		end
		if sessionId~=sid or not running then return end
		if typeof(remote)=="Instance" and remote:IsA("RemoteEvent") then
			rootConns[#rootConns+1]=remote.OnClientEvent:Connect(function(...)
				if sessionId~=sid then return end; pcall(handler,...)
			end)
		end
	end)
end
AutoDodgeModule.CFG=CFG
AutoDodgeModule.FSM=FSM
if IS_CLIENT then shared.AutoDodge=AutoDodgeModule end
if IS_CLIENT and script:IsA("LocalScript") then task.defer(function() AutoDodgeModule.Start() end) end
return AutoDodgeModule
