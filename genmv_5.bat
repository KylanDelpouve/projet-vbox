@echo off
set RAM=4096
set HDD=65536

:: Structure if pour gerer le premier argument (%1) tape par l'utilisateur
if "%1" == "" goto erreur_arg
if "%1" == "L" goto lister
if "%1" == "N" goto nouvelle
if "%1" == "S" goto supprimer
if "%1" == "D" goto demarrer
if "%1" == "A" goto arreter

:erreur_arg
echo Erreur : Argument manquant ou invalide.
echo Syntaxe : genmv_4.bat [L|N|S|D|A] [nom_machine]
goto :eof

:lister
echo Liste des machines et metadonnees :
:: Redirection de la liste vers un fichier texte
VBoxManage list vms > liste.txt
:: Parsing du fichier pour extraire le premier champ (nom)
FOR /F %%a in (liste.txt) do call :afficher_details %%a
:: Nettoyage du fichier temporaire
del liste.txt
goto :eof

:afficher_details
:: %1 contient le nom de la machine recupere par la boucle
echo.
echo Machine : %1
VBoxManage getextradata %1 "Createur"
VBoxManage getextradata %1 "DateCreation"
goto :eof

:nouvelle
:: On verifie qu'on a bien donne un nom de machine en deuxieme argument (%2)
if "%2" == "" goto erreur_arg
set NOM=%2
:: On teste si la machine existe
VBoxManage showvminfo "%NOM%" >nul 2>&1
:: Le ERRORLEVEL 1 veut dire que la commande a echoue (donc la machine n'existe pas)
if ERRORLEVEL 1 goto creation
:: Si on arrive ici, c'est que la machine existe deja. On la supprime
echo La machine %NOM% existe deja. Suppression en cours...
VBoxManage unregistervm "%NOM%" --delete

:creation
echo Creation de la machine %NOM%...
VBoxManage createvm --name "%NOM%" --ostype "Debian_64" --register
VBoxManage modifyvm "%NOM%" --memory %RAM% --nic1 nat
:: modification de l'ordre de demarrage pour mettre le reseau net en premier
VBoxManage modifyvm "%NOM%" --boot1 net --boot2 disk --boot3 none --boot4 none
:: Configuration du serveur TFTP pour la carte reseau 1 (qui est en NAT)
VBoxManage modifyvm "%NOM%" --nattftpprefix1 "%~dp0TFTP\debian-installer\amd64"
VBoxManage modifyvm "%NOM%" --nattftpfile1 "pxelinux.0"
VBoxManage createmedium disk --filename "%NOM%.vdi" --size %HDD%
VBoxManage storagectl "%NOM%" --name "SATA" --add sata
VBoxManage storageattach "%NOM%" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "%NOM%.vdi"

:: Ajout des metadonnees
VBoxManage setextradata "%NOM%" "Createur" "%USERNAME%"
VBoxManage setextradata "%NOM%" "DateCreation" "%DATE% %TIME%"

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
goto :eof

:arreter
if "%2" == "" goto erreur_arg
set NOM=%2
echo Arret de la machine %NOM%...
VBoxManage controlvm "%NOM%" poweroff
goto :eof