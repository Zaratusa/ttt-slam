AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

util.AddNetworkString("TTT_SLAMWarning")

include('shared.lua')

hook.Add("TTTPrepareRound", "SLAMClean", function()
	for _, slam in pairs(ents.FindByClass("ttt_slam_*")) do
		slam:Remove()
	end
end)

function ENT:SendWarn(armed)
	local owner = self:GetPlacer()

	if (TTT2 or !armed or (IsValid(owner) and owner:IsRole(ROLE_TRAITOR))) then
		net.Start("TTT_SLAMWarning")

		net.WriteUInt(self:EntIndex(), 16)
		net.WriteBool(armed)

		if (armed) then
			net.WriteVector(self:GetPos())
			if (TTT2) then
				net.WriteString(owner:GetTeam())
			end
		end

		if (!armed) then
			if (TTT2) then
				net.Send(GetTeamFilter(owner:GetTeam(), true))
			else
				net.Send(GetTraitorFilter(true))
			end
		else
			net.Broadcast()
		end
	end
end

function ENT:Disarm(ply)
	local owner = self:GetPlacer()
	SCORE:HandleC4Disarm(ply, owner, true)

	if (IsValid(owner)) then
		LANG.Msg(owner, "slam_disarmed")
	end

	self:SetBodygroup(0, 0)
	self:SetDefusable(false)
	self:SendWarn(false)
end

function ENT:OnRemove()
	self:SendWarn(false)
end
