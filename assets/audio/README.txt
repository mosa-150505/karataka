Depose ici tes fichiers audio pour qu'ils soient reconnus automatiquement.
Le NOM compte, l'EXTENSION est libre parmi .ogg / .mp3 / .wav (garde la
vraie extension de ton fichier, ne la modifie pas a la main) :

assets/audio/music/menu_theme.(ogg|mp3|wav)   -> musique de l'ecran de menu
assets/audio/music/game_theme.(ogg|mp3|wav)   -> musique de l'ecran de jeu
assets/audio/sfx/click.(ogg|mp3|wav)          -> son joue sur CHAQUE bouton (automatique)

Si tu veux d'autres noms de fichiers, modifie les constantes en haut de
scripts/global/audio_manager.gd (MENU_MUSIC_BASENAME, GAME_MUSIC_BASENAME,
CLICK_SFX_BASENAME).

Tant qu'un fichier n'est pas present, le jeu fonctionne normalement, juste
sans ce son (un avertissement s'affiche dans l'onglet Sortie de Godot).
