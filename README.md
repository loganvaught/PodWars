# PodWars
My current project on the Roblox platform.

PodWars is a competitive multiplayer survival experience that relies on defensive tactics. 
This project has served as a tool for me to experiment with:
- Debugging
- System design
- Modularity
- Organization
- Server-client communication and security
- Knowledge of time and space complexity

## Main Current Features:
- Object oriented inventory and crafting with server enforcement
- Hotbar and dragging logic
- Combat system with cooldowns, raycasting, and hit detection
- Lobby/round based system with starting delay

## To be Added:
- Explosions and hit detection
- Weapon ammunition/reloading
- Hunger/thirst/energy
- Skin shop and equip system
- After-death spectating

## Folder Structure:
- Lobby: The main experience players first join through. Facilitates teleportation to the battlefield.
- Battlefield: The main location where players play a round of PodWars.
- Client: Scripts ran by the client
- ClientModules: ModuleScripts ran by the client
- Server: Scripts ran by the server
- ServerModules: ModuleScripts ran by the server
- SharedModules: ModuleScripts shared between the server and client.

# Notes:
- Roblox provides a 3d workspace with humanoid/character logic. There are built in services to facilitate physics, graphics, saving data, object property manipulation, etc.
- Code readability and organization of this repository are being worked on. This version represents a working prototype. It is a solo project originally designed for me to best understand.
- PodWars was originally made for personal growth, entertainment, and for friends. It is not intended for commercial use.
