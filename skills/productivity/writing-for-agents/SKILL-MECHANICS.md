# Mécanique des skills

La branche spécifique aux skills de [`writing-for-agents`](SKILL.md) : ce qui change quand le document est un skill (le frontmatter, le choix d'invocation et les skills routeurs). Tout le reste de son écriture relève de la référence universelle de `SKILL.md`.

## Invocation

Deux choix, qui arbitrent entre les deux charges :

- Un skill **invoqué par le modèle** garde une `description`, donc l'agent peut le déclencher de façon autonome, et d'autres skills peuvent l'atteindre. Tu peux toujours taper son nom : l'invocation par le modèle _inclut_ toujours l'accès humain ; une description ne fait qu'ajouter la découverte par l'agent, elle ne retire jamais celle de l'humain. La description est le pointeur de contexte de plus haut niveau du skill, forcé de rester chargé en permanence : charge de contexte permanente en échange de la découvrabilité. Un skill invoqué par le modèle dont le contenu est entièrement de la référence est aussi un foyer pour la référence partagée : un autre skill peut l'invoquer, si bien que la référence dont plusieurs skills ont besoin vit à un seul endroit. Mécanique : omettre `disable-model-invocation`, et écrire une description destinée au modèle qui porte les branches de déclenchement (les règles d'écriture des pointeurs de `SKILL.md` s'appliquent intégralement).
- Un skill **invoqué par l'utilisateur** retire la description de la portée de l'agent : seul l'humain qui tape son nom peut l'invoquer, et aucun autre skill ne le peut. Charge de contexte nulle, mais il dépense de la charge cognitive : c'est toi l'index qui doit se souvenir qu'il existe. Mécanique : mettre `disable-model-invocation: true` ; la `description` devient destinée à l'humain : un résumé d'une ligne, listes de déclencheurs supprimées.

Ne choisis l'invocation par le modèle que si l'agent doit atteindre le skill de lui-même, ou si un autre skill le doit. S'il ne se déclenche jamais qu'à la main, rends-le invoqué par l'utilisateur et ne paie aucune charge de contexte.

Une référence partagée dont deux skills invoqués par l'utilisateur ont tous deux besoin ne peut vivre dans aucun des deux : sans description, aucun ne peut déclencher l'autre. Pousse-la dans un simple fichier hors du système de skills : une référence externe que n'importe quel skill peut pointer.

## Découper par invocation

La coupe par invocation du découpage (la coupe par séquence vit dans `SKILL.md`) : détache un skill invoqué par le modèle quand tu as un mot directeur distinct qui doit le déclencher tout seul (un mot déclencheur que tu emploies réellement dans tes prompts), ou quand un autre skill doit l'atteindre. Tu paies une charge de contexte pour la nouvelle description toujours chargée : il faut donc que cet accès indépendant en vaille la peine.

## Skills routeurs

Quand les skills invoqués par l'utilisateur se multiplient au-delà de ce que tu peux retenir, cette charge cognitive accumulée se soigne par un **skill routeur** : un seul skill invoqué par l'utilisateur qui nomme les autres et dit quand recourir à chacun, si bien que l'humain n'a qu'un skill à retenir au lieu de plusieurs. Il peut seulement suggérer, jamais les déclencher : les skills invoqués par l'utilisateur n'ont pas de description, donc rien d'autre que l'humain ne peut les atteindre.
