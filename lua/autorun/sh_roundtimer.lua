if SERVER then

	util.AddNetworkString( "BurTimer" )
	util.AddNetworkString( "BurTimerWinner" )
	util.AddNetworkString( "BurTimerFinish" )
	
	local BurTimerCurrent = 0
	local BurTimerEnd = 0
	local BurTimerProgress = false

	function BurStartTimer(ply,cmd,args)
	
	
	
		if (not (ply:IsAdmin() or ply:IsSuperAdmin())) and ply ~= Entity(0) then
		
			ply:PrintMessage(HUD_PRINTTALK,"You're not an admin.")
		
			return
		end
		
		ply:PrintMessage(HUD_PRINTTALK,"Starting timer.")

		BurTimerProgress = true
		BurTimerCurrent = 0
		BurTimerEnd = args[1]*60
		
	end

	concommand.Add("starttimer",BurStartTimer)

	local NextThink = 0

	function BurTimerThink()
		
		if NextThink <= CurTime() then

			--print("Tick")
		
			if BurTimerProgress == true then
			
				--print("Tock")
			
				local OfficialCountdown = BurTimerEnd - BurTimerCurrent
				
				net.Start("BurTimer")
					net.WriteFloat(OfficialCountdown)
				net.Broadcast()
			
				if (BurTimerCurrent < BurTimerEnd) then
					BurTimerCurrent = BurTimerCurrent + 1
				else
		
					local WinnerEnt = game.GetWorld()
					local WinnerScore = -1
					local WinnerTie = true
					
					for k,v in pairs(player.GetAll()) do
						v:Lock()
						if Winner == nil then
							Winner = v
							WinnerScore = v:Frags()
						else
							if WinnerScore == v:Frags() then
								WinnerTie = true
							elseif WinnerScore < v:Frags() then
								Winner = v
								WinnerScore = v:Frags()
								WinnerTie = false
							end
						end
					end
					
					net.Start("BurTimerWinner")
						net.WriteEntity(WinnerEnt)
						net.WriteFloat(WinnerScore)
						net.WriteBool(WinnerTie)
					net.Broadcast()

					BurTimerProgress = false
					
					game.SetTimeScale(0.1)
					BurTimerEnableSlowMo = true
					BurTimerSlowMoTime = CurTime() + (5*0.1)
					
				end
				
			end
			
			
			if BurTimerEnableSlowMo == true and BurTimerSlowMoTime <= CurTime() then
			
				for k,v in pairs(player.GetAll()) do
					v:UnLock()
					v:Spawn()
				end
				
				net.Start("BurTimerFinish")
					net.WriteBool(true) -- we have to send something!
				net.Broadcast()
				game.SetTimeScale(1)
				
				BurTimerEnableSlowMo = false
				
				BurStartTimer(Entity(1),"starttimer",{5})
				
			end

			NextThink = CurTime() + 1
		
		end
		
	end

	hook.Add("Think","Burger Timer Think",BurTimerThink)
	
end

if CLIENT then

	surface.CreateFont("RoundTimerMedium", {
		font = "Tahoma", 
		size = 50, 
		weight = 500, 
		blursize = 0, 
		scanlines = 0, 
		antialias = true, 
		underline = false, 
		italic = false, 
		strikeout = false, 
		symbol = false, 
		rotary = false, 
		shadow = true, 
		additive = false, 
		outline = false, 
	})

	local TimerSound = {}
	TimerSound[300] = "ut/cd5min.wav"
	TimerSound[180] = "ut/cd3min.wav"
	TimerSound[60] = "ut/cd1min.wav"
	TimerSound[59] = "#music"
	TimerSound[30] = "ut/cd30sec.wav"
	TimerSound[10] = "ut/cd10.wav"
	TimerSound[9] = "ut/cd9.wav"
	TimerSound[8] = "ut/cd8.wav"
	TimerSound[7] = "ut/cd7.wav"
	TimerSound[6] = "ut/cd6.wav"
	TimerSound[5] = "ut/cd5.wav"
	TimerSound[4] = "ut/cd4.wav"
	TimerSound[3] = "ut/cd3.wav"
	TimerSound[2] = "ut/cd2.wav"
	TimerSound[1] = "ut/cd1.wav"
	TimerSound[0] = "#insult"
	
	local Countdown = 0

	net.Receive("BurTimer", function(len)

		local CurrentCountdown = net.ReadFloat()
		
	
	
		if Countdown > CurrentCountdown then
			NewRoundStart()
		end

		Countdown = CurrentCountdown

		
		if TimerSound[Countdown] then
		
			if TimerSound[Countdown] == "#music" then
				EmitSound("ut/music" .. math.random(1,9) ..".mp3",LocalPlayer():GetPos(),LocalPlayer():EntIndex(),CHAN_VOICE2,1,75,0,100)
			elseif TimerSound[Countdown] == "#insult" then
				EmitSound("ut/lose" .. math.random(1,9) ..".mp3",LocalPlayer():GetPos(),LocalPlayer():EntIndex(),CHAN_VOICE2,1,75,0,100)

			else
				EmitSound(TimerSound[Countdown],LocalPlayer():GetPos(),LocalPlayer():EntIndex(),CHAN_VOICE2,1,75,0,100)
			end
			
		end

	end)

	net.Receive("BurTimerWinner", function(len)
		local Winner = net.ReadEntity()
		local Score = net.ReadFloat()
		local Tie = net.ReadBool()
		gmod.GetGamemode():ScoreboardShow()
	end)
	
	net.Receive("BurTimerFinish", function(len)
		gmod.GetGamemode():ScoreboardHide()
	end)
	
	
	local RoundStart01 = {}
	RoundStart01[1] = "ut/wildwastelandstart.wav"
	RoundStart01[2] = "ut/start3.mp3"
	RoundStart01[3] = "ut/prepare.wav"
	
	local RoundStart02 = {}
	RoundStart02[1] = "music/austinwintory_01/startround_01.mp3"
	RoundStart02[2] = "music/austinwintory_01/startround_02.mp3"
	RoundStart02[3] = "music/awolnation_01/startround_01.mp3"
	
	
	
	function NewRoundStart()

	end
	
	function BurTimerDrawHud()
		
		local Nice = string.ToMinutesSeconds( Countdown )
	
	
		if Countdown == 0 and !LocalPlayer():IsFrozen() then
	
		else
			draw.DrawText( "DEATHMATCH", "RoundTimerMedium", ScrW() * 0.5, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
			draw.DrawText( Nice, "RoundTimerMedium", ScrW() * 0.5, 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		end

	end
	
	hook.Add("HUDPaint","Round Timer HUD", BurTimerDrawHud)
	
	
end





