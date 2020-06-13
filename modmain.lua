
AddPrefabPostInit("reskin_tool", function(inst) 
	if inst.components ~= nil and inst.components.spellcaster ~= nil then
		-- save old functions to just extend them
		local oldSpellFunction = inst.components.spellcaster.spell			
		local oldTestSpellFunction = inst.components.spellcaster.can_cast_fn			
		
		
		local function can_cast_fn(doer, target, pos)	
			-- if it is a flower, return true, else return whatever the default function would return
			return target.prefab == "flower" or oldTestSpellFunction(doer, target, pos)
		end
		
		local function spellCB(tool, target, pos)					
			if target.prefab == "flower" then
				local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10"}
				local ROSE_NAME = "rose"
				local ROSE_CHANCE = GetModConfigData("rosePercent")		
				
				local nextAnimName				
				local currentAnimName = target.animname
				
				if GetModConfigData("randomSelection") == 1 then
					nextAnimName = math.random() < ROSE_CHANCE and ROSE_NAME or names[math.random(#names)]
				else
					if currentAnimName == ROSE_NAME then
						-- start from the beginning
						nextAnimName = "f1"
					elseif  currentAnimName == "f10" then
						-- add the rose as last flower
						nextAnimName = ROSE_NAME
					else
						-- extract the number (string position 2 to 3), increment and add the pre "f"						
						nextAnimName = "f"..(math.floor(string.sub(currentAnimName, 2, 3) + 1))					
					end
				
				end

				-- the puff effect
				local fx = GLOBAL.SpawnPrefab("explode_reskin")
				fx.Transform:SetScale(1, 1, 1)

				local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
				fx.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z) 
				
				-- change flower skin as in the flower "setflowertype" function
				target.animname = nextAnimName
				target.AnimState:PlayAnimation(target.animname)
				if target.animname == ROSE_NAME then
					target:AddTag("thorny")
				end		
			else
				-- do default stuff
				oldSpellFunction(tool, target, pos)
			end				
		end	
		
		inst.components.spellcaster:SetSpellFn(spellCB)
		inst.components.spellcaster:SetCanCastFn(can_cast_fn)
	end

end)
