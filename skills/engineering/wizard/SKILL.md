---
name: wizard
description: Génère un wizard bash interactif qui guide un humain à travers les étapes que lui seul peut faire. À utiliser pour provisionner une infrastructure, poser des identifiants ou des secrets de CI, traverser un dashboard tiers mal connu, ou mener une migration ou une bascule ponctuelle. Ne pas l'invoquer pour des étapes que l'agent peut exécuter lui-même.
---

# Wizard

Un **wizard** est un script bash qui guide un humain, pas à pas, à travers une procédure manuelle pénible à faire à la main et pénible à ré-expliquer à une IA chaque fois. Il ouvre chaque URL, dit exactement où cliquer et quoi copier, capture les valeurs, les écrit là où elles vont (`.env`, secrets GitHub), confirme à chaque palier et affiche combien d'étapes restent. Il peut configurer des services tiers, mener une migration ponctuelle, ou faire passer le projet d'un état à un autre.

L'UX est déjà résolue par [template.sh](template.sh) : progression étape par étape, portes de confirmation, ouverture d'URL multi-plateforme (WSL compris), saisie masquée des secrets, écriture idempotente dans `.env`, appels `gh secret`/`gh variable`, et résumé de clôture. **Ton travail se limite à cadrer la procédure et à écrire ses étapes.** La bibliothèque au-dessus du marqueur `STAGES` est identique dans tous les wizards ; cette constance est le but : ne jamais l'éditer à la main.

Un wizard est jetable par défaut : construit pour une exécution, enregistré dans un chemin de scratch ou dans `scripts/`, supprimé une fois le travail fait. Ne le commiter que si l'utilisateur veut un chemin d'installation répétable, qui a sa place dans le dépôt.

## Process

### 1. Cadrer la procédure

Établir chaque étape manuelle que l'humain devra faire, et chaque valeur capturée en chemin. Lire le dépôt d'abord, ne pas demander à froid :

- Pour une installation : `.env`, `.env.example`, `.env.*`, le `README`, `docker-compose*`, la configuration du framework, et `.github/workflows/*` — chaque référence `secrets.*` / `vars.*` est une valeur que le wizard doit produire.
- Pour une migration ou une bascule : l'état de départ, l'état visé, et les actions irréversibles entre les deux.

Montrer ensuite à l'utilisateur la liste ordonnée des étapes et les valeurs que chacune produit, puis confirmer : il peut en ajouter, en retirer, en réordonner.

**Terminé quand :** chaque étape est nommée dans l'ordre, et pour chaque valeur capturée tu sais (a) où l'humain la trouve, (b) où elle est écrite (`.env`, un secret GitHub, les deux, ou nulle part — certaines étapes sont de pures actions), et (c) si elle est secrète (saisie masquée) ou publique.

### 2. Tracer le parcours de chaque étape

Pour chaque étape, écrire le chemin précis que l'humain suit : quelle URL ouvrir, quoi y faire, où la valeur s'affiche, quelle variable elle remplit. Par exemple : « Dashboard → Developers → API keys → Reveal test key → copier ». Là où tu ne connais pas réellement l'UI actuelle ou la commande exacte, le dire et demander à l'utilisateur, ou vérifier dans la doc : ne jamais inventer une étape qui pourrait ne pas exister.

**Terminé quand :** chaque étape se traduit en instructions concrètes qu'un inconnu pourrait suivre.

### 3. Écrire le wizard

Copier `template.sh` vers le chemin cible. Remplacer l'étape d'exemple par un `stage` par étape, dans l'ordre des dépendances. Utiliser les fonctions de la bibliothèque : `stage`, `say`/`step`, `open_url`, `ask`/`ask_secret`, `write_env`, `set_secret`/`set_var`, `pause`/`confirm`. Régler `TOTAL_STAGES` sur le nombre d'étapes écrites.

Tenir la barre que pose le gabarit : ouvrir l'URL **avant** de demander sa valeur, utiliser `ask_secret` pour tout ce qui est secret, `write_env` pour chaque valeur persistée, `set_secret` pour les seules valeurs dont la CI a réellement besoin, et `confirm` avant toute action irréversible. Chaque `stage` efface l'écran pour que seule l'étape courante soit visible : garder une étape sur une seule tâche, pour que rien de ce dont l'humain a besoin ne défile hors champ. Ne pas toucher à la bibliothèque au-dessus du marqueur.

### 4. Vérifier et passer la main

- `bash -n <script>` ; lancer `shellcheck` s'il est disponible.
- `chmod +x <script>`.
- Ne pas l'exécuter de bout en bout toi-même : il ouvre des navigateurs et se bloque sur des saisies humaines. Le tracer statiquement à la place — chaque valeur de l'étape 1 est capturée et atterrit là où l'étape 1 l'a dit, et chaque nom passé à `set_secret` correspond exactement à une référence `secrets.*` de la CI.
- Dire à l'utilisateur comment le lancer. Si c'est un chemin d'installation répétable, le commiter et le lier depuis le README, pour que la personne suivante lance le script au lieu de demander à une IA.
