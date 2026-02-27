# This script is an autoload, that can be accessed from any other script!

extends Node

@onready var jump_sfx = $JumpSfx
@onready var coin_pickup_sfx = $CoinPickup
@onready var death_sfx = $DeathSfx
@onready var respawn_sfx = $RespawnSfx
@onready var level_complete_sfx = $LevelCompleteSfx
@onready var achievement_sfx = $AchievementSfx
@onready var kitchen_sounds = $CutsceneSounds/KitchenSounds

@onready var intro_jess = $"CutsceneSounds/Intro - Jess"
@onready var intro_jamie = $"CutsceneSounds/Intro - Jamie"
@onready var outro_jess = $"CutsceneSounds/Outro - Jess"
@onready var outro_jamie = $"CutsceneSounds/Outro - Jamie"
@onready var completion_thanks = $"CutsceneSounds/Completion - Thank You So Much"
@onready var completion_jess = $"CutsceneSounds/Completion - Jess"
@onready var completion_jamie = $"CutsceneSounds/Completion - Jamie"
@onready var credits = $"CutsceneSounds/Credits - Mimi"
