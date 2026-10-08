--==============================================================
-- AUTO DODGE v5.1 (РїРѕРІРµСЂС… v5.0, РЅР°СЃС‚СЂРѕР№РєРё С‚Рµ Р¶Рµ)
-- LocalScript -> StarterPlayer > StarterPlayerScripts
--==============================================================
-- РќРѕРІРѕРµ РІ v5.1 (СѓРЅРёРІРµСЂСЃР°Р»СЊРЅРѕСЃС‚СЊ):
--  вЂў РјРѕР±С‹ Р±РµР· Humanoid (РЅР° AnimationController) С‚РѕР¶Рµ СЃС‡РёС‚Р°СЋС‚СЃСЏ РІСЂР°РіР°РјРё
--  вЂў СЂР°РґРёСѓСЃ СѓРґР°СЂР° РїРѕРґСЃС‚СЂР°РёРІР°РµС‚СЃСЏ РїРѕРґ СЂР°Р·РјРµСЂ РІСЂР°РіР° (Р±РѕСЃСЃС‹, РјРµР»РєРёРµ РјРѕР±С‹)
--  вЂў РґРµС‚Р°Р»Рё РІ РїР°РїРєРµ/РјРѕРґРµР»Рё Projectiles, Hitboxes, Lava... РѕРїР°СЃРЅС‹, РґР°Р¶Рµ РµСЃР»Рё СЃР°РјРё РЅР°Р·РІР°РЅС‹ Part
--  вЂў Р±РѕР»СЊС€РёРµ РЅРµРѕСЃСЏР·Р°РµРјС‹Рµ Р·РѕРЅС‹ (AoE Р±РѕСЃСЃРѕРІ) Р±РѕР»СЊС€Рµ РЅРµ РѕС‚Р±СЂР°СЃС‹РІР°СЋС‚СЃСЏ
--  вЂў СЃРІРѕРё СЃР°РјРјРѕРЅС‹/РїРёС‚РѕРјС†С‹/РєР»РѕРЅС‹ РЅРµ СЃС‡РёС‚Р°СЋС‚СЃСЏ СѓРіСЂРѕР·РѕР№
--  вЂў РѕРїРµС‡Р°С‚РєРё РІ PROFILES/OVERRIDE РґР°СЋС‚ РїСЂРµРґСѓРїСЂРµР¶РґРµРЅРёРµ РІ Output
--  вЂў СЏР·С‹Рє РєРЅРѕРїРєРё: auto/ru/en (LANGUAGE)
--  вЂў AutoDodge.Discover(): РїРµС‡Р°С‚Р°РµС‚, С‡С‚Рѕ РІРѕРєСЂСѓРі (РёРјРµРЅР°, С‚РµРіРё, Р°С‚СЂРёР±СѓС‚С‹, Р°РЅРёРјР°С†РёРё), С‡С‚РѕР±С‹ Р±С‹СЃС‚СЂРѕ Р·Р°РїРѕР»РЅРёС‚СЊ РїСЂРѕС„РёР»СЊ
--  вЂў AutoDodge.CFG: РјРµРЅСЏР№ РЅР°СЃС‚СЂРѕР№РєРё РЅР° Р»РµС‚Сѓ РёР· РєРѕРјР°РЅРґРЅРѕР№ СЃС‚СЂРѕРєРё
--
-- РќРѕРІРѕРµ РІ v5.0 (РїРѕ РјРѕС‚РёРІР°Рј С‚РѕРіРѕ, РєР°Рє СѓСЃС‚СЂРѕРµРЅС‹ Р±РѕС‘РІРєРё РІ Р РѕР±Р»РѕРєСЃРµ):
--  вЂў С‚Р°Р№РјРёРЅРі СѓРґР°СЂР° РёР· СЃР°РјРѕР№ Р°РЅРёРјР°С†РёРё: РєР»СЋС‡РµРІС‹Рµ РєР°РґСЂС‹/РјР°СЂРєРµСЂС‹ Hit, Damage, Strike...
--    С‡РёС‚Р°СЋС‚СЃСЏ Р·Р°СЂР°РЅРµРµ (KeyframeSequence) Рё/РёР»Рё Р·Р°РїРѕРјРёРЅР°СЋС‚СЃСЏ РїРѕ KeyframeReached
--  вЂў СЃРЅР°СЂСЏРґС‹, РєРѕС‚РѕСЂС‹Рµ РёРіСЂР° РґРІРёРіР°РµС‚ РїРѕ CFrame (FastCast Рё С‚.Рї.), Р»РѕРІСЏС‚СЃСЏ РїРѕ СЃРјРµС‰РµРЅРёСЋ
--  вЂў С‚РѕС‡РєРё РєР»РёРЅРєР° DmgPoint (RaycastHitbox / ClientCast) РїРѕРјРѕРіР°СЋС‚ Р»РѕРІРёС‚СЊ Р·Р°РјР°С…
--  вЂў СЃР»Р°Р±С‹Рµ С‚РµР»РµС„РѕРЅС‹: think СЃР°Рј РїРµСЂРµРєР»СЋС‡Р°РµС‚СЃСЏ РЅР° РѕР±Р»РµРіС‡С‘РЅРЅС‹Р№ СЂРµР¶РёРј
--  вЂў AutoDodge.HookRemote(...) РґР»СЏ С‚РІРѕРёС… СЂРµРјРѕСѓС‚РѕРІ, AutoDodge.DumpLearned() РґР»СЏ СЃРёРґР°
--  вЂў LEARNED_SEED / KEYFRAME_SEED РІ РїСЂРѕС„РёР»Рµ: РІС‹СѓС‡РµРЅРЅРѕРµ СЃРѕС…СЂР°РЅСЏРµС‚СЃСЏ РјРµР¶РґСѓ СЃРµСЃСЃРёСЏРјРё
--
-- РќРѕРІРѕРµ РІ v4.5:
--  вЂў СЂРµР¶РёРј В«Р·Р°РЅСЏС‚В»: РїРѕРєР° Р»РµС‡РёС€СЊ РёРіСЂРѕРєР° / РєРѕР»РґСѓРµС€СЊ / Р¶РјС‘С€СЊ РїСЂРµРґРјРµС‚-Р»РµС‡РёР»РєСѓ,
--    СѓРІРѕСЂРѕС‚ РЅРµ РґС‘СЂРіР°РµС‚ С‚РµР±СЏ СЃ РјРµСЃС‚Р° (РєРЅРѕРїРєР° РїРѕРєР°Р·С‹РІР°РµС‚ РџРђРЈР—Рђ)
--  вЂў Р·Р°Р¶РјРё LeftAlt, С‡С‚РѕР±С‹ РІСЂСѓС‡РЅСѓСЋ РїРѕСЃС‚Р°РІРёС‚СЊ СѓРІРѕСЂРѕС‚ РЅР° РїР°СѓР·Сѓ
--  вЂў РЅРµ РјРµС€Р°РµС‚ СЃРѕР±СЃС‚РІРµРЅРЅРѕРјСѓ РїРµСЂРµРєР°С‚Сѓ/Р±Р»РѕРєСѓ РёРіСЂС‹ Рё РЅРµ С‚СЂР°С‚РёС‚СЃСЏ РїСЂРё РЅРµСѓСЏР·РІРёРјРѕСЃС‚Рё
--  вЂў API РґР»СЏ С‚РІРѕРёС… РјРѕРґСѓР»РµР№: shared.AutoDodge.Busy / Pause / Resume
--
-- РќРѕРІРѕРµ РІ v4.4:
--  вЂў РїСЂРѕС„РёР»Рё РёРіСЂ: PROFILES[PlaceId] РїРѕРґРјРµРЅСЏРµС‚ РЅР°СЃС‚СЂРѕР№РєРё РїРѕРґ РєРѕРЅРєСЂРµС‚РЅСѓСЋ РёРіСЂСѓ
--  вЂў СѓС‚РµС‡РєР° РїР°РјСЏС‚Рё: РєСЌС€Рё РІСЂР°РіР° С‡РёСЃС‚СЏС‚СЃСЏ, РєРѕРіРґР° РІСЂР°Рі РїСЂРѕРїР°РґР°РµС‚
--  вЂў С‡Р°СЃС‚Рё РїРµСЂСЃРѕРЅР°Р¶РµР№ РЅРµ Р»РµР·СѓС‚ РІ СЃРїРёСЃРѕРє В«Р»РµС‚СЏС‰РёС… РґРµС‚Р°Р»РµР№В» (Р±С‹СЃС‚СЂРµРµ)
--  вЂў think С‚РµРїРµСЂСЊ СЃС‚Р°Р±РёР»СЊРЅРѕ 30 Р“С† (СЂР°РЅСЊС€Рµ РїСЂС‹РіР°Р» РјРµР¶РґСѓ 20 Рё 30)
--  вЂў СЂС‹РІРѕРє СЃСЂР°Р·Сѓ РѕР±СЂС‹РІР°РµС‚СЃСЏ РїСЂРё СЃС‚Р°РЅРµ / СЂСЌРіРґРѕР»Р»Рµ / РІС‹РєР»СЋС‡РµРЅРёРё
--  вЂў СЃР°РјРѕРѕР±СѓС‡РµРЅРёРµ Р±РµСЂС‘С‚ С‚РѕР»СЊРєРѕ 1-2 Р±Р»РёР¶Р°Р№С€РёС… РІСЂР°РіРѕРІ, СЃРјРѕС‚СЂСЏС‰РёС… РЅР° С‚РµР±СЏ
--  вЂў РЅРµ СѓРІРѕСЂР°С‡РёРІР°РµС‚СЃСЏ РЅР° Р»Р°РІСѓ / РєРёР»Р»-Р±СЂРёРєРё (РґР°Р¶Рµ РѕРіСЂРѕРјРЅС‹Рµ)
--  вЂў РѕС€РёР±РєР° РІ РѕРґРЅРѕРј РІСЂР°РіРµ Р±РѕР»СЊС€Рµ РЅРµ Р»РѕРјР°РµС‚ РІРµСЃСЊ СѓРІРѕСЂРѕС‚
--  вЂў РєРЅРѕРїРєР° РЅРµ СѓРµР·Р¶Р°РµС‚ Р·Р° СЌРєСЂР°РЅ РїСЂРё РїРµСЂРµС‚Р°СЃРєРёРІР°РЅРёРё
--
-- Р‘С‹Р»Рѕ РІ v4:
--  вЂў СЂРµРµСЃС‚СЂ РІСЂР°РіРѕРІ/С…РёС‚Р±РѕРєСЃРѕРІ С‡РµСЂРµР· СЃРѕР±С‹С‚РёСЏ (РЅРµ С‚РµСЂСЏРµС‚ РІСЂР°РіРѕРІ РІ С‚РѕР»РїРµ РґРµС‚Р°Р»РµР№)
--  вЂў РѕРєРЅР° РІСЂРµРјРµРЅРё: СѓРІРѕСЂРѕС‚ С‚РѕР»СЊРєРѕ РєРѕРіРґР° СѓРґР°СЂ СЂРµР°Р»СЊРЅРѕ РґРѕР»РµС‚РёС‚
--  вЂў СЃР°РјРѕРѕР±СѓС‡РµРЅРёРµ: Р·Р°РїРѕРјРёРЅР°РµС‚ Р°РЅРёРјР°С†РёРё, РїРѕСЃР»Рµ РєРѕС‚РѕСЂС‹С… С‚РµР±СЏ СѓРґР°СЂРёР»Рё
--  вЂў Р»РёРЅРёСЏ РѕРіРЅСЏ: С€Р°Рі РІ СЃС‚РѕСЂРѕРЅСѓ РѕС‚ СЃС‚СЂРµР»РєР°/РєР°СЃС‚РµСЂР°
--  вЂў Р·Р°РјР°С… РѕСЂСѓР¶РёСЏ/СЂСѓРє РєР°Рє РїСЂРёР·РЅР°Рє Р°С‚Р°РєРё, РїСЂС‹Р¶РѕРє РєР°Рє РїРѕСЃР»РµРґРЅРёР№ С€Р°РЅСЃ
--  вЂў РґСЌС€ (СЂС‹РІРѕРє) Рё СѓРІРѕСЂРѕС‚ РѕС‚ РѕРіРЅРµСЃС‚СЂРµР»Р°: РїСЂРёС†РµР», РІС‹СЃС‚СЂРµР», Р»РёРЅРёСЏ РѕРіРЅСЏ
--  вЂў РєРЅРѕРїРєР° Р’РљР›/Р’Р«РљР› (С‚РµР»РµС„РѕРЅ), РѕС‚Р»Р°РґРєР° СЂРёСЃСѓРЅРєРѕРј Рё С‚РµРєСЃС‚РѕРј
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--==============================================================
-- Р Р•Р–РРњ Р РќРђРЎРўР РћР™РљР
--==============================================================

local MODE = "PARANOID" -- "CALM" (СЂРµР¶Рµ) | "BALANCED" | "PARANOID" (С‡Р°С‰Рµ, РѕС‚ РІСЃРµРіРѕ)

local OVERRIDE = {
	-- СЃСЋРґР° РїРёС€Рё СЃРІРѕРё Р·РЅР°С‡РµРЅРёСЏ, РѕРЅРё СЃРёР»СЊРЅРµРµ СЂРµР¶РёРјР°, РЅР°РїСЂРёРјРµСЂ:
	-- MARGIN = 3.5,
	-- ENABLE_SPEED_BOOST = false,
}

-- РџСЂРѕС„РёР»Рё РёРіСЂ: РѕРґРёРЅ СЃРєСЂРёРїС‚ РЅР° РІСЃРµ С‚РІРѕРё РёРіСЂС‹. РџРѕРґР±РёСЂР°РµС‚СЃСЏ РїРѕ PlaceId РёР»Рё GameId.
-- Р’РЅСѓС‚СЂРё Р»СЋР±С‹Рµ РєР»СЋС‡Рё РёР· CFG (СЃРїРёСЃРєРё Р·Р°РјРµРЅСЏСЋС‚СЃСЏ С†РµР»РёРєРѕРј) Рё MODE.
local PROFILES = {
	-- [1234567890] = {
	-- 	MODE = "BALANCED",
	-- 	IGNORE_PART_NAMES = { "Head_Hitbox" },
	-- 	ATTACK_ANIMATION_IDS = { ["rbxassetid://123"] = true },
	-- 	DANGER_TAGS = { "Hitbox" },
	-- },
}

local MODES = {
	CALM = {
		TRIGGER_TIME = 0.45, MARGIN = 2.4, USE_ACTION_ANIMATIONS = false,
		DETECT_SWINGS = false, DODGE_LINE_OF_FIRE = false, STATIC_ZONES = false, DODGE_AIMED_GUNS = false,
	},
	BALANCED = {
		TRIGGER_TIME = 0.70, MARGIN = 3.2, USE_ACTION_ANIMATIONS = true,
		DETECT_SWINGS = true, DODGE_LINE_OF_FIRE = true, STATIC_ZONES = true, DODGE_AIMED_GUNS = true,
	},
	PARANOID = {
		TRIGGER_TIME = 0.85, MARGIN = 4.2, USE_ACTION_ANIMATIONS = true,
		DETECT_SWINGS = true, DODGE_LINE_OF_FIRE = true, STATIC_ZONES = true, DODGE_AIMED_GUNS = true,
	},
}

