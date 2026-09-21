Journal de bord

TITRE PROJET : SAÉ 51 - Automatisation de la création de machines  
NOM CHEF DE PROJET : Kylan DELPOUVE
NOMS AUTRE MEMBRES EQUIPE : Tanjona RANDRIANARISOLO
DATE DEBUT : 16/09/2026

Ce document décrit l'utilisation des scripts Windows genmv_X.bat, qui pilotent VirtualBox en ligne de commande (VBoxManage) pour lister, créer, supprimer, démarrer et arrêter des machines virtuelles Debian de façon non interactive. 
Il présente le travail réalisé séance par séance (étapes 1 à 4 terminées, boot PXE/TFTP en cours), les difficultés rencontrées, les astuces techniques utilisées et les limites actuelles.

1. Utilisation

Le script est non interactif : tout passe par les arguments (Windows, genmv_4.bat = dernière version fonctionnelle).

genmv_4 <action> [nom_machine]
Action	Argument 	Description
L		–			Liste les machines enregistrées, avec leurs métadonnées (date de création, créateur)
N		nom			Crée une nouvelle machine (supprime d'abord une machine du même nom si elle existe)
S		nom			Supprime la machine
D		nom			Démarre la machine
A		nom			Arrête la machine


2. Journal de bord
Séance n° 1 date - heure : 16/09/2026 - 08:30 à 11:30
Travail effectué :

Étape 1 – Script de base (genmv_1.bat)

Écriture d'un premier script créant une machine nommée Debian1 (type Linux/Debian 64 bits), dotée de 4096 Mo de RAM, d'un disque dur de 65536 Mo (64 GiB) et d'une carte réseau connectée en NAT.
Ajout d'une pause après la création, permettant de vérifier via l'interface graphique de VirtualBox l'existence de la machine, puis ajout de la commande de suppression (unregistervm + suppression du fichier .xml).
Vérification après exécution complète que la machine n'apparaît plus dans la GUI et que le fichier de description a bien été supprimé.

Étape 2 – Gestion des doublons (genmv_2.bat)

Ajout d'une vérification de l'existence préalable d'une machine du même nom (test du code retour ERRORLEVEL de VBoxManage) avant toute création.
Ajout de la commande de suppression correspondante le cas échéant, rendant le script exécutable de façon répétée sans provoquer d'erreur.

Étape 3 – Gestion des arguments (genmv_3.bat)

Écriture des scripts genmv_1.bat à genmv_4.bat.
Implémentation des branchements conditionnels (goto, ERRORLEVEL) pour traiter le 1er argument (L, N, S, D, A), correspondant respectivement à Lister, Nouvelle machine, Supprimer, Démarrer, Arrêter, et le 2e argument (nom de la machine) pour les commandes N, S, D, A.
Déclaration des tailles de RAM et de disque dur en variables en tête de script (facilement modifiables) et réutilisation de ces variables lors de la création des machines.

Étape 4 – Métadonnées (genmv_4.bat)

Ajout de l'attachement de métadonnées à chaque machine créée : DateCreation (obtenue via l'OS) et Createur (obtenu via la variable d'environnement %USERNAME%), stockées avec VBoxManage setextradata.
Ajout de l'affichage de ces métadonnées lors de la commande L : redirection de la sortie de VBoxManage list vms vers un fichier texte, parsing ligne par ligne via une boucle FOR pour extraire le 1er champ (nom de machine), puis récupération des métadonnées associées via VBoxManage getextradata.

Difficultés rencontrées
Difficulté à comprendre pourquoi il fallait rediriger la sortie de VBoxManage showvminfo vers nul et comment interpréter le ERRORLEVEL 1 pour détecter qu'une machine n'existe pas encore.
Erreur de syntaxe sur l'argument de registre (--register).
Erreur d'UUID (VERR_ALREADY_EXISTS) causée par des disques virtuels résiduels non libérés dans la base de VirtualBox.
Problème d'extension de fichier masquée (.bat.txt) sous Windows bloquant l'exécution.
Difficulté lors de la rédaction de la syntaxe permettant de rediriger chaque argument (L, N, S, D, A) vers sa fonction correspondante.

A faire à la prochaine séance :
- Étape 5 (genmv5.bat): Configuration du boot réseau (PXE) et du serveur TFTP interne pour l'installation d'une image Debian netinst.  
- Installation automatisée via fichier de ”pre-seed”
- Login automatique
- Début des scripts pour les ressources additionnelles.
- Début de rédaction du fichier usage.md.  

Séance n° 2 date - heure : 21/09/2026 - 08:30 à 11:30
Travail effectué :
- Recherches documentaires sur la mise en place d'un serveur TFTP :
  fonctionnement du serveur TFTP intégré à VirtualBox (carte réseau en NAT),
  emplacement où déposer les fichiers, nom attendu pour le fichier de boot
  et structure du répertoire à fournir.
- Ajout dans le script des chemins bruts (chemins absolus, écrits en dur)
  permettant de localiser le répertoire du serveur TFTP interne de VirtualBox,
  afin que la machine puisse y retrouver les fichiers de démarrage.
- Enrichissement du journal de bord : ajout de détails dans les rubriques
  « Travail effectué » et « Difficultés rencontrées » de la séance 1.
  
Difficultés rencontrées : 
- Problème de connexion au serveur TFTP lors du boot PXE : la machine
  démarre bien en boot réseau, mais ne parvient pas à récupérer les fichiers
  de démarrage auprès du serveur TFTP.
- Difficulté lors de la mise en place du serveur TFTP :
  - incertitude sur les fichiers à ajouter dans le répertoire TFTP
    (quels fichiers de l'archive netboot Debian extraire, et où les placer) ;
  - incertitude sur ce que le fichier de configuration doit pointer
    (chemin du noyau et de l'initrd, nom du fichier de boot), l'erreur
    sur un seul de ces chemins empêchant le démarrage.	
	
3. Astuces techniques
Détecter l'existence d'une machine : VBoxManage showvminfo <nom> avec sortie redirigée vers nul ; ERRORLEVEL 1 = machine inexistante.
Supprimer proprement : VBoxManage unregistervm <nom> --delete (désenregistre et supprime les fichiers).
Conserver un code retour : set errcode=%ERRORLEVEL%, car chaque commande écrase ERRORLEVEL.
Métadonnées : VBoxManage setextradata <nom> <clé> <valeur> / getextradata.
Aiguillage des arguments : if "%1" == "L" goto ..., une étiquette par action.

4. Limites connues
Scripts spécifiques à Windows (batch), non portables sous Linux/bash.
Chemins du répertoire TFTP écrits en dur : à adapter selon la machine et l'utilisateur.
Boot PXE/TFTP pas encore fonctionnel de bout en bout ; installation automatisée (preseed) et login automatique pas encore mis en œuvre.