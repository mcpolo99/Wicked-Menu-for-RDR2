

# build CE 7.5 for speed hack to work 




install all required packages. 

Download Lazarus 2.2.2 from https://sourceforge.net/projects/lazarus/files/Lazarus%20Windows%2064%20bits/Lazarus%202.2.2/ 
First install lazarus-2.2.2-fpc-3.2.2-win64.exe and then lazarus-2.2.2-fpc-3.2.2-cross-i386-win32-win64.exe

build tools 2013 https://www.microsoft.com/en-us/download/details.aspx?id=40760
https://community.chocolatey.org/packages?q=build%20tools%20for%20Visual%20Studio%202013
choco install vcbuildtools

build tools 2017 https://stackoverflow.com/questions/57795314/are-visual-studio-2017-build-tools-still-available-for-download
install with additional support for  v141_xp c ++


sdk 8.1 https://learn.microsoft.com/en-us/windows/apps/windows-sdk/downloads-archive
Windows 10 SDK, version 1809 (10.0.17763.0) https://learn.microsoft.com/en-us/windows/apps/windows-sdk/downloads-archive



require 2013 tool set 
msbuild "Cheat Engine/Direct x mess/Direct x mess.sln" /p:Configuration=Release /p:Platform=Win32
msbuild "Cheat Engine/Direct x mess/Direct x mess.sln" /p:Configuration=Release /p:Platform=x64

C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\IDE\VC\VCTargets\Platforms\x64\PlatformToolsets\v141_xp
msbuild "Cheat Engine/MonoDataCollector/MonoDataCollector.sln" /p:Configuration=Release /p:Platform=Win32
msbuild "Cheat Engine/MonoDataCollector/MonoDataCollector.sln" /p:Configuration=Release /p:Platform=x64


C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\
msbuild "Cheat Engine/DotNetDataCollector/DotNetDataCollector.sln" /p:Configuration=Release /p:Platform=Win32
msbuild "Cheat Engine/DotNetDataCollector/DotNetDataCollector.sln" /p:Configuration=Release /p:Platform=x64


download nuget.exe https://www.nuget.org/downloads
 .\nuget.exe restore "Cheat Engine/DotNetInvasiveDataCollector/DotNetInvasiveDataCollector.sln"

msbuild "Cheat Engine/DotNetInvasiveDataCollector/DotNetInvasiveDataCollector.sln" /p:Configuration=Release




need something with java did not care. 
msbuild "Cheat Engine/Java/CEJVMTI/CEJVMTI.sln" /p:Configuration=Release /p:Platform=Win32
msbuild "Cheat Engine/Java/CEJVMTI/CEJVMTI.sln" /p:Configuration=Release /p:Platform=x64

i think this worked atleast . 
msbuild "Cheat Engine/tcclib/win32/tcc/tcc.sln"  /p:Configuration="Output to 64 (Release)" /p:Platform=Win32
msbuild "Cheat Engine/tcclib/win32/tcc/tcc.sln"  /p:Configuration="Output to 32 (Release)" /p:Platform=Win32
msbuild "Cheat Engine/tcclib/win32/tcc/tcc.sln"  /p:Configuration="Output to 64 (Release)" /p:Platform=x64
msbuild "Cheat Engine/tcclib/win32/tcc/tcc.sln"  /p:Configuration="Output to 32 (Release)" /p:Platform=x64


all files collected in  Cheat Engine\bin



https://www.unknowncheats.me/forum/anti-cheat-bypass/504191-undetected-cheat-engine-driver-2022-bypass-anticheats-eac.html




*.ddp  *.pas *.lrt *.lpr *.lpi *.lfm

















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