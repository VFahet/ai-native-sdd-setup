# Migrations

Une entrée par **rupture de convention** du plugin : un changement qui laisse un dépôt déjà configuré dans un état que la chaîne ne sait plus lire. `/upgrade-sdlc` parcourt ce fichier de haut en bas.

Une entrée y est ajoutée **au moment où la rupture est commise**, pas après coup. Une convention changée sans entrée ici est une rupture silencieuse : les dépôts déjà configurés continuent de tourner sur l'ancienne, et personne ne le voit.

Chaque entrée porte quatre champs, et les trois derniers ne se mélangent pas :

- **Pourquoi** — ce que la rupture achète. Sert à l'utilisateur qui décide d'appliquer ou non.
- **Détection** — comment constater, sur le dépôt, que la migration n'a pas été faite. Doit être vraie sur un dépôt neuf comme sur un dépôt ancien, sans dépendre d'un numéro de version.
- **Remédiation** — les gestes exacts.
- **Coût de refus** — ce qui casse si on n'applique pas. Une migration sans coût de refus n'est pas une migration, c'est une préférence.

---

## M001 — La spec sort du tracker

**Pourquoi.** La spec vivait dans le corps d'une issue, que ni le diff, ni la revue ligne à ligne, ni l'historique ne couvrent. Elle devient un fichier versionné `docs/specs/<feature-slug>.md`, portant un statut `Draft → Approved → Implemented → Superseded by …`. Le tracker garde les tickets et, sur un vrai tracker, une **epic mince** — un lien, des critères, la liste des enfants, jamais une copie de la spec.

**Détection.** Pour chaque fonctionnalité ayant une spec :

- tracker markdown local → un `.scratch/<slug>/spec.md` existe ;
- vrai tracker → une issue titrée `spec: <slug>` dont le corps porte les sections du gabarit (`## User stories`, `## Décisions d'implémentation`) au lieu d'un lien ;
- dans les deux cas → pas de `docs/specs/<slug>.md`, ou un fichier sans ligne `**Statut :**`.

**Remédiation.** Par fonctionnalité, dans cet ordre :

1. Créer `docs/specs/<slug>.md` avec le corps existant, précédé de l'en-tête `# spec: <slug> — <titre>`, `**Statut :**` et `**Epic :**`.
2. Choisir le statut d'après l'état réel : `Implemented` si les tickets sont tous fermés, `Approved` si le travail a commencé, `Draft` sinon. Le proposer, ne pas le supposer.
3. Sur un vrai tracker, remplacer le corps de l'issue par le lien, les critères au niveau de la fonctionnalité et la liste des tickets. **Ne pas fermer l'issue** — elle devient l'epic.
4. Sur le tracker markdown local, supprimer `.scratch/<slug>/spec.md` une fois le fichier écrit et relu. Il n'y a pas d'epic en local.

**Coût de refus.** `/to-spec` considérera la fonctionnalité comme non spécifiée et en réécrira une. `/implement` étape 7 et `/code-review` chercheront `docs/specs/<slug>.md`, ne le trouveront pas, et sauteront l'axe Spec de la revue de fonctionnalité — sans que rien d'autre ne le signale.

---

## M002 — Standards de code

**Pourquoi.** L'axe Standards de `/code-review` lit un fichier de standards du dépôt, qu'aucun skill n'écrivait. Il tournait donc sur la seule base de smells de Fowler : un bon filet générique, mais rien qui porte les conventions de ce dépôt.

**Détection.** `docs/agents/coding-standards.md` absent, et aucun `CODING_STANDARDS.md` ni `CONTRIBUTING.md` à la racine.

**Remédiation.** Rejouer la **Section E de `/setup-sdlc`** : poser la question, et sur accord écrire le gabarit avec la seule section « Outillage en place » pré-remplie, déduite de ce que le dépôt utilise réellement. Ne rien deviner dans les autres sections.

**Coût de refus.** Aucune casse : la revue continue de tourner sur la base de smells. C'est la seule migration de ce fichier qu'on peut refuser sans conséquence — le dire à l'utilisateur au lieu d'insister.

---

## Dérives tolérées

Ce qui a changé sans devenir une migration, et pourquoi :

- **Les lignes `Parent` et `Spec` des tickets sont devenues obligatoires.** Les tickets déjà publiés n'en portent pas. Ne pas les réécrire : `/implement` sait encore dériver le slug du titre de la fonctionnalité, et réécrire des tickets en cours de route brouille leur historique pour un gain nul. Les nouveaux tickets les porteront.
