require "UnLua"

local BP_CharacterBase_C = Class()

function BP_CharacterBase_C:Initialize(Initializer)
	self.IsDead = false
	self.BodyDuration = 3.0
	self.BoneName = nil
	local Health = 100
	self.Health = Health
	self.MaxHealth = Health
end

--function BP_CharacterBase_C:UserConstructionScript()
--end

function BP_CharacterBase_C:ReceiveBeginPlay()
	local Weapon = self:SpawnWeapon()
	if Weapon then
		Weapon:K2_AttachToComponent(self.WeaponPoint, nil, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget, UE4.EAttachmentRule.SnapToTarget)
		self.Weapon = Weapon
	end
end

function BP_CharacterBase_C:SpawnWeapon()
	return nil
end

function BP_CharacterBase_C:StartFire()
	if self.Weapon then
		self.Weapon:StartFire()
	end
end

function BP_CharacterBase_C:StopFire()
	if self.Weapon then
		self.Weapon:StopFire()
	end
end

function BP_CharacterBase_C:ReceiveAnyDamage(Damage, DamageType, InstigatedBy, DamageCauser)
	if not self.IsDead then
		local Health = self.Health - Damage
		self.Health = math.max(Health, 0)
		if Health <= 0.0 then
			self:Died(DamageType)
			local co = coroutine.create(BP_CharacterBase_C.Destroy)
			coroutine.resume(co, self, self.BodyDuration)
		end
	end
end

function BP_CharacterBase_C:Died(DamageType)
	self.IsDead = true
	self.CapsuleComponent:SetCollisionEnabled(UE4.ECollisionEnabled.NoCollision)
	self:StopFire()
	local Controller = self:GetController()
	Controller:UnPossess()
end

function BP_CharacterBase_C:Destroy(Duration)
	UE4.UKismetSystemLibrary.Delay(self, Duration)
	if self.Weapon then
		self.Weapon:K2_DestroyActor()
	end
	self:K2_DestroyActor()
end

function BP_CharacterBase_C:ChangeToRagdoll()
	self.Mesh:SetSimulatePhysics(true)
end

local yasio_update = require 'example'
local yasio_test_done = false
function BP_CharacterBase_C:ReceiveTick(dt)
	if not yasio_test_done then
        yasio_test_done = yasio_update(dt)
    end
end

return BP_CharacterBase_C
