-- define what prefab are valid to sweep
local validModPrefab = { "flower", "flower_evil", "succulent_plant", "succulent_potted", "cave_fern", "pottedfern", "marbleshrub", "deciduoustree", "carnivaldecor_lamp", "carnivaldecor_plant", "carnivaldecor_figure", "carnivaldecor_figure_season2", "singingshell_octave3", "singingshell_octave4", "singingshell_octave5", "cactus", "oasis_cactus" }

-- Potted Plants (DST) 1311366056
if GetModConfigData("pottedPlantsMod") == 1 then
	table.insert(validModPrefab, "pottedbluemushroom")
	table.insert(validModPrefab, "pottedcactus")
	table.insert(validModPrefab, "pottedevilflower")
	table.insert(validModPrefab, "pottedflower")
	table.insert(validModPrefab, "pottedgreenmushroom")
	table.insert(validModPrefab, "pottedredmushroom")
	table.insert(validModPrefab, "pottedrose")
end

-- mod configuration prefabs
if GetModConfigData("changeEvergreens") == 1 then
	table.insert(validModPrefab, "evergreen")
	table.insert(validModPrefab, "evergreen_sparse")
end

if GetModConfigData("changeReeds") == 1 then
	table.insert(validModPrefab, "reeds")
	table.insert(validModPrefab, "grass")
end

if GetModConfigData("changeMushrooms") == 1 then
	table.insert(validModPrefab, "red_mushroom")
	table.insert(validModPrefab, "green_mushroom")
	table.insert(validModPrefab, "blue_mushroom")
	table.insert(validModPrefab, "mushtree_medium")
	table.insert(validModPrefab, "mushtree_small")
	table.insert(validModPrefab, "mushtree_tall")
end

