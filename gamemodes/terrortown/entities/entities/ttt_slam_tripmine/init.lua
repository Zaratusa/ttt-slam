AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

-- Tripmine explosion mode
-- 0: Explode when any player crosses the beam
-- 1: Explode when any non traitor crosses the beam
-- 2: Explode when any non team mate crosses the beam
CreateConVar("ttt_slam_tripmine_explosion_mode", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "When should the M4 SLAM explode in tripmine mode?", 0, 2)

-- support for TTT Custom Roles
local function IsInnocentRole(role)
	return (ROLE_INNOCENT and role == ROLE_INNOCENT)
		or (ROLE_DETECTIVE and role == ROLE_DETECTIVE)
		or (ROLE_MERCENARY and role == ROLE_MERCENARY)
		or (ROLE_PHANTOM and role == ROLE_PHANTOM)
		or (ROLE_GLITCH and role == ROLE_GLITCH)
end

-- support for TTT Custom Roles
local function IsTraitorRole(role)
	return (ROLE_TRAITOR and role == ROLE_TRAITOR)
		or (ROLE_ASSASSIN and role == ROLE_ASSASSIN)
		or (ROLE_HYPNOTIST and role == ROLE_HYPNOTIST)
		or (ROLE_ZOMBIE and role == ROLE_ZOMBIE)
		or (ROLE_VAMPIRE and role == ROLE_VAMPIRE)
		or (ROLE_KILLER and role == ROLE_KILLER)
end

local function IsInTraitorTeam(ply)
	if (TTT2) then -- support for TTT2
		return ply:GetTeam() == TEAM_TRAITOR
	else
		return IsTraitorRole(ply:GetRole())
	end
end

local function AreTeamMates(ply1, ply2)
	if (TTT2) then -- support for TTT2
		return ply1:IsInTeam(ply2)
	else
		if (ply1.GetTeam and ply2.GetTeam) then -- support for TTT Totem
			return ply1:GetTeam() == ply2:GetTeam()
		else
			return IsInnocentRole(ply1:GetRole()) == IsInnocentRole(ply2:GetRole()) or IsTraitorRole(ply1:GetRole()) == IsTraitorRole(ply2:GetRole())
		end
	end
end

function ENT:ActivateSLAM()
	if (IsValid(self)) then
		self.LaserPos = self:GetAttachment(self:LookupAttachment("beam_attach")).Pos

		local ignore = ents.GetAll()
		local tr = util.QuickTrace(self.LaserPos, self:GetUp() * 10000, ignore)
		self.LaserLength = tr.Fraction
		self.LaserEndPos = tr.HitPos

		self:SetDefusable(true)

		sound.Play(self.BeepSound, self:GetPos(), 65, 110, 0.7)
	end
end

local specDM = file.Exists("sh_spectator_deathmatch.lua", "LUA")

function ENT:Think()
	if (IsValid(self) and self:IsActive()) then
		local tr = util.QuickTrace(self.LaserPos, self:GetUp() * 10000, self)

		if (tr.Fraction < self.LaserLength and (!self.Exploding)) then
			local ent = tr.Entity

			-- Spectator Deathmatch support
			local isValid = IsValid(ent) and ent:IsPlayer() and !ent:IsSpec()
			if (isValid and specDM) then
				isValid = !ent:IsGhost()
			end

			if (isValid) then
				local explosionMode = GetConVar("ttt_slam_tripmine_explosion_mode"):GetInt()

				if (explosionMode == 0 or (explosionMode == 1 and !IsInTraitorTeam(ent)) or (explosionMode == 2 and !AreTeamMates(self:GetPlacer(), ent))) then
					self:StartExplode(true)
				end
			end
		end

		self:NextThink(CurTime() + 0.05)
		return true
	end
end
