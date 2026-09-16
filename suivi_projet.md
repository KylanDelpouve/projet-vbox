Journal de bord

TITRE PROJET : SAÉ 51 - Automatisation de la création de machines  
NOM CHEF DE PROJET : Kylan DELPOUVE
NOMS AUTRE MEMBRES EQUIPE : Tanjona RANDRIANARISOLO
DATE DEBUT : 16/09/2026

Séance n° 1date - heure : 16/09/2026 - 08:30 à 11:30
Travail effectué :
- Configuration de la variable PATH système pour l'accès à VBoxManage.
- Écriture des scripts genmv_1.bat à genmv_4.bat.
- Création, modification, démarrage, arrêt et suppression de machines virtuelles (Debian 64 bits, 4096 Mo RAM, 65536 Mo HDD) en interface de ligne de commande.
- Implémentation des branchements conditionnels (goto, ERRORLEVEL) pour traiter les arguments (L, N, S, D, A) et éviter les doublons de machines.  
- Ajout de la lecture et de l'écriture des métadonnées (Createur, DateCreation) avec gestion de fichier texte de sortie.  

A faire à la prochaine séance :
- Étape 5 (genmv5.bat): Configuration du boot réseau (PXE) et du serveur TFTP interne pour l'installation d'une image Debian netinst.  
- Installation automatisée via fichier de ”pre-seed”
- Login automatique
- Début des scripts pour les ressources additionnelles.
- Début de rédaction du fichier usage.md.  

Difficultés rencontrées : 
- Erreur de syntaxe sur l'argument de registre (--register).
- Erreur d'UUID (VERR_ALREADY_EXISTS) causée par des disques virtuels résiduels non libérés dans la base de VirtualBox.
- Problème d'extension de fichier masquée (.bat.txt) sous Windows bloquant l'exécution.