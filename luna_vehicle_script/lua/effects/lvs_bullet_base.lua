
EFFECT.MatBeam = Material( "effects/lvs_base/spark" )
EFFECT.MatSprite = Material( "sprites/light_glow02_add" )

function EFFECT:Init( data )
	local pos  = data:GetOrigin()
	local dir = data:GetNormal()

	self.ID = data:GetFlags()

	self:SetRenderBoundsWS( pos, pos + dir * 50000 )
end

function EFFECT:Think()
	if not LVS:GetBullet( self.ID ) then return false end

	return true
end

function EFFECT:Render()
	local bullet = LVS:GetBullet( self.ID )

	local endpos = bullet:GetPos()
	local dir = bullet:GetDir()

	local len = 2500 * bullet:GetLength()

	render.SetMaterial( self.MatBeam )

	render.DrawBeam( endpos - dir * len, endpos + dir * len * 0.1, 10, 1, 0, Color( 255, 100, 0, 255 ) )
	render.DrawBeam( endpos - dir * len * 0.5, endpos + dir * len * 0.1,  7, 1, 0, Color( 255, 225, 0, 255 ) )
	render.DrawBeam( endpos - dir * len * 0.5, endpos + dir * len * 0.1, 5, 1, 0, Color( 255, 225, 0, 255 ) )
	render.DrawBeam( endpos - dir * len * 0.5, endpos + dir * len * 0.1, 5, 1, 0, Color( 255, 255, 0, 255 ) )

	render.SetMaterial( self.MatSprite ) 
	render.DrawSprite( endpos, 400, 400, Color( 125, 50, 0, 255 ) )
end