local CFG = {
	ENABLED = true,
	START_ENABLED = true,
	TOGGLE_BUTTON = true,
	TOGGLE_KEY = Enum.KeyCode.K,
	LANGUAGE = "auto", -- СЏР·С‹Рє РєРЅРѕРїРєРё: "auto" (РїРѕ СЏР·С‹РєСѓ Р РѕР±Р»РѕРєСЃР°) | "ru" | "en"

	-- РџРѕРёСЃРє
	DETECT_RADIUS = 60,
	MAX_THREATS = 8,
	THINK_RATE = 1 / 30,
	ADAPTIVE_PERF = true,   -- СЃР»Р°Р±С‹Р№ С‚РµР»РµС„РѕРЅ: СЃР°Рј СЃРЅРёР¶Р°РµС‚ С‡Р°СЃС‚РѕС‚Сѓ Рё С‡РёСЃР»Рѕ РЅР°РїСЂР°РІР»РµРЅРёР№
	PERF_BUDGET_MS = 3.0,   -- РµСЃР»Рё think РІ СЃСЂРµРґРЅРµРј РґРѕР»СЊС€Рµ, РІРєР»СЋС‡Р°РµРј РѕР±Р»РµРіС‡С‘РЅРЅС‹Р№ СЂРµР¶РёРј
	LOW_THINK_RATE = 1 / 20,
	LOW_DIRECTIONS = 16,

	-- РЎРёРјСѓР»СЏС†РёСЏ
	HORIZON = 0.85,
	STEP = 0.07,
	REACTION_LAG = 0.06,
	PING_COMP = true,
	VEL_TIME_CAP = 0.6,    -- РІСЂР°Рі РЅРµ Р±РµР¶РёС‚ Р·Р° С‚РѕР±РѕР№ РґРѕР»СЊС€Рµ СЌС‚РѕРіРѕ РІ СЂР°СЃС‡С‘С‚Рµ
	STATIC_MARGIN = 1.2,   -- Р·Р°РїР°СЃ Сѓ РЅРµРїРѕРґРІРёР¶РЅС‹С… Р·РѕРЅ

	-- Р’СЂР°РіРё
	MELEE_REACH = 8,
	SCALE_REACH = true, -- СЂР°РґРёСѓСЃ СѓРґР°СЂР° СЂР°СЃС‚С‘С‚/СѓРјРµРЅСЊС€Р°РµС‚СЃСЏ СЃ СЂР°Р·РјРµСЂРѕРј РІСЂР°РіР° (Р±РѕСЃСЃС‹, РјРµР»РєРёРµ РјРѕР±С‹)
	REACH_SIDE = 0.85,
	REACH_BACK = 0.55,
	ATTACK_CHECK_RANGE = 35,
	LUNGE_SPEED = 22,
	IGNORE_TEAMMATES = true,
	IGNORE_NAMES = {},
	-- РґРµС‚Р°Р»Рё, РєРѕС‚РѕСЂС‹Рµ РќРРљРћР“Р”Рђ РЅРµ СЃС‡РёС‚Р°СЋС‚СЃСЏ СѓРіСЂРѕР·РѕР№ (С…РёС‚Р±РѕРєСЃС‹ РіРѕР»РѕРІ, СЂСЌРіРґРѕР»Р»-РґР°РЅРЅС‹Рµ Рё С‚.Рї.)
	IGNORE_PART_NAMES = { "Head_Hitbox", "HitboxWeld" },
	IGNORE_ANCESTOR_NAMES = { "RagdollData" },
	IGNORE_TAGS = { "NoDodge" },
	ATTACK_END_FRACTION = 0.8, -- РїРѕСЃР»Рµ СЌС‚РѕР№ РґРѕР»Рё Р°РЅРёРјР°С†РёРё СѓРґР°СЂ СѓР¶Рµ Р·Р°РєРѕРЅС‡РµРЅ
	SWING_TOOL_SPEED = 34,
	SWING_LIMB_SPEED = 42,

	-- Р›РёРЅРёСЏ РѕРіРЅСЏ
	LINE_MIN_DIST = 14,
	LINE_MAX_DIST = 140,
	LINE_ANGLE_DOT = 0.88,

	-- РћРіРЅРµСЃС‚СЂРµР»: СЃС‚СЂРµР»РѕРє С†РµР»РёС‚СЃСЏ РІ С‚РµР±СЏ РёР»Рё СЃС‚СЂРµР»СЏРµС‚ -> СѓС…РѕРґРёРј СЃ Р»РёРЅРёРё РѕРіРЅСЏ
	-- (РјРіРЅРѕРІРµРЅРЅС‹Р№ РІС‹СЃС‚СЂРµР» РЅРµ СѓРІРёРґРµС‚СЊ Р·Р°СЂР°РЅРµРµ, РїРѕСЌС‚РѕРјСѓ СЂРµР°РіРёСЂСѓРµРј РЅР° РїСЂРёС†РµР»)
	GUN_ANGLE_DOT = 0.93,
	SHOT_ANGLE_DOT = 0.85,
	GUN_MIN_DIST = 3,
	GUN_LANE_WIDTH = 2.2,
	SHOT_WINDOW = 0.35,
	GUN_TOOL_WORDS = {
		"gun", "pistol", "rifle", "shotgun", "smg", "revolver", "sniper",
		"blaster", "crossbow", "longbow", "shortbow", "launcher", "glock",
		"deagle", "uzi", "ak47", "m4a1", "m16", "scar", "mp5", "musket",
		"cannon", "wand", "staff", "rocket", "laser", "taser",
	},
	GUN_PART_WORDS = { "muzzle", "barrel", "firepoint", "firepos", "bulletspawn", "magazine", "ammo" },
	GUN_ATTRIBUTES = { "Ammo", "FireRate", "Spread", "Magazine", "Bullets", "Recoil", "ReloadTime" },
	AIM_TAGS = { "AimThreat" }, -- С‚РµРі РЅР° РґРµС‚Р°Р»СЊ-РґСѓР»Рѕ: СЃРјРѕС‚СЂРёС‚ РїРѕ LookVector (С‚СѓСЂРµР»Рё Рё С‚.Рї.)

	-- РЎРЅР°СЂСЏРґС‹ Рё С…РёС‚Р±РѕРєСЃС‹
	MIN_PROJECTILE_SPEED = 12,
	FAST_PROJECTILE_SPEED = 28,
	MAX_PART_SIZE = 80,
	MAX_PROJECTILE_SIZE = 30,
	USE_TAGS = true,
	ANCESTOR_FLAGS = true, -- РґРµС‚Р°Р»Рё РІ РїР°РїРєРµ/РјРѕРґРµР»Рё СЃ РёРјРµРЅРµРј Projectiles, Hitboxes, Lava... РѕРїР°СЃРЅС‹
	CFRAME_PROJECTILES = true, -- СЃРЅР°СЂСЏРґС‹, РєРѕС‚РѕСЂС‹Рµ РёРіСЂР° РґРІРёРіР°РµС‚ РїРѕ CFrame (FastCast Рё С‚.Рї.), Р»РѕРІРёРј РїРѕ СЃРјРµС‰РµРЅРёСЋ
	YOUNG_LIFETIME = 8,        -- СЃРєРѕР»СЊРєРѕ СЃРµРєСѓРЅРґ РЅРѕРІР°СЏ РґРµС‚Р°Р»СЊ СЃС‡РёС‚Р°РµС‚СЃСЏ В«РІРѕР·РјРѕР¶РЅС‹Рј СЃРЅР°СЂСЏРґРѕРјВ»

	-- РћР±СѓС‡РµРЅРёРµ РїРѕ СѓСЂРѕРЅСѓ
	AUTO_LEARN = true,
	LEARN_RADIUS = 30,
	LEARN_EARLY = 0.14,
	LEARN_LATE = 0.28,
	LEARNED_SEED = {},  -- РїСЂРµРґР·Р°РїРѕР»РЅРµРЅРёРµ: ["rbxassetid://123"] = { n = 2, hitAt = 0.35 } (СЃРј. AutoDodge.DumpLearned())
	KEYFRAME_SEED = {}, -- РјРѕРјРµРЅС‚С‹ СѓРґР°СЂР° РІ СЃРµРєСѓРЅРґР°С…: ["rbxassetid://123"] = { 0.35, 0.8 }

	-- РўР°Р№РјРёРЅРіРё РёР· СЃР°РјРѕР№ Р°РЅРёРјР°С†РёРё: РєР»СЋС‡РµРІС‹Рµ РєР°РґСЂС‹/РјР°СЂРєРµСЂС‹ СЃ РёРјРµРЅР°РјРё Hit, Damage, Strike...
	USE_KEYFRAME_DATA = true,  -- С‡РёС‚Р°С‚СЊ KeyframeSequence Р·Р°СЂР°РЅРµРµ (СЂР°Р±РѕС‚Р°РµС‚ РґР»СЏ Р°РЅРёРјР°С†РёР№ С‚РІРѕРµР№ РёРіСЂС‹/РіСЂСѓРїРїС‹)
	LEARN_FROM_MARKERS = true, -- Р·Р°РїРѕРјРёРЅР°С‚СЊ РјРѕРјРµРЅС‚С‹ СѓРґР°СЂР° РїРѕ KeyframeReached Сѓ РґСЂСѓРіРёС… РёРіСЂРѕРєРѕРІ Рё РјРѕР±РѕРІ
	HIT_MARKER_WORDS = {
		"hit", "damage", "strike", "slash", "impact", "swing", "punch", "kick", "stab",
		"smash", "slam", "attack", "hitbox", "release", "launch", "shoot", "fire", "cast",
	},
	HIT_MARKER_NAMES = { "Hit", "HitStart", "Damage", "DamageStart", "Strike", "Slash", "Impact", "Release", "Shoot", "Fire" },
	HIT_ATTACHMENT_NAMES = { "DmgPoint", "DamagePoint", "HitPoint", "HitboxPoint" }, -- С‚РѕС‡РєРё РєР»РёРЅРєР° (RaycastHitbox/ClientCast)
	LEARN_MAX_ATTACKERS = 2, -- Сѓ СЃРєРѕР»СЊРєРёС… Р±Р»РёР¶Р°Р№С€РёС… РІСЂР°РіРѕРІ СѓС‡РёРј Р°РЅРёРјР°С†РёРё Р·Р° РѕРґРёРЅ СѓРґР°СЂ
	LEARN_MIN_HITS = 1,      -- СЃРєРѕР»СЊРєРѕ СѓРґР°СЂРѕРІ РЅСѓР¶РЅРѕ, С‡С‚РѕР±С‹ Р°РЅРёРјР°С†РёСЏ СЃС‚Р°Р»Р° В«РёР·РІРµСЃС‚РЅРѕР№В» (2 = РјРµРЅСЊС€Рµ Р»РѕР¶РЅС‹С…)

	-- Р’С‹Р±РѕСЂ РЅР°РїСЂР°РІР»РµРЅРёСЏ
	DIRECTIONS = 24,
	WALL_RAY = 12,
	LEDGE_CHECK = true,
	LEDGE_DEPTH = 16,
	DANGER_GROUND_PENALTY = 10, -- С€С‚СЂР°С„ Р·Р° С€Р°Рі РЅР° Р»Р°РІСѓ/РєРёР»Р»-Р±СЂРёРє (0 = РІС‹РєР»)

	-- РџСЂС‹Р¶РѕРє РєР°Рє РїРѕСЃР»РµРґРЅРёР№ С€Р°РЅСЃ
	JUMP_DODGE = true,
	JUMP_COOLDOWN = 0.7,

	-- РЎС‚Р°Р±РёР»СЊРЅРѕСЃС‚СЊ
	COMMIT_TIME = 0.16,
	PANIC_COMMIT_TIME = 0.08,
	PANIC_TIME = 0.28,
	HOLD_TIME = 0.30,
	SMOOTH = 22,
	SWITCH_GAIN = 0.6,

	-- РЈРїСЂР°РІР»РµРЅРёРµ РёРіСЂРѕРєРѕРј
	MANUAL_BIAS = 1.6,
	MANUAL_BLEND = 0.12,

	-- РЎРєРѕСЂРѕСЃС‚СЊ
	ENABLE_SPEED_BOOST = true,
	SPEED_MULT = 1.18,
	PANIC_SPEED_MULT = 1.30,

	-- РќРµ СЂР°Р±РѕС‚Р°С‚СЊ РІ СЌС‚РёС… СЃРѕСЃС‚РѕСЏРЅРёСЏС… (Р°С‚СЂРёР±СѓС‚С‹ РЅР° РїРµСЂСЃРѕРЅР°Р¶Рµ)
	PAUSE_ATTRIBUTES = { "Stunned", "Ragdoll", "Ragdolled", "Frozen", "Knocked", "Grabbed", "Gripped", "Rooted", "Cutscene", "Downed" },
	SKIP_WITH_FORCEFIELD = true,
	IMMUNE_ATTRIBUTES = { "Invincible", "Invulnerable", "IFrames", "Immune", "GodMode" }, -- РЅРµСѓСЏР·РІРёРј: СѓРІРѕСЂРѕС‚ РЅРµ РЅСѓР¶РµРЅ

	-- В«Р—Р°РЅСЏС‚В»: Р»РµС‡Сѓ РёРіСЂРѕРєР°, РєРѕР»РґСѓСЋ, РІР·Р°РёРјРѕРґРµР№СЃС‚РІСѓСЋ... РЈРІРѕСЂРѕС‚ РЅРµ СѓРІРѕРґРёС‚ С‚РµР±СЏ СЃ РјРµСЃС‚Р°.
	-- РџСЂРёР·РЅР°РєРё (Р»СЋР±РѕР№): Р°С‚СЂРёР±СѓС‚ РЅР° РїРµСЂСЃРѕРЅР°Р¶Рµ/Humanoid, Р°С‚СЂРёР±СѓС‚ DodgeBusy РЅР° РёРіСЂРѕРєРµ,
	-- Р·Р°Р¶Р°С‚Р°СЏ РєРЅРѕРїРєР° РїСЂРµРґРјРµС‚Р°-Р»РµС‡РёР»РєРё, С‚РІРѕСЏ Р°РЅРёРјР°С†РёСЏ Р»РµС‡РµРЅРёСЏ, РІС‹Р·РѕРІ AutoDodge.Busy().
	BUSY_ATTRIBUTES = {
		"Healing", "Casting", "Channeling", "Reviving", "Interacting", "Carrying", "Busy",
		"Blocking", "Parrying", "Rolling", "Dodging", "Dashing",
	},
	BUSY_TOOL_WORDS = { "heal", "medkit", "bandage", "syringe", "revive" }, -- РёРјСЏ РїСЂРµРґРјРµС‚Р° РІ СЂСѓРєРµ
	BUSY_ANIMATION_WORDS = { "heal", "channel", "revive", "bandage", "drink", "consume", "interact", "carry" },
	BUSY_ANIMATION_IDS = {}, -- ["rbxassetid://123"] = true
	BUSY_TAIL = 0.5,          -- СЃРєРѕР»СЊРєРѕ РµС‰С‘ В«Р·Р°РЅСЏС‚В» РїРѕСЃР»Рµ РѕС‚РїСѓСЃРєР°РЅРёСЏ РєРЅРѕРїРєРё РїСЂРµРґРјРµС‚Р°
	BUSY_ALLOW_PANIC = false, -- true: РґР°Р¶Рµ РєРѕРіРґР° Р·Р°РЅСЏС‚, СѓС…РѕРґРёС‚СЊ РѕС‚ СѓРґР°СЂР° В«РїСЂСЏРјРѕ СЃРµР№С‡Р°СЃВ»
	SUSPEND_KEY = Enum.KeyCode.LeftAlt, -- РїРѕРєР° РґРµСЂР¶РёС€СЊ, СѓРІРѕСЂРѕС‚ РЅР° РїР°СѓР·Рµ (nil = РЅРµС‚)

	-- Р”СЌС€ (СЂС‹РІРѕРє): РєРѕРіРґР° СѓРґР°СЂ РІРѕС‚-РІРѕС‚ РїРѕРїР°РґС‘С‚, Р° РѕР±С‹С‡РЅС‹Рј С€Р°РіРѕРј РЅРµ СѓР№С‚Рё
	DASH_ENABLED = true,
	DASH_SPEED = 62,      -- СЃС‚СѓРґРѕРІ/СЃРµРє РІРѕ РІСЂРµРјСЏ СЂС‹РІРєР°
	DASH_TIME = 0.2,      -- РґР»РёС‚РµР»СЊРЅРѕСЃС‚СЊ (РѕРєРѕР»Рѕ 12 СЃС‚СѓРґРѕРІ)
	DASH_COOLDOWN = 1.1,
	DASH_GAIN = 0.8,      -- РЅР°СЃРєРѕР»СЊРєРѕ СЂС‹РІРѕРє РґРѕР»Р¶РµРЅ Р±С‹С‚СЊ Р»СѓС‡С€Рµ С€Р°РіР°
	DASH_NEED = 1.0,      -- СЂС‹РІРѕРє С‚РѕР»СЊРєРѕ РµСЃР»Рё Сѓ С€Р°РіР° Р·Р°РїР°СЃ РјРµРЅСЊС€Рµ СЌС‚РѕРіРѕ
	DASH_IN_AIR = false,
	DASH_HOOK = nil,      -- function(direction, urgency) end: СЃРІРѕСЏ Р°РЅРёРјР°С†РёСЏ/Р·РІСѓРє/СЂРµРјРѕСѓС‚

	DANGER_TAGS = {
		"AttackHitbox", "Hitbox", "DamageHitbox", "Danger",
		"Projectile", "Attack", "Hurtbox", "Damage",
	},
	DANGER_NAME_WORDS = {
		"hitbox", "hurtbox", "damage", "attack", "projectile", "danger",
		"slash", "swing", "strike", "lunge", "impact", "bullet",
		"missile", "fireball", "spell", "explosion", "blast",
		"shockwave", "aoe", "laser", "lava", "killbrick", "killpart", "killzone",
		"acid", "poison", "spike", "sawblade", "bomb", "grenade", "rocket",
		"arrow", "dart", "knife", "shuriken", "kunai",
	},
	DAMAGE_ATTRIBUTES = { "Damage", "DamageAmount", "Dmg" },
	INACTIVE_ATTRIBUTES = { "Active", "Enabled", "CanDamage", "DamageActive", "HitboxActive" },
	OWNER_NAMES = { "Owner", "Attacker", "Creator", "Source", "OwnerCharacter", "AttackerCharacter" },
	ATTACK_ATTRIBUTES = {
		"IsAttacking", "Attacking", "AttackActive", "IsAttackActive",
		"AttackCommitted", "Swinging", "Dashing", "Charging",
		"AttackingNow", "CanDamage", "DamageActive", "HitboxActive",
	},
	ATTACK_ANIMATION_WORDS = {
		"attack", "swing", "slash", "strike", "lunge", "punch", "kick",
		"stab", "shoot", "cast", "skill", "ability", "combo",
		"smash", "slam", "bite", "claw", "charge", "damage",
		"fire", "throw", "shot", "blast", "beam",
		"barrage", "uppercut", "bash", "drill", "explode", "rapid", "spin", "bullet",
	},
	IGNORE_ANIMATION_WORDS = {
		"idle", "walk", "run", "jump", "fall", "climb", "swim", "sit",
		"emote", "dance", "wave", "laugh", "cheer", "point", "toolnone",
		"block", "equip", "unequip", "hold", "stun",
		"hurt", "flinch", "react", "getup", "death", "dead",
	},
	ATTACK_ANIMATION_IDS = {}, -- СЃСЋРґР° РјРѕР¶РЅРѕ РІРїРёСЃР°С‚СЊ "rbxassetid://123"

	DEBUG = false,
	DEBUG_DRAW = false,
	DEBUG_HUD = false,
}