AddPrefabPostInit("reskin_tool", function(inst)
	if inst.components ~= nil and inst.components.spellcaster ~= nil then
		-- save old functions to just extend them
		local oldSpellFunction = inst.components.spellcaster.spell
		local oldTestSpellFunction = inst.components.spellcaster.can_cast_fn

		local function puffEffect(tool, target, scale)
			--local fx = GLOBAL.SpawnPrefab("explode_reskin")

			local fx_prefab = "explode_reskin"
			local skin_fx = GLOBAL.SKIN_FX_PREFAB[tool:GetSkinName()]
			if skin_fx ~= nil and skin_fx[1] ~= nil then
				fx_prefab = skin_fx[1]
			end

			local fx = GLOBAL.SpawnPrefab(fx_prefab)
			fx.Transform:SetScale(scale, scale, scale)

			local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
			fx.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z)
		end

		local function inPrefabList(tbl, item)
			for key, value in pairs(tbl) do
				if value == item then return true end
			end
			return false
		end

		local function can_cast_fn(doer, target, pos)
			local isModPrefabBerrybush = GetModConfigData("changeBerrybushes") > 0 and (target.prefab == "berrybush" or target.prefab == "berrybush2" or target.prefab == "berrybush_juicy")
			local isModPrefabTwiggy = GetModConfigData("changeTwiggy") == 1 and (target.prefab == "twiggytree" or target.prefab == "sapling")

			if isModPrefabBerrybush then
				-- it is a berrybush and not barren or any
				local isCastOnEmptyPrefab = GetModConfigData("changeBerrybushes") == 1 and not target.components.pickable:CanBePicked()
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
			local function replacePrefab(fromPrefab, toPrefab, size)
				puffEffect(tool, fromPrefab, size)

				-- add new tree at the old position
				local newPrefab = GLOBAL.SpawnPrefab(toPrefab)
				local fx_pos_x, fx_pos_y, fx_pos_z = fromPrefab.Transform:GetWorldPosition()

				newPrefab.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z)

				-- remove old tree
				fromPrefab:Remove()

				return newPrefab
			end

			-- Potted Plants (DST) 1311366056
			local function changePottedPlants(prefix, maxVariation)
				local currentAnimName = target.animname
				local nextAnimName = prefix .. tostring(math.random(maxVariation))
				local prefixLength = string.len(prefix)

				if GetModConfigData("randomSelection") ~= 1 then
					if currentAnimName == prefix .. tostring(maxVariation) then
						-- start from beginning
						nextAnimName = prefix .. "1"
					else
						-- extract the number (string position after prefix), increment and add the following prefix number (+1)
						local minPosition = prefixLength + 1
						local maxPosition = prefixLength + 2
						nextAnimName = prefix .. (math.floor(string.sub(currentAnimName, minPosition, maxPosition) + 1))
					end
				end

				puffEffect(tool, target, 1)

				target.animname = nextAnimName
				target.AnimState:PlayAnimation(target.animname)
			end

			-- if there is no target, set empty string to compare
			local targetPrefabName = target ~= nil and target.prefab or ""
			-- print("targetPrefabName"..targetPrefabName)
			if targetPrefabName == "flower" then
				local names = { "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10" }
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
					elseif currentAnimName == "f10" then
						-- add the rose as last flower
						nextAnimName = ROSE_NAME
					else
						-- extract the number (string position 2 to 3), increment and add the pre "f"
						nextAnimName = "f" .. (math.floor(string.sub(currentAnimName, 2, 3) + 1))
					end
				end

				puffEffect(tool, target, 1)

				-- change flower skin as in the flower "setflowertype" function
				target.animname = nextAnimName
				target.AnimState:PlayAnimation(target.animname)

				if target.animname == ROSE_NAME then
					target:AddTag("thorny")
				end
			elseif targetPrefabName == "flower_evil" then
				local currentAnimName = target.animname
				local nextAnimName = "f" .. tostring(math.random(8))

				if GetModConfigData("randomSelection") ~= 1 then
					if currentAnimName == "f8" then
						-- start from beginning
						nextAnimName = "f1"
					else
						-- extract the number (string position 2 to 3), increment and add the pre "f"
						nextAnimName = "f" .. (math.floor(string.sub(currentAnimName, 2, 3) + 1))
					end
				end

				puffEffect(tool, target, 1)

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

				puffEffect(tool, target, 1)

				-- change flower skin as in the default function
				if target.plantid == 1 then
					target.AnimState:ClearOverrideSymbol(symbolName)
				else
					target.AnimState:OverrideSymbol(symbolName, prefabName, symbolPrefix .. tostring(target.plantid))
				end
			elseif targetPrefabName == "cave_fern" or targetPrefabName == "pottedfern" then
				local currentAnimName = target.animname
				local nextAnimName = "f" .. tostring(math.random(10))

				if GetModConfigData("randomSelection") ~= 1 then
					if currentAnimName == "f10" then
						-- start from beginning
						nextAnimName = "f1"
					else
						-- extract the number (string position 2 to 3), increment and add the pre "f"
						nextAnimName = "f" .. (math.floor(string.sub(currentAnimName, 2, 3) + 1))
					end
				end

				puffEffect(tool, target, 1)
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

				replacePrefab(target, nextPrefab, 1.4)
			elseif targetPrefabName == "marbleshrub" then
				puffEffect(tool, target, 1.8)

				local currentShapeNumber = target.shapenumber
				-- returns 1, 2 or 3
				local newShapeNumber = (currentShapeNumber + 1) < 4 and currentShapeNumber + 1 or 1

				-- randominze the color again
				local color = .5 + math.random() * .5
				target.AnimState:SetMultColour(color, color, color, 1)

				if newShapeNumber == 1 then
					target.AnimState:ClearOverrideSymbol("marbleshrub_top1")
				else
					target.AnimState:OverrideSymbol("marbleshrub_top1", "marbleshrub_build", "marbleshrub_top" .. newShapeNumber)
				end

				target.MiniMapEntity:SetIcon("marbleshrub" .. newShapeNumber .. ".png")
				target.shapenumber = newShapeNumber
			elseif targetPrefabName == "evergreen" or targetPrefabName == "evergreen_sparse" then
				if not target:HasTag("stump") then
					local newPrefabName = targetPrefabName == "evergreen_sparse" and "evergreen" or "evergreen_sparse"
					local stage = 0

					if target.components ~= nil and target.components.growable then
						stage = target.components.growable.stage
					end

					local newPrefab = replacePrefab(target, newPrefabName, 1.8)
					newPrefab.components.growable.stage = stage
				end
			elseif targetPrefabName == "deciduoustree" then
				puffEffect(tool, target, 1.8)
				if target.leaf_state == "colorful" then
					target.build = ({ "red", "orange", "yellow" })[math.random(3)]
					target.AnimState:SetMultColour(1, 1, 1, 1)
					target.AnimState:OverrideSymbol("swap_leaves", "tree_leaf_" .. target.build .. "_build", "swap_leaves")
				else
					target.color = .5 + math.random() * .5
					target.AnimState:SetMultColour(target.color, target.color, target.color, 1)
				end
			elseif targetPrefabName == "carnivaldecor_lamp" then
				local NUM_SHAPES = 6
				puffEffect(tool, target, 1.4)

				local currentShape = target.shape
				target.shape = math.random(NUM_SHAPES)

				if GetModConfigData("randomSelection") ~= 1 then
					if currentShape >= NUM_SHAPES then
						-- start from beginning
						target.shape = 1
					else
						target.shape = currentShape + 1
					end
				end

				target.AnimState:PlayAnimation("idle" .. target.shape .. "_off")

				target.Light:Enable(false)

				if target.components.activatable ~= nil then
					target.components.activatable.inactive = true
				end

				target.turnofftask = nil
			elseif targetPrefabName == "carnivaldecor_plant" then
				puffEffect(tool, target, 1.4)

				local currentShape = target.shape
				target.shape = math.random(3)

				if GetModConfigData("randomSelection") ~= 1 then
					if currentShape == 3 then
						-- start from beginning
						target.shape = 1
					else
						target.shape = currentShape + 1
					end
				end

				target.AnimState:PlayAnimation("idle_" .. tostring(target.shape), true)
			elseif targetPrefabName == "carnivaldecor_figure" or targetPrefabName == "carnivaldecor_figure_season2" then

				-- defaults for carnivaldecor_figure (season 1)
				local shape_rarity = {
					s1 = "rare",
					s2 = "uncommon",
					s3 = "uncommon",
					s4 = "common",
					s5 = "common",
					s6 = "common",
					s7 = "uncommon",
					s8 = "common",
					s9 = "common",
					s10 = "common",
					s11 = "common",
					s12 = "common",
				}

				if targetPrefabName == "carnivaldecor_figure_season2" then
					-- season 2
					shape_rarity = {
						s1 = "rare",
						s2 = "uncommon",
						s3 = "uncommon",
						s4 = "common",
						s5 = "common",
						s6 = "common",
						s7 = "uncommon",
						s8 = "common",
						s9 = "common",
						s10 = "common",
						s11 = "common",
						s12 = "common",
					}
				end

				local rarity_decor_vale_map = {
					rare     = 20,
					uncommon = 16,
					common   = 12,
				}

				puffEffect(tool, target, 1.2)

				local defaultShape = "s" .. 0
				local currentShape = target.shape or defaultShape
				local newShape = "s" .. math.random(12)

				if GetModConfigData("randomSelection") ~= 1 then
					if currentShape == "s12" then
						-- start from beginning
						newShape = "s" .. 1
					else
						-- extract the number (string position after prefix), increment and add the following prefix number (+1)
						local minPosition = 2
						local maxPosition = 3
						newShape = 's' .. (math.floor(string.sub(currentShape, minPosition, maxPosition) + 1))
					end
				end

				if target.shape ~= nil then
					target:RemoveTag("blindbox_" .. tostring(shape_rarity[target.shape]))
				end

				target.shape = newShape
				target.components.carnivaldecor.value = rarity_decor_vale_map[shape_rarity[newShape]]
				target:AddTag("blindbox_" .. tostring(shape_rarity[newShape]))

				target.AnimState:PlayAnimation(tostring(newShape))
			elseif targetPrefabName == "singingshell_octave3" or targetPrefabName == "singingshell_octave4" or targetPrefabName == "singingshell_octave5" then
				puffEffect(tool, target, 1)

				-- eg. "ocatave3"
				local octave_str = targetPrefabName:sub(-7)
				local currentVariation = target._variation

				target._variation = math.random(3)
				if GetModConfigData("randomSelection") ~= 1 then
					if currentVariation == 3 then
						-- start from beginning
						target._variation = 1
					else
						target._variation = currentVariation + 1
					end
				end
				target.AnimState:OverrideSymbol("shell_placeholder", "singingshell", octave_str .. "_" .. target._variation)
				target.components.inventoryitem:ChangeImageName("singingshell_" .. octave_str .. "_" .. target._variation)
			elseif targetPrefabName == "red_mushroom" or targetPrefabName == "green_mushroom" or targetPrefabName == "blue_mushroom" then

				local prefab = "mushtree_medium" -- red
				if targetPrefabName == "green_mushroom" then prefab = "mushtree_small" end
				if targetPrefabName == "blue_mushroom" then prefab = "mushtree_tall" end

				replacePrefab(target, prefab, 1.6)
			elseif targetPrefabName == "mushtree_medium" or targetPrefabName == "mushtree_small" or targetPrefabName == "mushtree_tall" then

				local prefab = "red_mushroom"
				if targetPrefabName == "mushtree_small" then prefab = "green_mushroom" end
				if targetPrefabName == "mushtree_tall" then prefab = "blue_mushroom" end

				replacePrefab(target, prefab, 1)
			elseif targetPrefabName == "pottedbluemushroom" then
				changePottedPlants("bm", 3)
			elseif targetPrefabName == "pottedcactus" then
				changePottedPlants("c", 5)
			elseif targetPrefabName == "pottedevilflower" then
				changePottedPlants("ef", 8)
			elseif targetPrefabName == "pottedflower" then
				changePottedPlants("pf", 9)
			elseif targetPrefabName == "pottedflower" then
				changePottedPlants("pf", 9)
			elseif targetPrefabName == "pottedgreenmushroom" then
				changePottedPlants("gm", 3)
			elseif targetPrefabName == "pottedredmushroom" then
				changePottedPlants("rm", 3)
			elseif targetPrefabName == "pottedrose" then
				changePottedPlants("pr", 7)
			elseif targetPrefabName == "reeds" then
				replacePrefab(target, "grass", 1.4)
			elseif targetPrefabName == "grass" then
				replacePrefab(target, "reeds", 1.4)
			elseif targetPrefabName == "cactus" then
				replacePrefab(target, "oasis_cactus", 1.4)
			elseif targetPrefabName == "oasis_cactus" then
				replacePrefab(target, "cactus", 1.4)
			elseif targetPrefabName == "sapling" then
				replacePrefab(target, "twiggytree", 1.4)
			elseif targetPrefabName == "twiggytree" then
				replacePrefab(target, "sapling", 1.8)
			else
				-- do default stuff
				oldSpellFunction(tool, target, pos)
			end
		end

		inst.components.spellcaster:SetSpellFn(spellCB)
		inst.components.spellcaster:SetCanCastFn(can_cast_fn)
	end

end)
