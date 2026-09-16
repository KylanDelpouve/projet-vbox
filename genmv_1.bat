@echo off
echo Creation de la machine virtuelle Debian1...
VBoxManage createvm --name "Debian1" --ostype "Debian_64" --register
VBoxManage modifyvm "Debian1" --memory 4096 --nic1 nat
VBoxManage createmedium disk --filename "Debian1.vdi" --size 65536
VBoxManage storagectl "Debian1" --name "SATA" --add sata
VBoxManage storageattach "Debian1" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "Debian1.vdi"

echo.
echo La machine Debian1 est creee.
echo Veuillez verifier dans l'interface graphique VirtualBox.
pause

echo.
echo Suppression de la machine...
VBoxManage unregistervm "Debian1" --delete
echo Suppression terminee. Le fichier .xml a ete efface.