-- РїРѕСЂСЏРґРѕРє: MODE -> РїСЂРѕС„РёР»СЊ РёРіСЂС‹ -> OVERRIDE (РїРѕСЃР»РµРґРЅРёР№ СЃРёР»СЊРЅРµРµ РІСЃРµС…)
local profile = PROFILES[game.PlaceId] or PROFILES[game.GameId] or {}
for k, v in pairs(MODES[profile.MODE or MODE] or MODES.BALANCED) do
	CFG[k] = v
end
-- РѕРїРµС‡Р°С‚РєРё РІ РёРјРµРЅР°С… РЅР°СЃС‚СЂРѕРµРє: РїСЂРµРґСѓРїСЂРµР¶РґР°РµРј, Р° РЅРµ РјРѕР»С‡РёРј
local NIL_KEYS = { DASH_HOOK = true }
local function checkKeys(tbl, label)
	for k in pairs(tbl) do
		if k ~= "MODE" and CFG[k] == nil and not NIL_KEYS[k] then
			warn(string.format("[AutoDodge] %s: РЅРµРёР·РІРµСЃС‚РЅР°СЏ РЅР°СЃС‚СЂРѕР№РєР° '%s' (РѕРїРµС‡Р°С‚РєР°?)", label, tostring(k)))
		end
	end
end
checkKeys(profile, "PROFILES")
checkKeys(OVERRIDE, "OVERRIDE")
for k, v in pairs(profile) do
	if k ~= "MODE" then
		CFG[k] = v
	end
end
for k, v in pairs(OVERRIDE) do
	CFG[k] = v
end

local CAP = 7
local FAR = 1e6

local ACTION_PRIORITIES = {
	[Enum.AnimationPriority.Action] = true,
	[Enum.AnimationPriority.Action2] = true,
	[Enum.AnimationPriority.Action3] = true,
	[Enum.AnimationPriority.Action4] = true,
}

--==============================================================
-- STATE
--==============================================================

local Character, Humanoid, Root
local rayParams

local charConns, rootConns = {}, {}

local enabled = CFG.START_ENABLED
local baseSpeed, boosted, lastSet = 16, false, 0

local threats = {}
local active, panic = false, false
local targetDir, curDir = Vector3.zero, Vector3.zero
local dodgeUntil, lastChoose, lastThink = 0, 0, 0
local lastJump, lastDash = -math.huge, -math.huge
local dashDir, dashUntil, dashWas = Vector3.zero, 0, false
local pingValue, lastPing = 0, 0
local lastError = ""
local jumpPlanned = false
local lastManual, lastManualTime = Vector3.zero, 0
local lastStats = { threats = 0, tHit = nil }
local hardPauseUntil, busyUntil = 0, 0 -- Pause()/Busy() РёР· РёРіСЂС‹ Рё В«С…РІРѕСЃС‚В» РїРѕСЃР»Рµ РїСЂРµРґРјРµС‚Р°
local suspendHeld = false              -- РґРµСЂР¶РёС€СЊ SUSPEND_KEY
local toolDown = {}                    -- [Tool] = true, РїРѕРєР° Р·Р°Р¶Р°С‚Р° РєРЅРѕРїРєР° Р»РµС‡РёР»РєРё
local holdPause, shownPause = false, false -- РїР°СѓР·Р° РёР·-Р·Р° В«Р·Р°РЅСЏС‚В»/СЂСѓС‡РЅР°СЏ (РґР»СЏ РєРЅРѕРїРєРё)
local ownAnim = { t = -1, v = false }

local humanoids = {}          -- [Humanoid] = true
local manualThreats = {}      -- СѓРіСЂРѕР·С‹ РёР· shared.AutoDodge
local flaggedParts = {}       -- [BasePart] = true
local aimParts = {}           -- [BasePart] = true (С‚РµРі AimThreat)
local dynamicParts = {}       -- [BasePart] = true
local motion = setmetatable({}, { __mode = "k" })
local ownerCache = setmetatable({}, { __mode = "k" })
local animCache = setmetatable({}, { __mode = "k" })
local swingCache = setmetatable({}, { __mode = "k" })
local rangedCache = setmetatable({}, { __mode = "k" })
local shotAt = setmetatable({}, { __mode = "k" })
local watched = setmetatable({}, { __mode = "k" })
local learned = {}            -- [animationId] = { n = count, hitAt = seconds }
local kfInfo = {}             -- [animationId] = { hits = {СЃРµРєСѓРЅРґС‹...}, src } РёР»Рё false (С‡РёС‚Р°Р»Рё, РЅРёС‡РµРіРѕ РЅРµС‚)
local kfPending = {}          -- [animationId] = true, РїРѕРєР° РіСЂСѓР·РёС‚СЃСЏ KeyframeSequence
local kfLive = {}             -- [animationId] = { hits = {...}, src = "live" } РёР· РЅР°Р±Р»СЋРґРµРЅРёСЏ Р·Р° РјР°СЂРєРµСЂР°РјРё
local hookedTracks = setmetatable({}, { __mode = "k" })
local youngParts = {}         -- [BasePart] = РІСЂРµРјСЏ РїРѕСЏРІР»РµРЅРёСЏ (РґРІРёРіР°РµРјС‹Рµ РїРѕ CFrame СЃРЅР°СЂСЏРґС‹)
local scanDone = false
local thinkAvg, perfLow = 0, false
local isIgnoredModel          -- Р·Р°РґР°С‘С‚СЃСЏ РЅРёР¶Рµ (РЅСѓР¶РЅР° Рё РѕР±СѓС‡РµРЅРёСЋ, Рё СЃР±РѕСЂСѓ СѓРіСЂРѕР·)

local controls = nil
local dynNear, dynNearT = {}, -math.huge

--==============================================================
-- HELPERS
--==============================================================

local function flat(v)
	return Vector3.new(v.X, 0, v.Z)
end

local function unit(v)
	local m = v.Magnitude
	if m > 1e-4 then
		return v / m
	end
	return Vector3.zero
end

local function isAlive()
	return Humanoid ~= nil
		and Humanoid.Parent ~= nil
		and Humanoid.Health > 0
		and Root ~= nil
		and Root.Parent ~= nil
end

local function containsWord(name, words)
	if type(name) ~= "string" or name == "" then
		return false
	end
	local lower = string.lower(name)
	for _, w in ipairs(words) do
		if string.find(lower, w, 1, true) then
			return true
		end
	end
	return false
end

local function attrActive(inst)
	if not inst then
		return false
	end
	for _, name in ipairs(CFG.ATTACK_ATTRIBUTES) do
		local v = inst:GetAttribute(name)
		if v == true or (type(v) == "number" and v > 0) then
			return true
		end
	end
	return false
end

-- Р’СЂР°Рі = РјРѕРґРµР»СЊ СЃ Humanoid РР›Р СЃ AnimationController (Р±РѕСЃСЃС‹/РјРѕР±С‹ Р±РµР· Humanoid)
local function isActorModel(model)
	return model:IsA("Model")
		and (model:FindFirstChildOfClass("Humanoid") ~= nil
			or model:FindFirstChildOfClass("AnimationController") ~= nil)
end

local function actorDead(actor)
	return actor:IsA("Humanoid") and actor.Health <= 0
end

local function getRoot(model)
	if not model:IsA("Model") then
		return nil
	end
	local r = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if r and r:IsA("BasePart") then
		return r
	end
	local t = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
	if t and t:IsA("BasePart") then
		return t
	end
	for _, n in ipairs({ "RootPart", "Root", "Hitbox", "Body" }) do
		local x = model:FindFirstChild(n)
		if x and x:IsA("BasePart") then
			return x
		end
	end
	return model:FindFirstChildWhichIsA("BasePart")
end

local function ownerIsMe(value)
	if value == nil then
		return false
	end
	if typeof(value) == "Instance" then
		return value == LocalPlayer
			or (Character ~= nil and (value == Character or value:IsDescendantOf(Character)))
	end
	if type(value) == "number" then
		return value == LocalPlayer.UserId
	end
	if type(value) == "string" then
		return value == LocalPlayer.Name or value == tostring(LocalPlayer.UserId)
	end
	return false
end

-- Р”РµС‚Р°Р»СЊ РїСЂРёРЅР°РґР»РµР¶РёС‚ РјРЅРµ (РјРѕР№ СЃРЅР°СЂСЏРґ/РјРѕР№ С…РёС‚Р±РѕРєСЃ). РљСЌС€ 2 СЃРµРє.
local function isMine(part, now)
	if Character and part:IsDescendantOf(Character) then
		return true
	end
	local rec = ownerCache[part]
	if rec and now - rec.t < 2 then
		return rec.v
	end
	local mine = false
	local cur = part
	for _ = 1, 4 do
		if not cur or cur == Workspace then
			break
		end
		for _, n in ipairs(CFG.OWNER_NAMES) do
			local child = cur:FindFirstChild(n)
			if child and child:IsA("ObjectValue") and ownerIsMe(child.Value) then
				mine = true
			end
			if ownerIsMe(cur:GetAttribute(n)) then
				mine = true
			end
		end
		if ownerIsMe(cur:GetAttribute("OwnerUserId")) or ownerIsMe(cur:GetAttribute("AttackerUserId")) then
			mine = true
		end
		if mine then
			break
		end
		cur = cur.Parent
	end
	ownerCache[part] = { v = mine, t = now }
	return mine
end

--==============================================================
-- Р Р•Р•РЎРўР Р« (СЃРѕР±С‹С‚РёСЏ РІРјРµСЃС‚Рѕ СЃРєР°РЅРёСЂРѕРІР°РЅРёСЏ РІСЃРµРіРѕ РІРѕРєСЂСѓРі)
--==============================================================

local function computeFlag(part)
	if CFG.USE_TAGS then
		for _, tag in ipairs(CFG.DANGER_TAGS) do
			if CollectionService:HasTag(part, tag) then
				return true
			end
		end
	end
	if containsWord(part.Name, CFG.DANGER_NAME_WORDS) then
		return true
	end
	for _, attr in ipairs(CFG.DAMAGE_ATTRIBUTES) do
		if part:GetAttribute(attr) ~= nil then
			return true
		end
	end
	return false
end

local function ignoredPart(part)
	if table.find(CFG.IGNORE_PART_NAMES, part.Name) then
		return true
	end
	local cur = part.Parent
	for _ = 1, 6 do
		if not cur or cur == Workspace then
			break
		end
		if table.find(CFG.IGNORE_ANCESTOR_NAMES, cur.Name) then
			return true
		end
		cur = cur.Parent
	end
	return false
end

-- Р”РµС‚Р°Р»СЊ РІРЅСѓС‚СЂРё РїРµСЂСЃРѕРЅР°Р¶Р°/РјРѕР±Р° (СЃ Humanoid): С‚Р°РєРёРµ РЅРµ Р±С‹РІР°СЋС‚ В«Р»РµС‚СЏС‰РёРј СЃРЅР°СЂСЏРґРѕРјВ»
local function inCharacterModel(inst)
	local cur = inst.Parent
	for _ = 1, 6 do
		if not cur or cur == Workspace then
			return false
		end
		if isActorModel(cur) then
			return true
		end
		cur = cur.Parent
	end
	return false
end

-- Р”РµС‚Р°Р»СЊ Р»РµР¶РёС‚ РІ РїР°РїРєРµ/РјРѕРґРµР»Рё СЃ В«РѕРїР°СЃРЅС‹РјВ» РёРјРµРЅРµРј (Projectiles, Hitboxes, Lava...), РґР°Р¶Рµ РµСЃР»Рё СЃР°РјР° Р·РѕРІС‘С‚СЃСЏ Part
local ancFlagCache = setmetatable({}, { __mode = "k" })
local function ancestorDanger(part)
	local cur = part.Parent
	for _ = 1, 3 do
		if not cur or cur == Workspace then
			return false
		end
		local c = ancFlagCache[cur]
		if c == nil then
			c = containsWord(cur.Name, CFG.DANGER_NAME_WORDS)
				and not isActorModel(cur)
				and not inCharacterModel(cur)
			ancFlagCache[cur] = c
		end
		if c then
			return true
		end
		cur = cur.Parent
	end
	return false
end

local function classify(inst)
	if inst:IsA("Humanoid") or inst:IsA("AnimationController") then
		humanoids[inst] = true
	elseif inst:IsA("BasePart") then
		if flaggedParts[inst] or dynamicParts[inst] then
			return
		end
		if ignoredPart(inst) then
			return
		end
		if computeFlag(inst) or (CFG.ANCESTOR_FLAGS and ancestorDanger(inst)) then
			flaggedParts[inst] = true
		elseif not inst.Anchored then
			if not inCharacterModel(inst) then
				dynamicParts[inst] = true
			end
		elseif CFG.CFRAME_PROJECTILES and scanDone and not inCharacterModel(inst) then
			local sz = inst.Size
			if math.max(sz.X, sz.Y, sz.Z) <= CFG.MAX_PROJECTILE_SIZE then
				youngParts[inst] = os.clock()
			end
		end
	end
end

local function unclassify(inst)
	if humanoids[inst] then
		-- РІСЂР°Рі РёСЃС‡РµР·: С‡РёСЃС‚РёРј РІСЃС‘, С‡С‚Рѕ РґРµСЂР¶Р°Р»Рѕ РЅР° РЅРµРіРѕ СЃСЃС‹Р»РєРё
		humanoids[inst] = nil
		animCache[inst] = nil
		local model = inst.Parent
		if model then
			swingCache[model] = nil
			shotAt[model] = nil
		end
	end
	flaggedParts[inst] = nil
	dynamicParts[inst] = nil
	aimParts[inst] = nil
	youngParts[inst] = nil
end

local function addTagged(inst)
	if not inst:IsDescendantOf(Workspace) then
		return
	end
	if inst:IsA("BasePart") then
		if not ignoredPart(inst) then
			dynamicParts[inst] = nil
			flaggedParts[inst] = true
		end
	else
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") and not ignoredPart(d) then
				dynamicParts[d] = nil
				flaggedParts[d] = true
			end
		end
	end
end

local function startRegistries()
	table.insert(rootConns, Workspace.DescendantAdded:Connect(classify))
	table.insert(rootConns, Workspace.DescendantRemoving:Connect(unclassify))

	if CFG.USE_TAGS then
		for _, tag in ipairs(CFG.DANGER_TAGS) do
			table.insert(rootConns, CollectionService:GetInstanceAddedSignal(tag):Connect(addTagged))
			for _, inst in ipairs(CollectionService:GetTagged(tag)) do
				if inst:IsDescendantOf(Workspace) then
					addTagged(inst)
				end
			end
		end
	end

	for _, tag in ipairs(CFG.AIM_TAGS) do
		table.insert(rootConns, CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
			if inst:IsA("BasePart") and inst:IsDescendantOf(Workspace) then
				aimParts[inst] = true
			end
		end))
		for _, inst in ipairs(CollectionService:GetTagged(tag)) do
			if inst:IsA("BasePart") and inst:IsDescendantOf(Workspace) then
				aimParts[inst] = true
			end
		end
	end

	task.spawn(function()
		local all = Workspace:GetDescendants()
		for i, inst in ipairs(all) do
			pcall(classify, inst)
			if i % 1500 == 0 then
				task.wait()
			end
		end
		scanDone = true
	end)
