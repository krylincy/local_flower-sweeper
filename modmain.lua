
AddPrefabPostInit("reskin_tool", function(inst) 
	if inst.components ~= nil and inst.components.spellcaster ~= nil then
		-- save old functions to just extend them
		local oldSpellFunction = inst.components.spellcaster.spell			
		local oldTestSpellFunction = inst.components.spellcaster.can_cast_fn	

		local function puffEffect(target, scale)
			local fx = GLOBAL.SpawnPrefab("explode_reskin")
			fx.Transform:SetScale(scale, scale, scale)

			local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
			fx.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z) 
		end
		
		function inPrefabList(tbl, item)
			for key, value in pairs(tbl) do
				if value == item then return true end
			end
			return false
		end

		local function can_cast_fn(doer, target, pos)	
			-- if it is a flower, return true, else return whatever the default function would return
			-- print('###target ', target, target.prefab)
			local isModPrefabBerrybush = GetModConfigData("changeBerrybushes") > 0 and (target.prefab == "berrybush" or target.prefab == "berrybush2" or target.prefab == "berrybush_juicy")
			local isModPrefabTwiggy = GetModConfigData("changeTwiggy") == 1 and (target.prefab == "twiggytree" or target.prefab == "sapling")
			local validModPrefab = {"flower", "flower_evil", "succulent_plant", "succulent_potted", "cave_fern", "pottedfern", "marbleshrub"}
	
			if isModPrefabBerrybush then
				-- it is a berrybush and not barren or any
				local isCastOnEmptyPrefab = GetModConfigData("changeBerrybushes") == 1  and not target.components.pickable:CanBePicked()	
				-- if you wanna change only the style, the cast on juicy is not allowed
				local juciyNotAllowed = GetModConfigData("changeBerrybushesType") == 0 and target.prefab == "berrybush_juicy"								
			
				return not juciyNotAllowed and not isCastOnEmptyPrefab
			elseif inPrefabList(validModPrefab, target.prefab) or isModPrefabTwiggy then
				-- it is a valid mod prefab
				return true
			else
				-- it is something default
				return oldTestSpellFunction(doer, target, pos)
			end			
		end
		
		local function spellCB(tool, target, pos)	
			-- if there is no target, set empty string to compare
			local targetPrefabName = target ~= nil and target.prefab or ""
			if targetPrefabName == "flower" then
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
						target:RemoveTag("thorny")
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
				puffEffect(target, 1)
				
				-- change flower skin as in the flower "setflowertype" function
				target.animname = nextAnimName
				target.AnimState:PlayAnimation(target.animname)
								
				if target.animname == ROSE_NAME then
					target:AddTag("thorny")
				end
			elseif targetPrefabName == "flower_evil" then
				local currentAnimName = target.animname	  
				
				if GetModConfigData("randomSelection") == 1 then
					nextAnimName = "f" .. tostring(math.random(8))
				else
					if  currentAnimName == "f8" then
						-- start from beginning
						nextAnimName = "f1"
					else
						-- extract the number (string position 2 to 3), increment and add the pre "f"						
						nextAnimName = "f"..(math.floor(string.sub(currentAnimName, 2, 3) + 1))					
					end				
				end

				-- the puff effect
				puffEffect(target, 1)
				
				-- change flower skin as in the default function
				target.animname = nextAnimName
				target.AnimState:PlayAnimation(target.animname)
			elseif targetPrefabName == "succulent_plant" or targetPrefabName == "succulent_potted" then				
				local currentAnimName = target.plantid
				
				-- differ the plant vs the potted version
				local prefabName = "succulent"
				local symbolName = "Symbol_1"
				local symbolPrefix = "Symbol_"
				
				if target.prefab == "succulent_potted" then
					prefabName = "succulent_potted"
					symbolName = "succulent"
					symbolPrefix = "succulent"
				end
    
				
				if GetModConfigData("randomSelection") == 1 then
					target.plantid = math.random(5)
				else
					if target.plantid == 5 then
						-- start from beginning
						target.plantid = 1
					else			
						target.plantid = target.plantid + 1			
					end				
				end

				-- the puff effect
				puffEffect(target, 1)
				
				-- change flower skin as in the default function
				if target.plantid == 1 then
					target.AnimState:ClearOverrideSymbol(symbolName)
				else
					target.AnimState:OverrideSymbol(symbolName, prefabName, symbolPrefix..tostring(target.plantid))
				end	
			elseif targetPrefabName == "cave_fern" or targetPrefabName == "pottedfern" then				
				local currentAnimName = target.animname	  
				
				if GetModConfigData("randomSelection") == 1 then
					nextAnimName = "f" .. tostring(math.random(10))
				else
					if  currentAnimName == "f10" then
						-- start from beginning
						nextAnimName = "f1"
					else
						-- extract the number (string position 2 to 3), increment and add the pre "f"						
						nextAnimName = "f"..(math.floor(string.sub(currentAnimName, 2, 3) + 1))					
					end				
				end

				-- the puff effect
				puffEffect(target, 1)
				
				-- change flower skin as in the default function
				target.animname = nextAnimName
				target.AnimState:PlayAnimation(target.animname)
			elseif targetPrefabName == "berrybush" or targetPrefabName == "berrybush2" or targetPrefabName == "berrybush_juicy" then
				local nextPrefab = "berrybush"
				local changeType = GetModConfigData("changeBerrybushesType")
				
				if target.prefab == "berrybush" then
					nextPrefab = "berrybush2"
				elseif target.prefab == "berrybush2" then
					if changeType == 0 then
						-- if you only change type, go back to berrybush
						nextPrefab = "berrybush"
					else
						-- if you rotate through go to juicy
						nextPrefab = "berrybush_juicy"
					end				
				elseif target.prefab == "berrybush_juicy" then
					nextPrefab = "berrybush"
				end
								
				-- the puff effect
				puffEffect(target, 1.4)				
				
				-- add new bush at the old position
				local newBush = GLOBAL.SpawnPrefab(nextPrefab)
				local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
				
				newBush.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z) 
				
				-- remove old bush
				target:Remove()
			elseif targetPrefabName == "sapling" then								
				-- the puff effect
				puffEffect(target, 1.4)				
				
				-- add new tree at the old position
				local newTree = GLOBAL.SpawnPrefab("twiggytree")
				local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
				
				newTree.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z) 
				
				-- remove old bush
				target:Remove()				
				
			elseif targetPrefabName == "twiggytree" then								
				-- the puff effect
				puffEffect(target, 1.8)				
				
				-- add new tree at the old position
				local newTree = GLOBAL.SpawnPrefab("sapling")
				local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
				
				newTree.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z) 
				
				-- remove old bush
				target:Remove()			
			elseif targetPrefabName == "marbleshrub" then				
				-- the puff effect
				puffEffect(target, 1.8)
								
				local currentShapeNumber = target.shapenumber
				-- returns 1, 2 or 3
				local newShapeNumber = (currentShapeNumber + 1) < 4 and currentShapeNumber + 1 or 1

				-- randominze the color again
				local color = .5 + math.random() * .5
				target.AnimState:SetMultColour(color, color, color, 1)	
				
				if newShapeNumber == 1 then
					target.AnimState:ClearOverrideSymbol("marbleshrub_top1")
				else
					target.AnimState:OverrideSymbol("marbleshrub_top1", "marbleshrub_build", "marbleshrub_top"..newShapeNumber)
				end			
				
				target.MiniMapEntity:SetIcon("marbleshrub"..newShapeNumber..".png")
				target.shapenumber = newShapeNumber				
			else
				-- do default stuff
				oldSpellFunction(tool, target, pos)
			end				
		end	
		
		inst.components.spellcaster:SetSpellFn(spellCB)
		inst.components.spellcaster:SetCanCastFn(can_cast_fn)
	end

end)
