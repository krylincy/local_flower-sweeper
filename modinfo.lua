name = "Clean Sweeper Expanded"
version = "6"
description = [[
You can change the appearances/type for more prefabs with the Clean Sweeper. 

This includes by default: 
Flowers, Evil Flowers, Ferns, Potted Fern, Succulents, Potted Succulent, Marble Shrub (all stages) and Birchnut Trees. 

Optional (default off): 
+ Evergreen <=> Lumpy Evergreen
+ Grass <=> Reeds
+ Sapling <=> Twiggy Tree
+ Berrybushes (Types with configuration options) 

Version: ]]..version
author = "krylincy"
api_version = 10
forumthread = ""
icon_atlas = "preview-flower.xml"
icon = "preview-flower.tex"
dst_compatible = true
client_only_mod = false
all_clients_require_mod = true

configuration_options = {
	{
		name = "randomSelection",
		label = "Flower Selection",
        hover = "How to find next flowertype. When 'sequence' is choosen the 'Rose Chance' is irrelevant.",
		options = {
			{description = "Sequence", data = 0},
			{description = "Random", data = 1},
		},
		default = 0,
	},
	{
		name = "rosePercent",
		label = "Rose Chance",
        hover = "The chance to spawn a rose instead of regular flower. Game default is 1%. Only relevant with 'Random Selection'.",
		options = {
			{description = "1%", data = 0.01},
			{description = "2%", data = 0.02},
			{description = "3%", data = 0.03},
			{description = "4%", data = 0.04},
			{description = "5%", data = 0.05},
			{description = "6%", data = 0.06},
			{description = "7%", data = 0.07},
			{description = "8%", data = 0.08},
			{description = "9%", data = 0.09},
			{description = "10%", data = 0.1},
		},
		default = 0.01,
	},
	{
		name = "changeEvergreens",
		label = "Sweep Evergreen",
        hover = "Change from Evergreen to Lumpy Evergreen and vice versa.",
		options = {
			{description = "No", data = 0},
			{description = "Yes", data = 1},
		},
		default = 0,
	},
	{
		name = "changeReeds",
		label = "Reeds and Grass",
        hover = "Change from Reeds to Grass and vice versa.",
		options = {
			{description = "No", data = 0},
			{description = "Yes", data = 1},
		},
		default = 0,
	},
	{
		name = "changeTwiggy",
		label = "Sweep Sapling",
        hover = "Change from Sapling to Twiggy Tree and vice versa.",
		options = {
			{description = "No", data = 0},
			{description = "Yes", data = 1},
		},
		default = 0,
	},
	{
		name = "changeBerrybushes",
		label = "Sweep Berrybushes",
        hover = "Allow changing Berrybushes (select details in 'Berrybushes Types'). Choose 'not empty' to avoid cheaty changing empty/barren Berrybush to full one.",
		options = {
			{description = "No", data = 0},
			{description = "Yes, not empty", data = 1},
			{description = "Yes, any", data = 2},
		},
		default = 0,
	},
	{
		name = "changeBerrybushesType",
		label = "Berrybushes Type",
        hover = "'Stlye only' means you only change Berrybush into the Leavy form. 'Style and Type' allows you to change the Juicy Berrybush, too.",
		options = {
			{description = "Style only", data = 0},
			{description = "Style & Type", data = 1},
		},
		default = 0,
	},
}
