include('shared.lua')

LANG.AddToLanguage("english", "slam_full", "You currently cannot carry SLAM's.")
LANG.AddToLanguage("english", "slam_disarmed", "A SLAM you've planted has been disarmed.")

ENT.PrintName = "M4 SLAM"
ENT.Icon = "vgui/ttt/icon_slam"

hook.Add("TTT2ScoreboardAddPlayerRow", "ZaratusasTTTMod", function(ply)
	local ID64 = ply:SteamID64()
	local ID64String = tostring(ID64)

	if (ID64String == "76561198032479768") then
		AddTTT2AddonDev(ID64)
	end
end)

net.Receive("TTT_SLAMWarning", function()
	local idx = net.ReadUInt(16)
	local armed = net.ReadBool()

	if (armed) then
		local pos = net.ReadVector()

		if (TTT2) then
			local team = net.ReadString()
			RADAR.bombs[idx] = {pos = pos, nick = "SLAM", team = team}
		else
			RADAR.bombs[idx] = {pos = pos, nick = "SLAM"}
		end
	else
		RADAR.bombs[idx] = nil
	end

	RADAR.bombs_count = table.Count(RADAR.bombs)
end)
