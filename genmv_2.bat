@echo off

echo Verification de l'existence de la machine Debian1...
VBoxManage showvminfo "Debian1" >nul 2>&1

if ERRORLEVEL 1 goto creation

echo La machine existe deja. Suppression en cours...
VBoxManage unregistervm "Debian1" --delete

:creation
echo Creation de la machine virtuelle Debian1...
VBoxManage createvm --name "Debian1" --ostype "Debian_64" --register
VBoxManage modifyvm "Debian1" --memory 4096 --nic1 nat
VBoxManage createmedium disk --filename "Debian1.vdi" --size 65536
VBoxManage storagectl "Debian1" --name "SATA" --add sata
VBoxManage storageattach "Debian1" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "Debian1.vdi"

echo.
echo Operation terminee. La machine Debian1 est prete.