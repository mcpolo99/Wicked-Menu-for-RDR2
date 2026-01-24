
# converting json list to lua table

## access to lua table

examples:

local p = Path([[G:\Cheats\Tables\Wicked-Menu-for-RDR2\Array]]) /"MapData_Array.lua"
local p2 = Path([[G:\Cheats\Tables\Wicked-Menu-for-RDR2\]]) /"MapData_Array.lua"
Path.exportLua(p,p2)










## For preparing "item-cordinates-in-game.json" to be run in lua

^(\s*)([A-Za-z_]*)


^(\s*)([A-Za-z][A-Za-z ]*[A-Za-z])\s*=
\1["\2"] =


^(\s*)([A-Za-z0-9_ ]+?)=\s*\{
\1["\2"] = {

Rename:
(\w+)_Tarot_Card
document_card_\1

convert uppercase to lower case:
document_card_([A-Z_]+)
document_card_\L\1

replace space between to letters with _ :
([A-Za-z])\s([A-Za-z])
\1_\2


## format finished one

,\s*\r?\n\s*([A-Za-z0-9_"]+)
, \1


(\S)\s*\r?\n\s*\},\s\s

\1 },\n

(\{)\s*\n\t*\s*(\w)

\1 \2