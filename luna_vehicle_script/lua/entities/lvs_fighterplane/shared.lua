
ENT.Base = "lvs_baseentity"

ENT.PrintName = "plane basescript"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS]"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/blu/bf109.mdl"

ENT.AITEAM = 0

ENT.MaxVelocity = 2500
ENT.MaxPerfVelocity = 1500
ENT.MaxThrust = 100

ENT.TurnRatePitch = 1
ENT.TurnRateYaw = 1
ENT.TurnRateRoll = 1

ENT.ForceLinearMultiplier = 1

ENT.ForceAngleMultiplier = 1
ENT.ForceAngleDampingMultiplier = 1

ENT.MaxSlipAnglePitch = 20
ENT.MaxSlipAngleYaw = 10

ENT.MaxHealth = 1000

function ENT:SetupDataTables()
	self:CreateBaseDT()

	self:AddDT( "Vector", "Steer" )
	self:AddDT( "Float", "Throttle" )
end

function ENT:PlayerDirectInput( ply, cmd )
	local Delta = FrameTime()

	local KeyLeft = cmd:KeyDown( IN_MOVERIGHT )
	local KeyRight = cmd:KeyDown( IN_MOVELEFT )
	local KeyPitch = cmd:KeyDown( IN_SPEED )

	local MouseY = KeyPitch and -10 or cmd:GetMouseY()

	local Input = Vector( cmd:GetMouseX(), MouseY * 4, 0 ) * 0.25

	local Cur = self:GetSteer()

	local Rate = Delta * 2

	local New = Vector(Cur.x, Cur.y, 0) - Vector( math.Clamp(Cur.x * Delta * 5,-Rate,Rate), math.Clamp(Cur.y * Delta * 5,-Rate,Rate), 0)

	local Target = New + Input * Delta * 0.8

	local Fx = math.Clamp( Target.x, -1, 1 )
	local Fy = math.Clamp( Target.y, -1, 1 )

	local TargetFz = (KeyRight and 1 or 0) - (KeyLeft and 1 or 0)
	local Fz = Cur.z + math.Clamp(TargetFz - Cur.z,-Rate * 3,Rate * 3)

	local F = Cur + (Vector( Fx, Fy, Fz ) - Cur) * math.min(Delta * 100,1)

	self:SetSteer( F )
end

function ENT:PlayerMouseAim( ply, cmd )
	if CLIENT then return end

	local Pod = self:GetDriverSeat()

	local PitchUp = cmd:KeyDown( IN_SPEED ) --Driver:lfsGetInput( "+PITCH" )
	local PitchDown = false --Driver:lfsGetInput( "-PITCH" )
	local YawRight = cmd:KeyDown( IN_ATTACK2 ) --Driver:lfsGetInput( "+YAW" )
	local YawLeft = cmd:KeyDown( IN_ATTACK ) -- Driver:lfsGetInput( "-YAW" )
	local RollRight = cmd:KeyDown( IN_MOVERIGHT )
	local RollLeft = cmd:KeyDown( IN_MOVELEFT )

	local EyeAngles = Pod:WorldToLocalAngles( ply:EyeAngles() )

	if ply:KeyDown( IN_WALK ) then
		if isangle( self.StoredEyeAngles ) then
			EyeAngles = self.StoredEyeAngles
		end
	else
		self.StoredEyeAngles = EyeAngles
	end

	local OverridePitch = 0
	local OverrideYaw = 0
	local OverrideRoll = (RollRight and 1 or 0) - (RollLeft and 1 or 0)

	if PitchUp or PitchDown then
		EyeAngles = self:GetAngles()

		self.StoredEyeAngles = Angle(EyeAngles.p,EyeAngles.y,0)

		OverridePitch = (PitchUp and 1 or 0) - (PitchDown and 1 or 0)
	end

	if YawRight or YawLeft then
		EyeAngles = self:GetAngles()

		self.StoredEyeAngles = Angle(EyeAngles.p,EyeAngles.y,0)

		OverrideYaw = (YawRight and 1 or 0) - (YawLeft and 1 or 0) 
	end

	self:ApproachTargetAngle( EyeAngles, OverridePitch, OverrideYaw, OverrideRoll )
end

function ENT:CalcThrottle( ply, cmd )
	local Delta = FrameTime()

	local ThrottleUp = cmd:KeyDown( IN_FORWARD ) and 1 or 0
	local ThrottleDown = cmd:KeyDown( IN_BACK ) and -1 or 0

	local Throttle = (ThrottleUp + ThrottleDown) * Delta

	self:SetThrottle( math.Clamp(self:GetThrottle() + Throttle,0,1) )
end

function ENT:StartCommand( ply, cmd )
	if self:GetDriver() ~= ply then return end

	if self:GetLockView() then
		self:PlayerDirectInput( ply, cmd )
	else
		self:PlayerMouseAim( ply, cmd )
	end

	self:CalcThrottle( ply, cmd )
end

function ENT:GetStability()
	local ForwardVelocity = self:WorldToLocal( self:GetPos() + self:GetVelocity() ).x

	local Stability = math.Clamp(ForwardVelocity / self.MaxPerfVelocity,0,1) ^ 2
	local InvStability = 1 - Stability

	return Stability, InvStability, ForwardVelocity
end
