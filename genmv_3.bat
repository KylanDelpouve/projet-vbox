@echo off
set RAM=4096
set HDD=65536

if "%1" == "" goto erreur_arg
if "%1" == "L" goto lister
if "%1" == "N" goto nouvelle
if "%1" == "S" goto supprimer
if "%1" == "D" goto demarrer
if "%1" == "A" goto arreter

:erreur_arg
echo Erreur : Argument manquant ou invalide.
echo Syntaxe : genmv_3.bat [L|N|S|D|A] [nom_machine]
goto :eof

:lister
echo Liste des machines enregistrees :
VBoxManage list vms
goto :eof

:nouvelle
if "%2" == "" goto erreur_arg
set NOM=%2
VBoxManage showvminfo "%NOM%" >nul 2>&1
if ERRORLEVEL 1 goto creation
echo La machine %NOM% existe deja. Suppression en cours...
VBoxManage unregistervm "%NOM%" --delete

:creation
echo Creation de la machine %NOM% (%RAM% Mo RAM, %HDD% Mo HDD)...
VBoxManage createvm --name "%NOM%" --ostype "Debian_64" --register
VBoxManage modifyvm "%NOM%" --memory %RAM% --nic1 nat
VBoxManage createmedium disk --filename "%NOM%.vdi" --size %HDD%
VBoxManage storagectl "%NOM%" --name "SATA" --add sata
VBoxManage storageattach "%NOM%" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "%NOM%.vdi"
echo Machine %NOM% creee avec succes.
goto :eof

:supprimer
if "%2" == "" goto erreur_arg
set NOM=%2
echo Suppression de la machine %NOM%...
VBoxManage unregistervm "%NOM%" --delete
goto :eof

:demarrer
if "%2" == "" goto erreur_arg
set NOM=%2
echo Demarrage de la machine %NOM%...
VBoxManage startvm "%NOM%"
if ERRORLEVEL 1 goto erreur_demarrage
goto :eof

:erreur_demarrage
echo Echec du demarrage de la VM %NOM%.
goto :eof

:arreter
if "%2" == "" goto erreur_arg
set NOM=%2
echo Arret brutal de la machine %NOM%...
VBoxManage controlvm "%NOM%" poweroff
goto :eof