end

local function modelFromPart(part, cache)
	local cur = part.Parent
	local chain = {}
	local found = false
	local depth = 0
	while cur and cur ~= Workspace and depth < 8 do
		local c = cache[cur]
		if c ~= nil then
			found = c
			break
		end
		chain[#chain + 1] = cur
		if isActorModel(cur) then
			found = cur
			break
		end
		cur = cur.Parent
		depth += 1
	end
	for _, inst in ipairs(chain) do
		cache[inst] = found
	end
	return found or nil
end

--==============================================================
-- РЎРљРћР РћРЎРўР¬ РџРћ Р”Р’РР–Р•РќРР® (РґР»СЏ С‚РІРёРЅРѕРІ Рё CFrame-С…РёС‚Р±РѕРєСЃРѕРІ)
--==============================================================

local function measuredVel(part, now)
	local v = part.AssemblyLinearVelocity
	local pos = part.Position
	local rec = motion[part]
	if rec and v.Magnitude < 1 then
		local dt = now - rec.t
		if dt > 0.001 and dt < 0.25 then
			local m = (pos - rec.p) / dt
			if m.Magnitude < 400 then
				v = m
			end
		end
	end
	motion[part] = { p = pos, t = now }
	return v
end

--==============================================================
-- РџРРќР“
--==============================================================

local function updatePing(now)
	if now - lastPing < 1 then
		return
	end
	lastPing = now
	local ok, p = pcall(function()
		return LocalPlayer:GetNetworkPing()
	end)
	if ok and type(p) == "number" then
		pingValue = math.clamp(p, 0, 0.4)
	end
end

--==============================================================
-- РђРќРРњРђР¦РР Р’Р РђР“Рђ
--==============================================================

local function getAnimator(hum)
	local a = hum:FindFirstChildOfClass("Animator")
	if a then
		return a
	end
	return nil
end

local function trackId(track)
	local anim = track.Animation
	if anim then
		return anim.AnimationId
	end
	return ""
end

local function trackIgnored(track)
	if containsWord(track.Name, CFG.IGNORE_ANIMATION_WORDS) then
		return true
	end
	local anim = track.Animation
	return anim ~= nil and containsWord(anim.Name, CFG.IGNORE_ANIMATION_WORDS)
end

-- Р’С‹СѓС‡РµРЅРЅР°СЏ Р°РЅРёРјР°С†РёСЏ СЃС‡РёС‚Р°РµС‚СЃСЏ В«РёР·РІРµСЃС‚РЅРѕР№В» С‚РѕР»СЊРєРѕ РїРѕСЃР»Рµ LEARN_MIN_HITS СѓРґР°СЂРѕРІ
local function learnedRec(id)
	local L = learned[id]
	if L and L.n >= CFG.LEARN_MIN_HITS then
		return L
	end
	return nil
end

-- РЎРѕС…СЂР°РЅС‘РЅРЅС‹Рµ РјРѕРјРµРЅС‚С‹ СѓРґР°СЂР° (СЃРµРєСѓРЅРґС‹ РѕС‚ РЅР°С‡Р°Р»Р° Р°РЅРёРјР°С†РёРё): РёР· KeyframeSequence, СЃРёРґР° РёР»Рё РЅР°Р±Р»СЋРґРµРЅРёСЏ
local function hitTimesFor(id)
	local k = kfInfo[id]
	if k then
		return k.hits, k.src
	end
	local l = kfLive[id]
	if l then
		return l.hits, "live"
	end
	return nil
end

-- Р”РѕСЃС‚Р°С‘Рј С‚Р°Р№РјРёРЅРіРё СѓРґР°СЂР° РёР· СЃР°РјРѕР№ Р°РЅРёРјР°С†РёРё: РєР»СЋС‡РµРІС‹Рµ РєР°РґСЂС‹/РјР°СЂРєРµСЂС‹ Hit, Damage, Strike...
-- Р Р°Р±РѕС‚Р°РµС‚ РґР»СЏ Р°РЅРёРјР°С†РёР№, РєРѕС‚РѕСЂС‹РјРё РІР»Р°РґРµРµС‚ С‚РІРѕСЏ РёРіСЂР°/РіСЂСѓРїРїР°; РµСЃР»Рё РЅРµ РІС‹С€Р»Рѕ, РјРѕР»С‡Р° РёРґС‘Рј РґР°Р»СЊС€Рµ.
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local function loadKeyframeData(id)
	if not CFG.USE_KEYFRAME_DATA or id == "" or kfInfo[id] ~= nil or kfPending[id] then
		return
	end
	kfPending[id] = true
	task.spawn(function()
		local ok, seq = pcall(function()
			return KeyframeSequenceProvider:GetKeyframeSequenceAsync(id)
		end)
		local hits = {}
		if ok and typeof(seq) == "Instance" then
			for _, kf in ipairs(seq:GetChildren()) do
				if kf:IsA("Keyframe") then
					local isHit = containsWord(kf.Name, CFG.HIT_MARKER_WORDS)
					if not isHit then
						local okm, markers = pcall(function()
							return kf:GetMarkers()
						end)
						if okm and markers then
							for _, m in ipairs(markers) do
								if containsWord(m.Name, CFG.HIT_MARKER_WORDS) then
									isHit = true
									break
								end
							end
						end
					end
					if isHit then
						hits[#hits + 1] = kf.Time
					end
				end
			end
			pcall(function()
				seq:Destroy()
			end)
		end
		table.sort(hits)
		kfInfo[id] = #hits > 0 and { hits = hits, src = "keyframe" } or false
		kfPending[id] = nil
	end)
end

-- Р—Р°РїРѕРјРёРЅР°РµРј РјРѕРјРµРЅС‚ СѓРґР°СЂР°, РєРѕРіРґР° Сѓ С‡СѓР¶РѕР№ Р°РЅРёРјР°С†РёРё СЃСЂР°Р±РѕС‚Р°Р» РјР°СЂРєРµСЂ/РєР°РґСЂ Hit, Damage...
local function recordLiveHit(id, t)
	local rec = kfLive[id]
	if not rec then
		rec = { hits = {}, src = "live" }
		kfLive[id] = rec
	end
	for _, h in ipairs(rec.hits) do
		if math.abs(h - t) < 0.06 then
			return
		end
	end
	if #rec.hits < 8 then
		rec.hits[#rec.hits + 1] = t
		table.sort(rec.hits)
	end
end

local function hookTrackMarkers(tr, id)
	if not CFG.LEARN_FROM_MARKERS or hookedTracks[tr] then
		return
	end
	hookedTracks[tr] = true
	pcall(function()
		tr.KeyframeReached:Connect(function(name)
			if containsWord(name, CFG.HIT_MARKER_WORDS) then
				recordLiveHit(id, tr.TimePosition)
			end
		end)
		for _, nm in ipairs(CFG.HIT_MARKER_NAMES) do
			tr:GetMarkerReachedSignal(nm):Connect(function()
				recordLiveHit(id, tr.TimePosition)
			end)
		end
	end)
end

-- M1, M2... РєР°Рє РѕС‚РґРµР»СЊРЅРѕРµ СЃР»РѕРІРѕ (РЅРµ РІРЅСѓС‚СЂРё Anim1/Item1)
local function isComboName(name)
	return type(name) == "string" and string.find(string.lower(name), "%f[%w]m%d%f[%W]") ~= nil
end

-- "known" = С‚РѕС‡РЅРѕ Р°С‚Р°РєР°, "generic" = Р»СЋР±Р°СЏ Action-Р°РЅРёРјР°С†РёСЏ, nil = РЅРµ Р°С‚Р°РєР°
local function isAimName(name)
	return type(name) == "string" and string.find(string.lower(name), "%f[%a]aim") ~= nil
end

local function classifyTrack(track)
	if not track.IsPlaying or track.WeightCurrent < 0.1 then
		return nil
	end
	local id = trackId(track)
	if id ~= "" and (CFG.ATTACK_ANIMATION_IDS[id] or table.find(CFG.ATTACK_ANIMATION_IDS, id) or learnedRec(id) or hitTimesFor(id)) then
		return "known"
	end
	if containsWord(track.Name, CFG.ATTACK_ANIMATION_WORDS) or isComboName(track.Name) then
		return "known"
	end
	local anim = track.Animation
	if anim and (containsWord(anim.Name, CFG.ATTACK_ANIMATION_WORDS) or isComboName(anim.Name)) then
		return "known"
	end
	if isAimName(track.Name) or (anim and isAimName(anim.Name)) then
		return "aim"
	end
	if trackIgnored(track) then
		return nil
	end
	if CFG.USE_ACTION_ANIMATIONS and not track.Looped and ACTION_PRIORITIES[track.Priority] then
		return "generic"
	end
	return nil
end

-- РћРєРЅРѕ РѕРїР°СЃРЅРѕСЃС‚Рё С‚СЂРµРєР° РІ СЃРµРєСѓРЅРґР°С… РѕС‚ СЃРµР№С‡Р°СЃ: from, to
local function trackWindow(track)
	local len = track.Length
	local pos = track.TimePosition
	local spd = track.Speed
	if spd == nil or math.abs(spd) < 0.05 then
		spd = 1
	end
	if len <= 0 then
		return 0, 0.5
	end
	local endT = len * CFG.ATTACK_END_FRACTION
	local id = trackId(track)
	local L = learnedRec(id)
	if L then
		local tth = (L.hitAt - pos) / spd
		local from, to = tth - CFG.LEARN_EARLY, tth + CFG.LEARN_LATE
		if to < 0 then
			return nil
		end
		return math.max(from, 0), to
	end
	local hits, hitSrc = hitTimesFor(id)
	if hits then
		-- Р±Р»РёР¶Р°Р№С€РёР№ РµС‰С‘ РЅРµ РїСЂРѕС€РµРґС€РёР№ СѓРґР°СЂ РёР· Р°РЅРёРјР°С†РёРё
		for _, h in ipairs(hits) do
			local tth = (h - pos) / spd
			if tth + CFG.LEARN_LATE >= 0 then
				return math.max(tth - CFG.LEARN_EARLY, 0), tth + CFG.LEARN_LATE
			end
		end
		if hitSrc ~= "live" then
			return nil
		end
	end
	if pos > endT then
		return nil
	end
	return 0, math.max((endT - pos) / spd, 0.15)
end

-- Р’РѕР·РІСЂР°С‰Р°РµС‚ СЃРїРёСЃРѕРє { kind, from, to } РїРѕ РёРіСЂР°СЋС‰РёРј С‚СЂРµРєР°Рј. РљСЌС€ РїРѕ РґРёСЃС‚Р°РЅС†РёРё.
local function attackWindows(hum, dist, now)
	local rec = animCache[hum]
	local interval = dist < 20 and 0 or (dist < 50 and 0.06 or 0.15)
	if not rec or now - rec.t >= interval then
		local list = {}
		local animator = getAnimator(hum)
		if animator then
			local ok, tracks = pcall(function()
				return animator:GetPlayingAnimationTracks()
			end)
			if ok and tracks then
				for _, tr in ipairs(tracks) do
					local kind = classifyTrack(tr)
					if kind then
						list[#list + 1] = { track = tr, kind = kind }
						if kind ~= "aim" then
							local tid = trackId(tr)
							if tid ~= "" then
								loadKeyframeData(tid)
								hookTrackMarkers(tr, tid)
							end
						end
					end
				end
			end
		end
		rec = { t = now, list = list }
		animCache[hum] = rec
	end

	local out = {}
	for _, item in ipairs(rec.list) do
		local tr = item.track
		if tr.IsPlaying then
			if item.kind == "aim" then
				out[#out + 1] = { kind = "aim", from = 0, to = FAR }
			else
				local from, to = trackWindow(tr)
				if from then
					out[#out + 1] = { kind = item.kind, from = from, to = to }
				end
			end
		end
	end
	return out
end

--==============================================================
-- Р—РђРњРђРҐ РћР РЈР–РРЇ / Р РЈРљ
--==============================================================

local LIMB_NAMES = { "RightHand", "LeftHand", "Right Arm", "Left Arm" }

local function detectSwing(model, root, myPos, now)
	local rec = swingCache[model]
	if not rec then
		rec = { parts = {}, untilT = 0 }
		swingCache[model] = rec
	end
	if now < rec.untilT then
		return true
	end

	local candidates = {}
	local tool = model:FindFirstChildOfClass("Tool")
	if tool then
		local h = tool:FindFirstChild("Handle")
		if h and h:IsA("BasePart") then
			candidates[#candidates + 1] = { h, CFG.SWING_TOOL_SPEED }
		end
		-- С‚РѕС‡РєРё РєР»РёРЅРєР° РёР· RaycastHitbox / ClientCast (Attachment "DmgPoint")
		for _, nm in ipairs(CFG.HIT_ATTACHMENT_NAMES) do
			local a = tool:FindFirstChild(nm, true)
			if a and a:IsA("Attachment") then
				candidates[#candidates + 1] = { a, CFG.SWING_TOOL_SPEED }
				break
			end
		end
	end
	for _, n in ipairs(LIMB_NAMES) do
		local l = model:FindFirstChild(n)
		if l and l:IsA("BasePart") then
			candidates[#candidates + 1] = { l, CFG.SWING_LIMB_SPEED }
		end
	end

	local found = false
	for _, c in ipairs(candidates) do
		local part, thr = c[1], c[2]
		local prev = rec.parts[part]
		local pos = part:IsA("Attachment") and part.WorldPosition or part.Position
		local rpos = root.Position
		if prev then
			local dt = now - prev.t
			if dt > 0.01 and dt < 0.3 then
				local disp = (pos - prev.p) - (rpos - prev.r)
				local v = disp / dt
				local s = v.Magnitude
				if s > thr and s < 300 and unit(v):Dot(unit(myPos - pos)) > 0.2 then
					found = true
				end
			end
		end
		rec.parts[part] = { p = pos, r = rpos, t = now }
	end

	if found then
		rec.untilT = now + 0.25
	end
	return found
end

--==============================================================
-- РћР‘РЈР§Р•РќРР• РџРћ РЈР РћРќРЈ
--==============================================================

local function learnFromHit(myPos)
	if not CFG.AUTO_LEARN then
		return
	end

	-- РєР°РЅРґРёРґР°С‚С‹: Р±Р»РёР¶Р°Р№С€РёРµ РІСЂР°РіРё, РїРѕРІС‘СЂРЅСѓС‚С‹Рµ Рє С‚РµР±Рµ (Р° РЅРµ РІСЃСЏ С‚РѕР»РїР° РІРѕРєСЂСѓРі)
	local cands = {}
	for hum in pairs(humanoids) do
		if hum ~= Humanoid and hum.Parent and not actorDead(hum) and not isIgnoredModel(hum.Parent) then
			local root = getRoot(hum.Parent)
			if root then
				local offset = myPos - root.Position
				local d = offset.Magnitude
				if d <= CFG.LEARN_RADIUS then
					local facing = unit(flat(root.CFrame.LookVector)):Dot(unit(flat(offset)))
					if facing > 0.2 or d < 6 then
						cands[#cands + 1] = { hum = hum, d = d }
					end
				end
			end
		end
	end
	table.sort(cands, function(a, b)
		return a.d < b.d
	end)

	for i = 1, math.min(#cands, CFG.LEARN_MAX_ATTACKERS) do
		local hum = cands[i].hum
		local animator = getAnimator(hum)
		if animator then
			local ok, tracks = pcall(function()
				return animator:GetPlayingAnimationTracks()
			end)
			if ok and tracks then
				for _, tr in ipairs(tracks) do
					local id = trackId(tr)
					if id ~= "" and tr.IsPlaying and tr.WeightCurrent >= 0.1
						and not tr.Looped and not trackIgnored(tr)
						and (ACTION_PRIORITIES[tr.Priority] or containsWord(tr.Name, CFG.ATTACK_ANIMATION_WORDS))
					then
						local hitAt = math.max(tr.TimePosition - pingValue, 0.05)
						local rec = learned[id]
						if rec then
							rec.hitAt = (rec.hitAt * rec.n + hitAt) / (rec.n + 1)
							rec.n += 1
						else
							learned[id] = { n = 1, hitAt = hitAt }
						end
						animCache[hum] = nil
					end
				end
			end
		end
	end

	local count = 0
	for _ in pairs(learned) do
		count += 1
	end
	pcall(function()
		LocalPlayer:SetAttribute("AutoDodgeLearned", count)
	end)
end

--==============================================================
-- РЎР‘РћР  РЈР“Р РћР—
--==============================================================
-- Р¤РѕСЂРјР° СѓРіСЂРѕР·С‹:
--  СЌР»Р»РёРїСЃРѕРёРґ: kind="ell", cf, rf (РІРїРµСЂС‘Рґ), rb (РЅР°Р·Р°Рґ), rs (Р±РѕРє), ry (РІРІРµСЂС…)
--  РєРѕСЂРѕР±РєР°:   kind="box", cf, half
--  РѕР±С‰РµРµ: vel, from/to (РѕРєРЅРѕ РІСЂРµРјРµРЅРё, СЃРµРє), margin, dist

local function isTeammate(model)
	if not CFG.IGNORE_TEAMMATES or not LocalPlayer.Team then
		return false
	end
	local plr = Players:GetPlayerFromCharacter(model)
	return plr ~= nil and plr.Team == LocalPlayer.Team
end

function isIgnoredModel(model)
	if table.find(CFG.IGNORE_NAMES, model.Name) then
		return true
	end
	for _, tag in ipairs(CFG.IGNORE_TAGS) do
		if CollectionService:HasTag(model, tag) then
			return true
		end
	end
	return isTeammate(model)
end

-- РћСЂСѓР¶РёРµ РґР°Р»СЊРЅРµРіРѕ Р±РѕСЏ: РїРѕ РёРјРµРЅРё, Р°С‚СЂРёР±СѓС‚Р°Рј РёР»Рё РґРµС‚Р°Р»СЏРј (РґСѓР»Рѕ, РїР°С‚СЂРѕРЅС‹)
local function isRangedTool(tool, now)
	local rec = rangedCache[tool]
	if rec and (rec.v or now - rec.t < 2) then
		return rec.v
	end
	local r = containsWord(tool.Name, CFG.GUN_TOOL_WORDS)
	if not r then
		for _, a in ipairs(CFG.GUN_ATTRIBUTES) do
			if tool:GetAttribute(a) ~= nil then
				r = true
				break
			end
		end
	end
	if not r then
		for _, d in ipairs(tool:GetDescendants()) do
			if containsWord(d.Name, CFG.GUN_PART_WORDS) then
				r = true
				break
			end
		end
	end
	rangedCache[tool] = { v = r, t = now }
	return r
end

-- РЎР»РµРґРёРј Р·Р° РїСЂРёР·РЅР°РєР°РјРё РІС‹СЃС‚СЂРµР»Р°: Р·РІСѓРє, РІСЃРїС‹С€РєР°, С‡Р°СЃС‚РёС†С‹, РёР·РјРµРЅРµРЅРёРµ РїР°С‚СЂРѕРЅРѕРІ
local function watchTool(tool, model, now)
	if watched[tool] then
		return
	end
	local conns = {}
	watched[tool] = conns
	local t0 = now

	local function shot()
		local n = os.clock()
		if n - t0 > 0.4 then
			shotAt[model] = n
		end
	end
	local function hook(inst)
		if inst:IsA("Sound") then
			table.insert(conns, inst.Played:Connect(shot))
		elseif inst:IsA("Light") or inst:IsA("ParticleEmitter") then
			table.insert(conns, inst:GetPropertyChangedSignal("Enabled"):Connect(shot))
		end
	end

	for _, d in ipairs(tool:GetDescendants()) do
		hook(d)
	end
	table.insert(conns, tool.DescendantAdded:Connect(function(d)
		hook(d)
		if d:IsA("Sound") or d:IsA("ParticleEmitter") or d:IsA("Beam") or d:IsA("Trail")
			or d:IsA("Light") or d:IsA("BasePart")
		then
			shot()
		end
	end))
	table.insert(conns, tool.AttributeChanged:Connect(function(name)
		if table.find(CFG.GUN_ATTRIBUTES, name) then
			shot()
		end
	end))
	table.insert(conns, tool.AncestryChanged:Connect(function()
		if not tool:IsDescendantOf(Workspace) then
			for _, c in ipairs(conns) do
				c:Disconnect()
			end
			watched[tool] = nil
		end
	end))
end

-- Р›РёРЅРёСЏ РѕРіРЅСЏ: РґР»РёРЅРЅР°СЏ РєРѕСЂРѕР±РєР° РѕС‚ СЃС‚СЂРµР»РєР° С‡РµСЂРµР· С‚РµР±СЏ
local function addLane(list, pos, lookU, dist, from, to, urgent, baseWidth)
	local length = math.min(dist + 25, CFG.LINE_MAX_DIST)
	local width = (baseWidth or 2.5) + 0.05 * dist
	local center = pos + lookU * (length * 0.5)
	list[#list + 1] = {
		kind = "box", cf = CFrame.lookAt(center, center + lookU),
		half = Vector3.new(width, 4, length * 0.5),
		vel = Vector3.zero, from = from, to = to, dist = dist, urgent = urgent,
	}
end

-- Р Р°Р·РјРµСЂ РІСЂР°РіР° РѕС‚РЅРѕСЃРёС‚РµР»СЊРЅРѕ РѕР±С‹С‡РЅРѕРіРѕ РїРµСЂСЃРѕРЅР°Р¶Р° (РєСЌС€ 1 СЃ): Р±РѕСЃСЃС‹ Р±СЊСЋС‚ РґР°Р»СЊС€Рµ, РјРµР»РѕС‡СЊ Р±Р»РёР¶Рµ
local scaleCache = setmetatable({}, { __mode = "k" })
local function actorScale(model, now)
	local rec = scaleCache[model]
	if rec and now - rec.t < 1 then
		return rec.v
	end
	local v = 1
	local ok, size = pcall(function()
		return model:GetExtentsSize()
	end)
	if ok and size then
		v = math.clamp(size.Y / 5.4, 0.7, 3.5)
		if v > 0.9 and v < 1.15 then
			v = 1
		end
	end
	scaleCache[model] = { v = v, t = now }
	return v
end

local function addHumanoidThreat(list, hum, myPos, now)
	local model = hum.Parent
	if not model or model == Character or actorDead(hum) then
		return
	end
	local root = getRoot(model)
	if not root then
		return
	end

	local offset = myPos - root.Position
	local dist = offset.Magnitude
	local maxRange = (CFG.DODGE_LINE_OF_FIRE or CFG.DODGE_AIMED_GUNS) and CFG.LINE_MAX_DIST or CFG.ATTACK_CHECK_RANGE
	if dist > maxRange then
		return
	end
	if isIgnoredModel(model) then
		return
	end
	-- СЃРІРѕРё СЃР°РјРјРѕРЅС‹/РїРёС‚РѕРјС†С‹/РєР»РѕРЅС‹ (Owner/Creator... = С‚С‹) РЅРµ СѓРіСЂРѕР·Р°
	if isMine(root, now) then
		return
	end

	local dirToMe = unit(flat(offset))
	local vel = flat(measuredVel(root, now))
	local closing = vel:Dot(dirToMe)
	local near = dist <= CFG.ATTACK_CHECK_RANGE
	local scale = CFG.SCALE_REACH and actorScale(model, now) or 1

	local look = flat(root.CFrame.LookVector)
	local lookU = unit(look)
	local facing = lookU:Dot(dirToMe)

	local from, to = FAR, -FAR
	local function extend(a, b)
		if a < from then from = a end
		if b > to then to = b end
	end

	local tool = model:FindFirstChildOfClass("Tool")
	local gunner = false
	if tool and isRangedTool(tool, now) then
		gunner = true
		watchTool(tool, model, now)
	end
	local shotT = shotAt[model]
	local recentShot = shotT ~= nil and now - shotT <= CFG.SHOT_WINDOW

	local lunging = near and closing >= CFG.LUNGE_SPEED
	local ranged = false
	local meleeSignal = false
	local aimTrack = false

	if lunging then
		extend(0, 0.6)
		meleeSignal = true
	end
	if near and (attrActive(model) or attrActive(root) or attrActive(hum)) then
		extend(0, 0.6)
		meleeSignal = true
		ranged = true
	end
	if near and CFG.DETECT_SWINGS and detectSwing(model, root, myPos, now) then
		extend(0, 0.4)
		meleeSignal = true
	end

	for _, w in ipairs(attackWindows(hum, dist, now)) do
		if w.kind == "aim" then
			aimTrack = true
		elseif w.kind == "known" then
			extend(w.from, w.to)
			meleeSignal = true
			ranged = true
		elseif near and facing > 0.3 and dist < CFG.MELEE_REACH * scale * 2.2 then
			extend(w.from, w.to)
			meleeSignal = true
			ranged = true
		end
	end

	if recentShot then
		extend(0, CFG.SHOT_WINDOW)
		ranged = true
	end

	if to >= from and near and meleeSignal then
		local reach = CFG.MELEE_REACH * scale * (lunging and 1.25 or 1)
		local pos = root.Position
		local cf = CFrame.lookAt(pos, pos + (lookU.Magnitude > 0.1 and lookU or Vector3.new(0, 0, -1)))
		list[#list + 1] = {
			kind = "ell", cf = cf,
			rf = reach, rb = reach * CFG.REACH_BACK, rs = reach * CFG.REACH_SIDE,
			ry = math.max(reach * 0.6, 4),
			vel = vel, from = from, to = to, dist = dist,
		}
	end

	local laneMade = false
	if to >= from and CFG.DODGE_LINE_OF_FIRE and ranged then
		local minD = recentShot and CFG.GUN_MIN_DIST or CFG.LINE_MIN_DIST
		local minDot = recentShot and CFG.SHOT_ANGLE_DOT or CFG.LINE_ANGLE_DOT
		if dist >= minD and facing >= minDot then
			addLane(list, root.Position, lookU, dist, from, to, true, recentShot and CFG.GUN_LANE_WIDTH or nil)
			laneMade = true
		end
	end

	-- РЎС‚СЂРµР»РѕРє РїСЂРѕСЃС‚Рѕ С†РµР»РёС‚СЃСЏ: РґРµСЂР¶РёРјСЃСЏ РІРЅРµ Р»РёРЅРёРё (СЃСЂРѕС‡РЅС‹Рј СЌС‚Рѕ РЅРµ СЃС‡РёС‚Р°РµРј)
	if not laneMade and CFG.DODGE_AIMED_GUNS and (gunner or aimTrack)
		and dist >= CFG.GUN_MIN_DIST and facing >= CFG.GUN_ANGLE_DOT
	then
		addLane(list, root.Position, lookU, dist, 0, FAR, false, CFG.GUN_LANE_WIDTH)
	end
end

local function boxThreat(part, vel, dist, static)
	return {
		kind = "box", cf = part.CFrame, half = part.Size * 0.5,
		vel = vel, from = 0, to = FAR, dist = dist,
		margin = static and CFG.STATIC_MARGIN or nil,
		urgent = not static,
	}
end

local function inactiveHitbox(part)
	for _, a in ipairs(CFG.INACTIVE_ATTRIBUTES) do
		if part:GetAttribute(a) == false then
			return true
		end
	end
	return false
end

local function gather(now)
	local list = {}
	local myPos = Root.Position
	local R = CFG.DETECT_RADIUS

	-- СѓРіСЂРѕР·С‹, РїСЂРёСЃР»Р°РЅРЅС‹Рµ РёРіСЂРѕР№ С‡РµСЂРµР· shared.AutoDodge
	for i = #manualThreats, 1, -1 do
		local m = manualThreats[i]
		if now > m.endT then
			table.remove(manualThreats, i)
		else
			local c = m.cf.Position
			local d = (c - myPos).Magnitude
			if d - m.reach <= R then
				list[#list + 1] = {
					kind = m.kind, cf = m.cf, half = m.half,
					rf = m.rf, rb = m.rb, rs = m.rs, ry = m.ry,
					vel = m.vel, from = math.max(0, m.startT - now), to = m.endT - now,
					dist = d, urgent = m.urgent,
				}
			end
		end
	end

	-- РєР°Р¶РґС‹Р№ РІСЂР°Рі РІ СЃРІРѕС‘Рј pcall: РѕРґРёРЅ РєСЂРёРІРѕР№ РјРѕР± РЅРµ Р»РѕРјР°РµС‚ РІРµСЃСЊ СѓРІРѕСЂРѕС‚
	for hum in pairs(humanoids) do
		if hum.Parent then
			local ok, err = pcall(addHumanoidThreat, list, hum, myPos, now)
			if not ok then
				local msg = tostring(err)
				if msg ~= lastError then
					lastError = msg
					warn("[AutoDodge] РѕС€РёР±РєР° РІСЂР°РіР°:", msg)
				end
			end
		else
			humanoids[hum] = nil
		end
	end

	for part in pairs(flaggedParts) do
		if not part.Parent then
			flaggedParts[part] = nil
		else
			local size = part.Size
			local big = math.max(size.X, size.Y, size.Z)
			if big <= CFG.MAX_PART_SIZE or not part.CanCollide then
				local d = (part.Position - myPos).Magnitude
				if d - big * 0.5 <= R and not inactiveHitbox(part) and not isMine(part, now) then
					local vel = measuredVel(part, now)
					local static = vel.Magnitude < 1
					if not static or CFG.STATIC_ZONES then
						list[#list + 1] = boxThreat(part, vel, d, static)
					end
				end
			end
		end
	end

	for part in pairs(aimParts) do
		if not part.Parent then
			aimParts[part] = nil
		elseif CFG.DODGE_AIMED_GUNS then
			local off = myPos - part.Position
			local d = off.Magnitude
			if d >= 2 and d <= CFG.LINE_MAX_DIST then
				local look = unit(flat(part.CFrame.LookVector))
				if look.Magnitude > 0.1 and look:Dot(unit(flat(off))) >= CFG.GUN_ANGLE_DOT then
					addLane(list, part.Position, look, d, 0, FAR, false, CFG.GUN_LANE_WIDTH)
				end
			end
		end
	end

	-- РЎРІРѕР±РѕРґРЅС‹Рµ РґРµС‚Р°Р»Рё: С‚СЏР¶С‘Р»С‹Р№ РѕС‚Р±РѕСЂ СЂР°Р· РІ 0.12 СЃ, РґР°Р»СЊС€Рµ РїСЂРѕРІРµСЂСЏРµРј С‚РѕР»СЊРєРѕ Р±С‹СЃС‚СЂС‹С… СЂСЏРґРѕРј
	if now - dynNearT >= 0.12 then
		dynNearT = now
		dynNear = {}
		for part in pairs(dynamicParts) do
			if not part.Parent then
				dynamicParts[part] = nil
			elseif not part.Anchored and part.CanTouch then
				local d = (part.Position - myPos).Magnitude
				local size = part.Size
				if d <= R + 15 and math.max(size.X, size.Y, size.Z) <= CFG.MAX_PROJECTILE_SIZE
					and part.AssemblyLinearVelocity.Magnitude >= CFG.MIN_PROJECTILE_SPEED
				then
					dynNear[#dynNear + 1] = part
				end
			end
		end
	end

	local modelCache = {}
	for _, part in ipairs(dynNear) do
		if part.Parent and not part.Anchored then
			local d = (part.Position - myPos).Magnitude
			local vel = part.AssemblyLinearVelocity
			local speed = vel.Magnitude
			if d <= R and speed >= CFG.MIN_PROJECTILE_SPEED and vel:Dot(unit(myPos - part.Position)) >= 4 then
				local touchy = part:FindFirstChildOfClass("TouchTransmitter") ~= nil
				if (touchy or speed >= CFG.FAST_PROJECTILE_SPEED)
					and not modelFromPart(part, modelCache)
					and not isMine(part, now)
				then
					list[#list + 1] = boxThreat(part, vel, d, false)
				end
			end
		end
	end

	-- Р”РµС‚Р°Р»Рё, РєРѕС‚РѕСЂС‹Рµ РёРіСЂР° РґРІРёРіР°РµС‚ РїРѕ CFrame (FastCast Рё С‚.Рї.): СЃРєРѕСЂРѕСЃС‚СЊ Р±РµСЂС‘Рј РїРѕ СЃРјРµС‰РµРЅРёСЋ
	if CFG.CFRAME_PROJECTILES then
		for part, t0 in pairs(youngParts) do
			if not part.Parent or now - t0 > CFG.YOUNG_LIFETIME then
				youngParts[part] = nil
			elseif part.Anchored then
				local d = (part.Position - myPos).Magnitude
				if d <= R then
					local vel = measuredVel(part, now)
					if vel.Magnitude >= CFG.FAST_PROJECTILE_SPEED
						and vel:Dot(unit(myPos - part.Position)) >= 4
						and not isMine(part, now)
					then
						list[#list + 1] = boxThreat(part, vel, d, false)
					end
				end
			end
		end
	end

	table.sort(list, function(a, b)
		return a.dist < b.dist
	end)
	while #list > CFG.MAX_THREATS do
		table.remove(list)
	end
	return list
end

--==============================================================
-- РЈРџР РђР’Р›Р•РќРР• РР“Р РћРљРђ
--==============================================================

task.spawn(function()
	local ok, module = pcall(function()
		return require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
	end)
	if ok and module then
		local ok2, c = pcall(function()
			return module:GetControls()
		end)
		if ok2 then
			controls = c
		end
	end
end)

-- РџРѕСЂСЏРґРѕРє: СЃС‚Р°РЅРґР°СЂС‚РЅС‹Рµ РєРѕРЅС‚СЂРѕР»С‹ -> Р°С‚СЂРёР±СѓС‚ DodgeManualInput (РґР»СЏ СЃРІРѕРµРіРѕ
-- РґР¶РѕР№СЃС‚РёРєР°) -> РїРѕСЃР»РµРґРЅРµРµ РЅР°РїСЂР°РІР»РµРЅРёРµ РґРІРёР¶РµРЅРёСЏ РґРѕ РЅР°С‡Р°Р»Р° СѓРІРѕСЂРѕС‚Р°.
local function getManualDirection(now)
	if controls then
		local ok, mv = pcall(function()
			return controls:GetMoveVector()
		end)
		local cam = Workspace.CurrentCamera
		if ok and mv and mv.Magnitude > 0.1 and cam then
			local look = unit(flat(cam.CFrame.LookVector))
			local right = unit(flat(cam.CFrame.RightVector))
			local d = unit(right * mv.X + look * (-mv.Z))
			if d.Magnitude > 0.1 then
				return d
			end
		end
	end
	local a = LocalPlayer:GetAttribute("DodgeManualInput")
	if typeof(a) == "Vector3" and a.Magnitude > 0.1 then
		return unit(flat(a))
	end
	if now - lastManualTime < 0.5 then
		return lastManual
	end
	return Vector3.zero
end

--==============================================================
-- РЎРРњРЈР›РЇР¦РРЇ
--==============================================================

local function marginOf(th)
	return th.margin or CFG.MARGIN
end

-- Р—Р°РїР°СЃ (РІ СЃС‚СѓРґР°С…) РјРµР¶РґСѓ С‚РѕС‡РєРѕР№ Рё СѓРіСЂРѕР·РѕР№ С‡РµСЂРµР· t СЃРµРєСѓРЅРґ
local function clearanceAt(th, point, t)
	if t < th.from or t > th.to then
		return FAR
	end
	local tt = math.min(t, CFG.VEL_TIME_CAP)
	local lp = th.cf:PointToObjectSpace(point - th.vel * tt)

	if th.kind == "ell" then
		local zr = lp.Z < 0 and th.rf or th.rb
		local nx, ny, nz = lp.X / th.rs, lp.Y / th.ry, lp.Z / zr
		local d = math.sqrt(nx * nx + ny * ny + nz * nz)
		return (d - 1) * ((th.rs + zr) * 0.5)
	end

	local h = th.half
	local dx = math.max(math.abs(lp.X) - h.X, 0)
	local dy = math.max(math.abs(lp.Y) - h.Y, 0)
	local dz = math.max(math.abs(lp.Z) - h.Z, 0)
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function totalLag()
	return CFG.REACTION_LAG + (CFG.PING_COMP and pingValue or 0)
end

-- РџСЂРѕР№РґРµРЅРЅС‹Р№ РїСѓС‚СЊ С‡РµСЂРµР· t СЃРµРєСѓРЅРґ (dash = { speed, time } РґР°С‘С‚ СЂС‹РІРѕРє РІ РЅР°С‡Р°Р»Рµ)
local function travelAt(t, speed, lag, dash)
	local tm = math.max(t - lag, 0)
	if dash then
		local td = math.min(tm, dash.time)
		return td * dash.speed + (tm - td) * speed
	end
	return tm * speed
end

-- lift = { v0, g } РґР»СЏ РїСЂС‹Р¶РєР°
local function pathClearance(dir, myPos, speed, maxTravel, ths, lift, dash)
	local worst, endClear, pen = CAP, CAP, 0
	local lag = totalLag()
	local t = 0
	while t <= CFG.HORIZON do
		local travel = math.min(travelAt(t, speed, lag, dash), maxTravel)
		local point = myPos + dir * travel
		if lift then
			local tj = math.max(t - 0.03, 0)
			point += Vector3.new(0, math.max(lift.v0 * tj - 0.5 * lift.g * tj * tj, 0), 0)
		end
		for _, th in ipairs(ths) do
			local c = clearanceAt(th, point, t) - marginOf(th)
			if c < worst then
				worst = c
			end
			if c < 0 then
				pen += -c * CFG.STEP -- СЃРєРѕР»СЊРєРѕ РІСЂРµРјРµРЅРё Рё РЅР°СЃРєРѕР»СЊРєРѕ РіР»СѓР±РѕРєРѕ РІРЅСѓС‚СЂРё СѓРіСЂРѕР·С‹
			end
			if t + CFG.STEP > CFG.HORIZON and c < endClear then
				endClear = c
			end
		end
		t += CFG.STEP
	end
	return worst, endClear, pen
end

local function dodgeSpeed()
	if CFG.ENABLE_SPEED_BOOST then
		return baseSpeed * (panic and CFG.PANIC_SPEED_MULT or CFG.SPEED_MULT)
	end
	return Humanoid.WalkSpeed
end

-- Р’РѕР·РІСЂР°С‰Р°РµС‚ РёС‚РѕРіРѕРІСѓСЋ РѕС†РµРЅРєСѓ Рё С…СѓРґС€РёР№ Р·Р°РїР°СЃ (<0 = Р·Р°РґРµРЅРµС‚)
local function scoreDirection(dir, myPos, speed, ths, manual, lift, dash)
	local maxTravel = travelAt(CFG.HORIZON, speed, totalLag(), dash)
	local score = 0

	if dir.Magnitude > 0.1 then
		local hit = Workspace:Spherecast(myPos, 1.4, dir * CFG.WALL_RAY, rayParams)
		if hit then
			maxTravel = math.min(maxTravel, math.max(hit.Distance - 0.8, 0))
			if hit.Distance < 2.5 then
				score -= 6
			end
		end

		if CFG.LEDGE_CHECK then
			local reach = math.min(maxTravel, dash and 12 or 7)
			for _, f in ipairs({ 0.5, 1 }) do
				local probe = myPos + dir * (reach * f)
				local ground = Workspace:Raycast(probe, Vector3.new(0, -CFG.LEDGE_DEPTH, 0), rayParams)
				if not ground then
					score -= 8
				else
					if ground.Distance > 12 then
						score -= 3 + (ground.Distance - 12) * 0.5
					end
					-- Р»Р°РІР° / РєРёР»Р»-Р±СЂРёРє РїРѕРґ РЅРѕРіР°РјРё (РІ С‚РѕРј С‡РёСЃР»Рµ РѕРіСЂРѕРјРЅС‹Рµ, РєРѕС‚РѕСЂС‹С… РЅРµС‚ РІ СѓРіСЂРѕР·Р°С…)
					if CFG.DANGER_GROUND_PENALTY > 0 and flaggedParts[ground.Instance] then
						score -= CFG.DANGER_GROUND_PENALTY
					end
				end
			end
		end
	end

	local worst, endClear, pen = pathClearance(dir, myPos, speed, maxTravel, ths, lift, dash)
	score += worst + endClear * 0.15 - pen * 1.0

	if targetDir.Magnitude > 0.1 and dir.Magnitude > 0.1 then
		score += math.max(dir:Dot(targetDir), 0) * 1.2
	end
	if manual.Magnitude > 0.1 and dir.Magnitude > 0.1 then
		score += dir:Dot(manual) * CFG.MANUAL_BIAS
	end

	return score, worst
end

local function jumpParams()
	if not Humanoid or Humanoid.FloorMaterial == Enum.Material.Air then
		return nil
	end
	local v0
	if Humanoid.UseJumpPower then
		v0 = Humanoid.JumpPower
	else
		v0 = math.sqrt(2 * Workspace.Gravity * Humanoid.JumpHeight)
	end
	if v0 <= 1 then
		return nil
	end
	return { v0 = v0, g = Workspace.Gravity }
end

-- Р’РѕР·РІСЂР°С‰Р°РµС‚ dir, score, worst, wantJump
local function chooseDirection(myPos, speed, ths, manual, dash)
	local n = perfLow and CFG.LOW_DIRECTIONS or CFG.DIRECTIONS
	local bestDir, bestScore, bestWorst = Vector3.zero, -math.huge, -math.huge

	local function try(dir)
		local s, w = scoreDirection(dir, myPos, speed, ths, manual, nil, dash)
		if s > bestScore then
			bestDir, bestScore, bestWorst = dir, s, w
		end
	end

	local bestAngle = 0
	for i = 0, n - 1 do
		local a = (i / n) * math.pi * 2
		local before = bestScore
		try(Vector3.new(math.cos(a), 0, math.sin(a)))
		if bestScore > before then
			bestAngle = a
		end
	end
	if manual.Magnitude > 0.1 then
		try(manual)
	end
	-- СѓС‚РѕС‡РЅРµРЅРёРµ РІРѕРєСЂСѓРі Р»СѓС‡С€РµРіРѕ
	local half = math.pi / n
	for _, d in ipairs({ -half, half }) do
		try(Vector3.new(math.cos(bestAngle + d), 0, math.sin(bestAngle + d)))
	end

	local wantJump = false
	if CFG.JUMP_DODGE and not dash and bestWorst < 0.3 then
		-- РїСЂС‹Р¶РѕРє РїРѕРјРѕРіР°РµС‚ С‚РѕР»СЊРєРѕ РїСЂРѕС‚РёРІ РЅРёР·РєРёС… РІРѕР»РЅ РїРѕ Р·РµРјР»Рµ, РЅРµ РїСЂРѕС‚РёРІ СѓРґР°СЂРѕРІ РІ СЂРѕСЃС‚
		local low = {}
		for _, th in ipairs(ths) do
			if th.kind == "box" and th.half.Y <= 1.6 then
				low[#low + 1] = th
			end
		end
		local lift = #low > 0 and jumpParams() or nil
		if lift then
			local base = scoreDirection(bestDir, myPos, speed, low, manual)
			local js = scoreDirection(bestDir, myPos, speed, low, manual, lift)
			local zs = scoreDirection(Vector3.zero, myPos, speed, low, manual, lift)
			if js - 1 > base or zs - 1 > base then
				wantJump = true
			end
		end
	end

	return bestDir, bestScore, bestWorst, wantJump
end

--==============================================================
-- THINK
--==============================================================

-- РўРІРѕСЏ СЃРѕР±СЃС‚РІРµРЅРЅР°СЏ Р°РЅРёРјР°С†РёСЏ Р»РµС‡РµРЅРёСЏ/РёСЃРїРѕР»СЊР·РѕРІР°РЅРёСЏ (РєСЌС€ 0.1 СЃ)
local function ownBusyAnimation(now)
	if #CFG.BUSY_ANIMATION_WORDS == 0 and next(CFG.BUSY_ANIMATION_IDS) == nil then
		return false
	end
	if now - ownAnim.t < 0.1 then
		return ownAnim.v
	end
	ownAnim.t = now
	local v = false
	local animator = getAnimator(Humanoid)
	if animator then
		local ok, tracks = pcall(function()
			return animator:GetPlayingAnimationTracks()
		end)
		if ok and tracks then
			for _, tr in ipairs(tracks) do
				if tr.IsPlaying and tr.WeightCurrent >= 0.1 then
					local id = trackId(tr)
					local anim = tr.Animation
					if (id ~= "" and CFG.BUSY_ANIMATION_IDS[id])
						or containsWord(tr.Name, CFG.BUSY_ANIMATION_WORDS)
						or (anim ~= nil and containsWord(anim.Name, CFG.BUSY_ANIMATION_WORDS))
					then
						v = true
						break
					end
				end
			end
		end
	end
	ownAnim.v = v
	return v
end

-- В«Р—Р°РЅСЏС‚В»: С‚С‹ СЃРµР№С‡Р°СЃ Р»РµС‡РёС€СЊ, РєРѕР»РґСѓРµС€СЊ, Р¶РјС‘С€СЊ Р»РµС‡РёР»РєСѓ Рё С‚.Рї.
local function busy(now)
	if now < busyUntil or next(toolDown) ~= nil then
		return true
	end
	if LocalPlayer:GetAttribute("DodgeBusy") == true then
		return true
	end
	for _, name in ipairs(CFG.BUSY_ATTRIBUTES) do
		local v = Character:GetAttribute(name)
		if v == nil and Humanoid then
			v = Humanoid:GetAttribute(name)
		end
		if v == true or (type(v) == "number" and v > 0) then
			return true
		end
	end
	return ownBusyAnimation(now)
end

local function paused()
	holdPause = false
	if not isAlive() or not enabled then
		return true
	end
	local now = os.clock()
	if suspendHeld or now < hardPauseUntil or (not CFG.BUSY_ALLOW_PANIC and busy(now)) then
		holdPause = true
		return true
	end
	for _, name in ipairs(CFG.IMMUNE_ATTRIBUTES) do
		local v = Character:GetAttribute(name)
		if v == nil and Humanoid then
			v = Humanoid:GetAttribute(name)
		end
		if v == true or (type(v) == "number" and v > 0) then
			return true
		end
	end
	if Humanoid.Sit or Humanoid.PlatformStand or Humanoid.WalkSpeed <= 0 then
		return true
	end
	local st = Humanoid:GetState()
	if st == Enum.HumanoidStateType.Dead
		or st == Enum.HumanoidStateType.Ragdoll
		or st == Enum.HumanoidStateType.FallingDown
		or st == Enum.HumanoidStateType.Physics
		or st == Enum.HumanoidStateType.Seated
		or st == Enum.HumanoidStateType.Climbing
	then
		return true
	end
	for _, name in ipairs(CFG.PAUSE_ATTRIBUTES) do
		local v = Character:GetAttribute(name)
		if v == nil and Humanoid then
			v = Humanoid:GetAttribute(name)
		end
		if v == true or (type(v) == "number" and v > 0) then
			return true
		end
	end
	if CFG.SKIP_WITH_FORCEFIELD and Character:FindFirstChildOfClass("ForceField") then
		return true
	end
	return false
end

local function think(now)
	updatePing(now)

	if paused() then
		threats = {}
		active, panic, jumpPlanned = false, false, false
		targetDir = Vector3.zero
		dashUntil, dashWas = 0, false -- СЃС‚Р°РЅ/СЂСЌРіРґРѕР»Р»: СЂС‹РІРѕРє РЅРµ РїСЂРѕРґРѕР»Р¶Р°РµРј
		return
	end

	local myPos = Root.Position

	if not active then
		local md = flat(Humanoid.MoveDirection)
		if md.Magnitude > 0.1 then
			lastManual, lastManualTime = unit(md), now
		end
	end

	threats = gather(now)

	-- Р—Р°РґРµРЅРµС‚ Р»Рё, РµСЃР»Рё СЏ РїСЂРѕСЃС‚Рѕ СЃС‚РѕСЋ?
	local tHit, tUrgent = nil, nil
	for _, th in ipairs(threats) do
		local t = 0
		while t <= CFG.HORIZON do
			if clearanceAt(th, myPos, t) - marginOf(th) < 0 then
				if not tHit or t < tHit then
					tHit = t
				end
				-- "СЃСЂРѕС‡РЅС‹Рµ" СѓРіСЂРѕР·С‹ (Р°С‚Р°РєР°, РІС‹СЃС‚СЂРµР», СЃРЅР°СЂСЏРґ) РІРєР»СЋС‡Р°СЋС‚ РїР°РЅРёРєСѓ Рё РґСЌС€;
				-- РїСЂРѕСЃС‚Рѕ РїСЂРёС†РµР» РёР»Рё РЅРµРїРѕРґРІРёР¶РЅР°СЏ Р·РѕРЅР° СѓРІРѕСЂР°С‡РёРІР°СЋС‚СЃСЏ РѕР±С‹С‡РЅС‹Рј С€Р°РіРѕРј
				if th.urgent ~= false and (not tUrgent or t < tUrgent) then
					tUrgent = t
				end
				break
			end
			t += CFG.STEP
		end
	end
	lastStats = { threats = #threats, tHit = tHit }

	-- В«Р·Р°РЅСЏС‚В» + BUSY_ALLOW_PANIC: СѓС…РѕРґРёРј С‚РѕР»СЊРєРѕ РѕС‚ СѓРґР°СЂР° В«РїСЂСЏРјРѕ СЃРµР№С‡Р°СЃВ»
	if CFG.BUSY_ALLOW_PANIC and busy(now) then
		if tUrgent ~= nil and tUrgent <= CFG.PANIC_TIME then
			dodgeUntil = now + 0.15
		end
	elseif tHit and tHit <= CFG.TRIGGER_TIME then
		dodgeUntil = now + CFG.HOLD_TIME
	end

	panic = tUrgent ~= nil and tUrgent <= CFG.PANIC_TIME
	active = #threats > 0 and now < dodgeUntil

	if not active then
		targetDir = Vector3.zero
		panic = false
		return
	end

	local speed = dodgeSpeed()
	local manual = getManualDirection(now)
	local commit = panic and CFG.PANIC_COMMIT_TIME or CFG.COMMIT_TIME
	local since = now - lastChoose

	local need = targetDir.Magnitude < 0.1 or since >= commit
	local curScore, curWorst
	if targetDir.Magnitude > 0.1 then
		curScore, curWorst = scoreDirection(targetDir, myPos, speed, threats, manual)
		if not need and since >= 0.05 and curWorst < 0 then
			need = true
		end
	end

	if need then
		local dir, sc, _, wantJump = chooseDirection(myPos, speed, threats, manual)
		if curScore and curWorst >= 0 and curScore >= sc - CFG.SWITCH_GAIN then
			dir = targetDir
		end
		if dir.Magnitude > 0.1 then
			targetDir = dir
			lastChoose = now
		end
		jumpPlanned = wantJump
	end

	if jumpPlanned and now - lastJump >= CFG.JUMP_COOLDOWN and Humanoid.FloorMaterial ~= Enum.Material.Air then
		Humanoid.Jump = true
		lastJump = now
		jumpPlanned = false
	end

	-- Р”СЌС€: СЃСЂРѕС‡РЅР°СЏ СѓРіСЂРѕР·Р°, С€Р°РіРѕРј РЅРµ СѓР№С‚Рё, Р° СЂС‹РІРєРѕРј РІС‹С…РѕРґРёС‚ Р·Р°РјРµС‚РЅРѕ Р»СѓС‡С€Рµ
	if CFG.DASH_ENABLED and panic and now >= dashUntil and now - lastDash >= CFG.DASH_COOLDOWN
		and now - lastJump > 0.6
		and (CFG.DASH_IN_AIR or Humanoid.FloorMaterial ~= Enum.Material.Air)
		and targetDir.Magnitude > 0.1
	then
		local ns, nw = scoreDirection(targetDir, myPos, speed, threats, manual)
		if nw < CFG.DASH_NEED then
			local dash = { speed = CFG.DASH_SPEED, time = CFG.DASH_TIME }
			local dd, ds = chooseDirection(myPos, speed, threats, manual, dash)
			if dd.Magnitude > 0.1 and ds > ns + CFG.DASH_GAIN then
				dashDir = dd
				dashUntil = now + CFG.DASH_TIME
				lastDash = now
				targetDir, curDir, lastChoose = dd, dd, now
				dodgeUntil = math.max(dodgeUntil, dashUntil + 0.12)
				if CFG.DASH_HOOK then
					pcall(CFG.DASH_HOOK, dd, 1 - math.clamp((tUrgent or 0) / CFG.PANIC_TIME, 0, 1))
				end
			end
		end
	end

	if CFG.DEBUG then
		print("[AutoDodge] threats:", #threats, "panic:", panic, "tHit:", tHit)
	end
end

--==============================================================
-- РЎРљРћР РћРЎРўР¬
--==============================================================

local function updateSpeed()
	if not CFG.ENABLE_SPEED_BOOST then
		return
	end

	local ws = Humanoid.WalkSpeed

	-- РљС‚Рѕ-С‚Рѕ РґСЂСѓРіРѕР№ РїРѕРјРµРЅСЏР» СЃРєРѕСЂРѕСЃС‚СЊ: РїСЂРёРЅРёРјР°РµРј РµС‘ РєР°Рє Р±Р°Р·РѕРІСѓСЋ
	if boosted and math.abs(ws - lastSet) > 0.01 then
		boosted = false
	end
	if not boosted then
		baseSpeed = ws
	end

	if active then
		local target = baseSpeed * (panic and CFG.PANIC_SPEED_MULT or CFG.SPEED_MULT)
		if math.abs(ws - target) > 0.01 then
			Humanoid.WalkSpeed = target
		end
		lastSet = target
		boosted = true
	elseif boosted then
		Humanoid.WalkSpeed = baseSpeed
		boosted = false
	end
end

--==============================================================
-- Р”Р’РР–Р•РќРР•
--==============================================================
-- РќР°РїСЂР°РІР»РµРЅРёРµ СЃС‡РёС‚Р°РµС‚СЃСЏ РєР°Р¶РґС‹Р№ РєР°РґСЂ (RenderStep), Р° Move РІС‹Р·С‹РІР°РµС‚СЃСЏ
-- РµС‰С‘ Рё РІ Stepped: СЌС‚Рѕ РїРѕСЃР»РµРґРЅРёР№ РІС‹Р·РѕРІ РїРµСЂРµРґ С„РёР·РёРєРѕР№, РїРѕСЌС‚РѕРјСѓ СЃРІРѕР№
-- РґР¶РѕР№СЃС‚РёРє РёР»Рё РґСЂСѓРіРѕР№ СЃРєСЂРёРїС‚ РЅРµ РїРµСЂРµР±СЊС‘С‚ СѓРІРѕСЂРѕС‚.

local finalDir = Vector3.zero

local function advanceMovement(dt)
	if not isAlive() then
		finalDir = Vector3.zero
		return
	end

	updateSpeed()

	if not active or targetDir.Magnitude < 0.1 then
		curDir = Vector3.zero
		finalDir = Vector3.zero
		return
	end

	local smooth = CFG.SMOOTH * (panic and 1.8 or 1)
	local alpha = 1 - math.exp(-smooth * math.clamp(dt, 0, 0.05))

	if curDir.Magnitude < 0.1 then
		curDir = targetDir
	else
		curDir = unit(curDir:Lerp(targetDir, alpha))
		if curDir.Magnitude < 0.1 then
			curDir = targetDir
		end
	end

	local final = curDir
	if not panic then
		local manual = getManualDirection(os.clock())
		if manual.Magnitude > 0.1 then
			local blended = unit(final * (1 - CFG.MANUAL_BLEND) + manual * CFG.MANUAL_BLEND)
			if blended.Magnitude > 0.1 then
				final = blended
			end
		end
	end
	finalDir = final
end

local function applyMove()
	if not isAlive() then
		return
	end
	if os.clock() < dashUntil and dashDir.Magnitude > 0.1 and enabled then
		-- СЂС‹РІРѕРє: Р·Р°РґР°С‘Рј РіРѕСЂРёР·РѕРЅС‚Р°Р»СЊРЅСѓСЋ СЃРєРѕСЂРѕСЃС‚СЊ, РІРµСЂС‚РёРєР°Р»СЊ РЅРµ С‚СЂРѕРіР°РµРј
		local v = Root.AssemblyLinearVelocity
		Root.AssemblyLinearVelocity = Vector3.new(dashDir.X * CFG.DASH_SPEED, v.Y, dashDir.Z * CFG.DASH_SPEED)
		Humanoid:Move(dashDir, false)
		dashWas = true
		return
	end
	if dashWas then
		-- РєРѕРЅРµС† СЂС‹РІРєР°: РїР»Р°РІРЅРѕ РІРѕР·РІСЂР°С‰Р°РµРјСЃСЏ Рє РѕР±С‹С‡РЅРѕР№ СЃРєРѕСЂРѕСЃС‚Рё
		dashWas = false
		local v = Root.AssemblyLinearVelocity
		local sp = Humanoid.WalkSpeed
		Root.AssemblyLinearVelocity = Vector3.new(dashDir.X * sp, v.Y, dashDir.Z * sp)
	end
	if finalDir.Magnitude > 0.1 and active then
		Humanoid:Move(finalDir, false)
	end
end

--==============================================================
-- РРќРўР•Р Р¤Р•Р™РЎ: РєРЅРѕРїРєР°, HUD, РѕС‚Р»Р°РґРѕС‡РЅС‹Р№ СЂРёСЃСѓРЅРѕРє
--==============================================================

local gui, toggleBtn, hudLabel
local debugFolder, debugPool = nil, {}

local UI_TEXT = {
	ru = { on = "РЈР’РћР РћРў: Р’РљР›", off = "РЈР’РћР РћРў: Р’Р«РљР›", pause = "РЈР’РћР РћРў: РџРђРЈР—Рђ", threats = "СѓРіСЂРѕР·", learned = "РІС‹СѓС‡РµРЅРѕ" },
	en = { on = "DODGE: ON", off = "DODGE: OFF", pause = "DODGE: PAUSED", threats = "threats", learned = "learned" },
}
local TXT
do
	local lang = CFG.LANGUAGE
	if lang == "auto" or UI_TEXT[lang] == nil then
		lang = string.sub(string.lower(LocalPlayer.LocaleId or ""), 1, 2) == "ru" and "ru" or "en"
	end
	TXT = UI_TEXT[lang]
end

local function refreshToggle()
	if toggleBtn then
		if not enabled then
			toggleBtn.Text = TXT.off
			toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
		elseif holdPause then
			toggleBtn.Text = TXT.pause
			toggleBtn.BackgroundColor3 = Color3.fromRGB(190, 140, 20)
		else
			toggleBtn.Text = TXT.on
			toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 140, 70)
		end
	end
end

local function setEnabled(v)
	enabled = v and true or false
	if not enabled then
		active, panic, targetDir, curDir, finalDir = false, false, Vector3.zero, Vector3.zero, Vector3.zero
		dashUntil, dashWas = 0, false
	end
	pcall(function()
		LocalPlayer:SetAttribute("AutoDodgeEnabled", enabled)
	end)
	refreshToggle()
end


--==============================================================
-- API Р”Р›РЇ РР“Р Р«: shared.AutoDodge
-- Р’С‹Р·С‹РІР°Р№ РёР· СЃРІРѕРёС… РєР»РёРµРЅС‚СЃРєРёС… РјРѕРґСѓР»РµР№ Р°С‚Р°Рє (Replicate/*Client),
-- РєРѕРіРґР° Р·РЅР°РµС€СЊ С‚РѕС‡РЅСѓСЋ Р·РѕРЅСѓ СѓРґР°СЂР°. РўРѕРіРґР° СЃРєСЂРёРїС‚ РЅРµ РіР°РґР°РµС‚.
--   AutoDodge.AddBox(cframe, size, duration, delay, opts)
--   AutoDodge.AddSphere(position, radius, duration, delay, opts)
--   AutoDodge.AddRay(origin, direction, length, width, duration, delay, opts)
--   AutoDodge.SetEnabled(bool) / AutoDodge.IsEnabled()
--   AutoDodge.Discover(СЂР°РґРёСѓСЃ) -- РїРµС‡Р°С‚Р°РµС‚ РІ Output РІСЂР°РіРѕРІ, С‚РµРіРё, Р°С‚СЂРёР±СѓС‚С‹, Р°РЅРёРјР°С†РёРё Рё РѕРїР°СЃРЅС‹Рµ РґРµС‚Р°Р»Рё СЂСЏРґРѕРј
--   AutoDodge.CFG -- С‚Р°Р±Р»РёС†Р° РЅР°СЃС‚СЂРѕРµРє: shared.AutoDodge.CFG.MARGIN = 3 РјРµРЅСЏРµС‚ РЅР° Р»РµС‚Сѓ
--   AutoDodge.HookRemote(РёРјСЏ РёР»Рё RemoteEvent, function(...) ... end)
--       -- СЃР»СѓС€Р°РµС‚ С‚РІРѕР№ СЂРµРјРѕСѓС‚ (OnClientEvent); РІРЅСѓС‚СЂРё РІС‹Р·С‹РІР°Р№ AddBox/AddSphere/AddRay
--   AutoDodge.DumpLearned() -- РїРµС‡Р°С‚Р°РµС‚ РІС‹СѓС‡РµРЅРЅРѕРµ РІ Output, С‡С‚РѕР±С‹ РІСЃС‚Р°РІРёС‚СЊ РІ LEARNED_SEED/KEYFRAME_SEED
--   AutoDodge.Busy(seconds)  -- В«Р·Р°РЅСЏС‚В» (Р»РµС‡Сѓ, РєРѕР»РґСѓСЋ): СѓРІРѕСЂРѕС‚ РЅРµ СѓРІРѕРґРёС‚ СЃ РјРµСЃС‚Р°
--   AutoDodge.Pause(seconds) -- Р¶С‘СЃС‚РєР°СЏ РїР°СѓР·Р°, AutoDodge.Resume() СЃРЅРёРјР°РµС‚ РїР°СѓР·Сѓ Рё В«Р·Р°РЅСЏС‚В»
--   (С‚Рѕ Р¶Рµ РјРѕР¶РЅРѕ С‡РµСЂРµР· LocalPlayer:SetAttribute("DodgeBusy", true/false))
-- delay = С‡РµСЂРµР· СЃРєРѕР»СЊРєРѕ СЃРµРєСѓРЅРґ СѓРґР°СЂ СЃС‚Р°РЅРµС‚ РѕРїР°СЃРЅС‹Рј (РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ 0)
-- opts  = { velocity = Vector3, urgent = true/false }
--==============================================================
-- Р Р°Р·РІРµРґРєР°: РїРµС‡Р°С‚Р°РµС‚ РІ Output, С‡С‚Рѕ РІРёРґРЅРѕ РІРѕРєСЂСѓРі (РёРјРµРЅР°, С‚РµРіРё, Р°С‚СЂРёР±СѓС‚С‹, Р°РЅРёРјР°С†РёРё),
-- С‡С‚РѕР±С‹ Р±С‹СЃС‚СЂРѕ Р·Р°РїРѕР»РЅРёС‚СЊ РїСЂРѕС„РёР»СЊ РёРіСЂС‹. Р’С‹Р·РѕРІ: shared.AutoDodge.Discover(СЂР°РґРёСѓСЃ)
local function discover(radius)
	radius = type(radius) == "number" and radius or 60
	if not isAlive() then
		print("[AutoDodge] Discover: РЅРµС‚ Р¶РёРІРѕРіРѕ РїРµСЂСЃРѕРЅР°Р¶Р°")
		return
	end
	local myPos = Root.Position
	local L = { string.format("===== AutoDodge Discover (СЂР°РґРёСѓСЃ %d) =====", radius) }
	local function add(fmt, ...)
		L[#L + 1] = string.format(fmt, ...)
	end
	local function attrs(inst, label)
		for k, v in pairs(inst:GetAttributes()) do
			add("   Р°С‚СЂРёР±СѓС‚ %s: %s = %s", label, tostring(k), tostring(v))
		end
	end

	local found = 0
	for actor in pairs(humanoids) do
		local model = actor.Parent
		local root = model and model ~= Character and getRoot(model)
		if root then
			local d = (root.Position - myPos).Magnitude
			if d <= radius then
				found += 1
				add("[%s] %s (%s) %.0f studs", actor.ClassName, model.Name,
					Players:GetPlayerFromCharacter(model) and "РёРіСЂРѕРє" or "РјРѕР±", d)
				local tags = CollectionService:GetTags(model)
				if #tags > 0 then
					add("   С‚РµРіРё: %s", table.concat(tags, ", "))
				end
				attrs(model, "РјРѕРґРµР»Рё")
				attrs(actor, actor.ClassName)
				attrs(root, "РєРѕСЂРЅСЏ")
				local tool = model:FindFirstChildOfClass("Tool")
				if tool then
					add("   РїСЂРµРґРјРµС‚: %s (РґР°Р»СЊРЅРёР№ Р±РѕР№: %s)", tool.Name, isRangedTool(tool, os.clock()) and "РґР°" or "РЅРµС‚")
					attrs(tool, "РїСЂРµРґРјРµС‚Р°")
				end
				local animator = getAnimator(actor)
				if animator then
					local ok, tracks = pcall(function()
						return animator:GetPlayingAnimationTracks()
					end)
					if ok and tracks then
						for _, tr in ipairs(tracks) do
							if tr.IsPlaying then
								local id = trackId(tr)
								local hitText = ""
								local hits = hitTimesFor(id)
								if hits then
									local parts = {}
									for _, h in ipairs(hits) do
										parts[#parts + 1] = string.format("%.2f", h)
									end
									hitText = "  СѓРґР°СЂС‹: " .. table.concat(parts, ", ")
								end
								add("   Р°РЅРёРјР°С†РёСЏ: %s | %s | prio=%s len=%.2f loop=%s | РІРёРґ=%s%s",
									tr.Name, id, tr.Priority.Name, tr.Length, tostring(tr.Looped),
									tostring(classifyTrack(tr)), hitText)
							end
						end
					end
				end
			end
		end
	end

	local fc, shown = 0, 0
	for part in pairs(flaggedParts) do
		if part.Parent and (part.Position - myPos).Magnitude <= radius then
			fc += 1
			if shown < 10 then
				shown += 1
				add("[РѕРїР°СЃРЅР°СЏ РґРµС‚Р°Р»СЊ] %s  %.0fx%.0fx%.0f", part:GetFullName(), part.Size.X, part.Size.Y, part.Size.Z)
			end
		end
	end
	add("РІСЂР°РіРѕРІ СЂСЏРґРѕРј: %d, РѕРїР°СЃРЅС‹С… РґРµС‚Р°Р»РµР№ СЂСЏРґРѕРј: %d (РїРѕРєР°Р·Р°РЅРѕ %d)", found, fc, shown)
	attrs(Character, "РјРѕРµРіРѕ РїРµСЂСЃРѕРЅР°Р¶Р°")
	print(table.concat(L, "\n"))
end

local function pushManual(m, delay, duration, opts)
	local now = os.clock()
	m.startT = now + (delay or 0)
	m.endT = m.startT + math.max(duration or 0.3, 0.05)
	m.vel = opts and opts.velocity or Vector3.zero
	m.urgent = not (opts and opts.urgent == false)
	if #manualThreats >= 40 then
		table.remove(manualThreats, 1)
	end
	manualThreats[#manualThreats + 1] = m
end

shared.AutoDodge = {
	AddBox = function(cf, size, duration, delay, opts)
		if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
			return
		end
		local half = size * 0.5
		pushManual({ kind = "box", cf = cf, half = half, reach = math.max(half.X, half.Y, half.Z) }, delay, duration, opts)
	end,
	AddSphere = function(pos, radius, duration, delay, opts)
		if typeof(pos) ~= "Vector3" or type(radius) ~= "number" then
			return
		end
		pushManual({
			kind = "ell", cf = CFrame.new(pos),
			rf = radius, rb = radius, rs = radius, ry = math.max(radius, 3), reach = radius,
		}, delay, duration, opts)
	end,
	AddRay = function(origin, direction, length, width, duration, delay, opts)
		if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" or direction.Magnitude < 0.01 then
			return
		end
		length = length or 100
		width = width or 2.5
		local dir = direction.Unit
		local center = origin + dir * (length * 0.5)
		pushManual({
			kind = "box", cf = CFrame.lookAt(center, center + dir),
			half = Vector3.new(width, 4, length * 0.5), reach = length * 0.5,
		}, delay, duration, opts)
	end,
	Busy = function(seconds)
		busyUntil = math.max(busyUntil, os.clock() + (type(seconds) == "number" and seconds or 0.5))
	end,
	Pause = function(seconds)
		hardPauseUntil = os.clock() + (type(seconds) == "number" and seconds or 0.5)
	end,
	Resume = function()
		hardPauseUntil, busyUntil = 0, 0
	end,
	Discover = discover,
	CFG = CFG,
	HookRemote = function(remote, handler)
		if type(handler) ~= "function" then
			return
		end
		task.spawn(function()
			if type(remote) == "string" then
				local rs = game:GetService("ReplicatedStorage")
				local name, t0 = remote, os.clock()
				remote = nil
				while not remote and os.clock() - t0 < 15 do
					remote = rs:FindFirstChild(name, true)
					if not remote then
						task.wait(0.5)
					end
				end
			end
			if typeof(remote) == "Instance" and remote:IsA("RemoteEvent") then
				table.insert(rootConns, remote.OnClientEvent:Connect(function(...)
					local ok, err = pcall(handler, ...)
					if not ok then
						warn("[AutoDodge] HookRemote:", err)
					end
				end))
			end
		end)
	end,
	DumpLearned = function()
		local out = { "-- AutoDodge: РІСЃС‚Р°РІСЊ РІ РїСЂРѕС„РёР»СЊ РёРіСЂС‹ (PROFILES[PlaceId])", "LEARNED_SEED = {" }
		for id, rec in pairs(learned) do
			out[#out + 1] = string.format('\t["%s"] = { n = %d, hitAt = %.2f },', id, rec.n, rec.hitAt)
		end
		out[#out + 1] = "},"
		out[#out + 1] = "KEYFRAME_SEED = {"
		for id, rec in pairs(kfLive) do
			local parts = {}
			for _, h in ipairs(rec.hits) do
				parts[#parts + 1] = string.format("%.2f", h)
			end
			out[#out + 1] = string.format('\t["%s"] = { %s },', id, table.concat(parts, ", "))
		end
		out[#out + 1] = "},"
		print(table.concat(out, "\n"))
	end,
	SetEnabled = function(v)
		setEnabled(v)
	end,
	IsEnabled = function()
		return enabled
	end,
}

-- РЎРјРµС‰РµРЅРёРµ РєРЅРѕРїРєРё С‚Р°Рє, С‡С‚РѕР±С‹ РѕРЅР° РЅРµ РІС‹С…РѕРґРёР»Р° Р·Р° СЌРєСЂР°РЅ
local function clampOffset(off, scale, view, size)
	local lo = -scale * view
	local hi = math.max(view - size, 0) + lo
	return math.clamp(off, lo, hi)
end

local function buildGui()
	local pg = LocalPlayer:WaitForChild("PlayerGui", 10)
	if not pg then
		return
	end
	gui = Instance.new("ScreenGui")
	gui.Name = "AutoDodgeGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 50
	gui.Parent = pg

	if CFG.TOGGLE_BUTTON then
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(128, 34)
		btn.Position = UDim2.new(0, 12, 0.32, 0)
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.BackgroundTransparency = 0.15
		btn.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = btn
		toggleBtn = btn
		refreshToggle()

		local dragging, moved, dragStart, startPos, dragInput = false, false, Vector2.zero, btn.Position, nil
		local function isPointer(input)
			return input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
		end
		table.insert(rootConns, btn.InputBegan:Connect(function(input)
			if isPointer(input) then
				dragging, moved = true, false
				dragInput = input
				dragStart = Vector2.new(input.Position.X, input.Position.Y)
				startPos = btn.Position
			end
		end))
		table.insert(rootConns, UserInputService.InputChanged:Connect(function(input)
			if dragging and dragInput and (input == dragInput
				or (input.UserInputType == Enum.UserInputType.MouseMovement
					and dragInput.UserInputType == Enum.UserInputType.MouseButton1))
			then
				local d = Vector2.new(input.Position.X, input.Position.Y) - dragStart
				if d.Magnitude > 8 then
					moved = true
				end
				if moved then
					local view, size = gui.AbsoluteSize, btn.AbsoluteSize
					btn.Position = UDim2.new(
						startPos.X.Scale, clampOffset(startPos.X.Offset + d.X, startPos.X.Scale, view.X, size.X),
						startPos.Y.Scale, clampOffset(startPos.Y.Offset + d.Y, startPos.Y.Scale, view.Y, size.Y)
					)
				end
			end
		end))
		table.insert(rootConns, UserInputService.InputEnded:Connect(function(input)
			if dragging and input == dragInput then
				dragging = false
				dragInput = nil
				if not moved then
					setEnabled(not enabled)
				end
			end
		end))
	end

	if CFG.DEBUG_HUD then
		local l = Instance.new("TextLabel")
		l.Size = UDim2.fromOffset(260, 70)
		l.Position = UDim2.new(0, 12, 0.32, 40)
		l.BackgroundColor3 = Color3.new(0, 0, 0)
		l.BackgroundTransparency = 0.5
		l.TextColor3 = Color3.new(1, 1, 1)
		l.Font = Enum.Font.Code
		l.TextSize = 13
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.Parent = gui
		hudLabel = l
	end
end

local function updateHud()
	if hudLabel then
		hudLabel.Text = string.format(
			"%s | " .. TXT.threats .. ": %d\nactive: %s panic: %s\ntHit: %s\n" .. TXT.learned .. ": %d%s",
			enabled and "ON" or "OFF", lastStats.threats, tostring(active), tostring(panic),
			lastStats.tHit and string.format("%.2f", lastStats.tHit) or "-",
			(function()
				local c = 0
				for _ in pairs(learned) do c += 1 end
				return c
			end)(),
			lastError ~= "" and ("\nERR: " .. string.sub(lastError, 1, 60)) or ""
		)
	end
end

local function updateDraw()
	if not CFG.DEBUG_DRAW then
		return
	end
	local cam = Workspace.CurrentCamera
	if not cam then
		return
	end
	if not debugFolder or not debugFolder.Parent then
		debugFolder = Instance.new("Folder")
		debugFolder.Name = "AutoDodgeDebug"
		debugFolder.Parent = cam
		debugPool = {}
	end
	for i = 1, math.max(#threats, #debugPool) do
		local th = threats[i]
		local p = debugPool[i]
		if th and not p then
			p = Instance.new("Part")
			p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
			p.Material = Enum.Material.Neon
			p.Transparency = 0.65
			local m = Instance.new("SpecialMesh")
			m.Parent = p
			p.Parent = debugFolder
			debugPool[i] = p
		end
		if p then
			if th then
				local mesh = p:FindFirstChildOfClass("SpecialMesh")
				if th.kind == "ell" then
					p.Size = Vector3.new(th.rs * 2, th.ry * 2, th.rf + th.rb)
					p.CFrame = th.cf * CFrame.new(0, 0, -(th.rf - th.rb) / 2)
					if mesh then mesh.MeshType = Enum.MeshType.Sphere end
				else
					p.Size = th.half * 2
					p.CFrame = th.cf
					if mesh then mesh.MeshType = Enum.MeshType.Brick end
				end
				p.Color = th.from <= 0.05 and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 200, 50)
				p.Transparency = 0.65
			else
				p.Transparency = 1
			end
		end
	end
end

--==============================================================
-- РџР•Р РЎРћРќРђР–
--==============================================================

local function resetState()
	threats = {}
	active, panic, jumpPlanned = false, false, false
	targetDir, curDir, finalDir = Vector3.zero, Vector3.zero, Vector3.zero
	dodgeUntil, lastChoose, lastThink = 0, 0, 0
	dashUntil, dashWas = 0, false
end

local function disconnectList(list)
	for _, c in ipairs(list) do
		if c.Connected then
			c:Disconnect()
		end
	end
	table.clear(list)
end

local function setupCharacter(char)
	disconnectList(charConns)

	Character = char
	Humanoid = nil
	Root = nil
	resetState()
	boosted = false

	local hum = char:WaitForChild("Humanoid", 10)
	local root = char:WaitForChild("HumanoidRootPart", 10)

	if Character ~= char or not hum or not root then
		return
	end

	Humanoid = hum
	Root = root
	baseSpeed = hum.WalkSpeed

	rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { char }
	rayParams.IgnoreWater = true
	rayParams.RespectCanCollide = true

	-- РїСЂРµРґРјРµС‚С‹-Р»РµС‡РёР»РєРё: РїРѕРєР° Р·Р°Р¶Р°С‚Р° РєРЅРѕРїРєР°, С‚С‹ В«Р·Р°РЅСЏС‚В»
	table.clear(toolDown)
	local hooked = {}
	local function hookTool(tool)
		if not tool:IsA("Tool") or hooked[tool] or not containsWord(tool.Name, CFG.BUSY_TOOL_WORDS) then
			return
		end
		hooked[tool] = true
		local function release()
			if toolDown[tool] then
				toolDown[tool] = nil
				busyUntil = math.max(busyUntil, os.clock() + CFG.BUSY_TAIL)
			end
		end
		table.insert(charConns, tool.Activated:Connect(function()
			toolDown[tool] = true
		end))
		table.insert(charConns, tool.Deactivated:Connect(release))
		table.insert(charConns, tool.Unequipped:Connect(release))
	end
	for _, child in ipairs(char:GetChildren()) do
		hookTool(child)
	end
	table.insert(charConns, char.ChildAdded:Connect(hookTool))

	local lastHealth = hum.Health
	table.insert(charConns, hum.HealthChanged:Connect(function(h)
		if h < lastHealth - 0.5 and Root then
			pcall(learnFromHit, Root.Position)
		end
		lastHealth = h
	end))

	table.insert(charConns, hum.Died:Connect(function()
		if boosted then
			hum.WalkSpeed = baseSpeed
			boosted = false
		end
		resetState()
	end))
end

--==============================================================
-- Р—РђРџРЈРЎРљ
--==============================================================

-- РїСЂРµРґР·Р°РїРѕР»РЅРµРЅРёРµ РёР· РїСЂРѕС„РёР»СЏ/РЅР°СЃС‚СЂРѕРµРє
for id, rec in pairs(CFG.LEARNED_SEED or {}) do
	if type(rec) == "table" and type(rec.hitAt) == "number" then
		learned[id] = { n = rec.n or 1, hitAt = rec.hitAt }
	end
end
for id, hits in pairs(CFG.KEYFRAME_SEED or {}) do
	if type(hits) == "table" and #hits > 0 then
		kfInfo[id] = { hits = hits, src = "seed" }
	end
end

if CFG.ENABLED then
	pcall(function()
		LocalPlayer:SetAttribute("AutoDodgeEnabled", enabled)
	end)
	table.insert(rootConns, LocalPlayer:GetAttributeChangedSignal("AutoDodgeEnabled"):Connect(function()
		local v = LocalPlayer:GetAttribute("AutoDodgeEnabled")
		if type(v) == "boolean" and v ~= enabled then
			setEnabled(v)
		end
	end))

	table.insert(rootConns, UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and CFG.TOGGLE_KEY and input.KeyCode == CFG.TOGGLE_KEY then
			setEnabled(not enabled)
		end
	end))

	task.spawn(function()
		local ok, err = pcall(buildGui)
		if not ok then
			warn("[AutoDodge] РёРЅС‚РµСЂС„РµР№СЃ РЅРµ СЃРѕР·РґР°РЅ:", err)
		end
	end)

	startRegistries()

	if CFG.SUSPEND_KEY then
		table.insert(rootConns, UserInputService.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == CFG.SUSPEND_KEY then
				suspendHeld = true
			end
		end))
		table.insert(rootConns, UserInputService.InputEnded:Connect(function(input)
			if input.KeyCode == CFG.SUSPEND_KEY then
				suspendHeld = false
			end
		end))
		table.insert(rootConns, UserInputService.WindowFocusReleased:Connect(function()
			suspendHeld = false
		end))
	end

	table.insert(rootConns, LocalPlayer.CharacterAdded:Connect(setupCharacter))
	if LocalPlayer.Character then
		task.spawn(setupCharacter, LocalPlayer.Character)
	end

	table.insert(rootConns, RunService.Heartbeat:Connect(function()
		if not isAlive() or not rayParams then
			return
		end

		local now = os.clock()
		-- РЅРµР±РѕР»СЊС€РѕР№ РґРѕРїСѓСЃРє, С‡С‚РѕР±С‹ РїСЂРё 60 FPS think С€С‘Р» СЂРѕРІРЅРѕ РєР°Р¶РґС‹Р№ 2-Р№ РєР°РґСЂ (30 Р“С†)
		if now - lastThink < (perfLow and CFG.LOW_THINK_RATE or CFG.THINK_RATE) - 0.004 then
			return
		end
		lastThink = now

		local ok, err = pcall(think, now)
		if CFG.ADAPTIVE_PERF then
			thinkAvg = thinkAvg * 0.9 + (os.clock() - now) * 1000 * 0.1
			if not perfLow and thinkAvg > CFG.PERF_BUDGET_MS then
				perfLow = true
			elseif perfLow and thinkAvg < CFG.PERF_BUDGET_MS * 0.4 then
				perfLow = false
			end
		end
		if not ok then
			local msg = tostring(err)
			if msg ~= lastError then
				lastError = msg
				warn("[AutoDodge] РѕС€РёР±РєР°:", msg)
			end
		end
		pcall(updateDraw)
		pcall(updateHud)
		if holdPause ~= shownPause then
			shownPause = holdPause
			refreshToggle()
		end
	end))

	table.insert(rootConns, RunService.Stepped:Connect(applyMove))

	pcall(function()
		RunService:UnbindFromRenderStep("AutoDodgeMove")
	end)
	RunService:BindToRenderStep("AutoDodgeMove", Enum.RenderPriority.Last.Value, function(dt)
		advanceMovement(dt)
		applyMove()
	end)
end

script.Destroying:Connect(function()
	pcall(function()
		RunService:UnbindFromRenderStep("AutoDodgeMove")
	end)
	if Humanoid and boosted then
		Humanoid.WalkSpeed = baseSpeed
	end
	if gui then
		gui:Destroy()
	end
	if debugFolder then
		debugFolder:Destroy()
	end
	disconnectList(charConns)
	disconnectList(rootConns)
end)
