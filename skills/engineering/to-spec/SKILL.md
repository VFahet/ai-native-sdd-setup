---
name: to-spec
description: "Transforme la conversation en cours en spec et la publie dans l'issue tracker du projet : pas d'interview, juste la synthèse de ce qui a déjà été discuté."
disable-model-invocation: true
---

Ce skill prend le contexte de la conversation en cours et la compréhension du code, et produit une spec. Ne PAS interviewer l'utilisateur ; se contenter de synthétiser ce que tu sais déjà.

L'issue tracker et le vocabulaire des labels de triage devraient t'avoir été fournis. Si ce n'est pas le cas, dire à l'utilisateur de lancer `/setup-sdlc`.

## Process

1. **Rassembler les sources écrites**, avant toute synthèse. C'est ce qui permet de lancer ce skill dans une fenêtre neuve, sans avoir mené l'entretien soi-même :

   - **`.scratch/<feature-slug>/decisions.md`** s'il existe : les décisions prises pendant `/grill-with-docs`. C'est la source principale des sections *Décisions d'implémentation* et *Décisions de test* quand la conversation ne les porte pas. Si l'utilisateur n'a pas passé de slug, parcourir `.scratch/*/` à la recherche des répertoires contenant un `decisions.md` dont la fonctionnalité n'a **pas encore de spec**. Ce que « pas encore de spec » veut dire dépend de la forme que le tracker configuré donne à une spec, lue dans `docs/agents/issue-tracker.md` : sur le tracker markdown local, pas de `spec.md` à côté du `decisions.md` ; sur un vrai tracker, aucune issue dont le titre commence par `spec: <feature-slug>` — la marque que pose l'étape 4, à chercher sur tous les états, ouverts comme fermés. S'il n'y en a qu'un, l'annoncer et continuer, sinon demander lequel.
   - **`docs/prd.md`** s'il existe : y relever les **exigences non fonctionnelles qui contraignent cette fonctionnalité**, et les reporter dans les décisions d'implémentation **avec leur chiffre ou leur seuil**. Une exigence restée dans le PRD ne deviendra jamais un critère d'acceptation. Reprendre aussi le hors-périmètre du projet qui touche cette zone.
   - **La carte d'un chantier `/wayfinder`** — `.scratch/<chantier>/map.md` sur le tracker markdown local, l'issue labellisée `wayfinder:map` sur un vrai tracker — quand l'utilisateur en passe une ou qu'un chantier existe : sa **destination** dit vers quoi ce chantier cherchait son chemin, et ses **Décisions à ce jour** indexent les **tickets de décision** résolus. La carte n'en garde que l'essentiel, donc zoomer sur les tickets qui touchent cette fonctionnalité pour lire leur réponse. Reprendre son **hors périmètre** dans le hors-scope de la spec, et laisser le **brouillard** dehors : ce que la carte n'a pas encore spécifié ne se spécifie pas ici.

   Attention à l'altitude : le PRD énonce le problème **du projet**, cette spec énonce celui **d'une seule fonctionnalité**. Ne pas recopier — restreindre.

   Si aucune de ces sources n'existe, travailler à partir de la conversation seule, comme avant.

2. Explorer le dépôt pour comprendre l'état actuel du code, si ce n'est pas déjà fait. Utiliser le vocabulaire du glossaire de domaine du projet dans toute la spec, et respecter les ADR qui couvrent la zone concernée.

3. Esquisser les seams auxquels la fonctionnalité sera testée. Préférer les seams existants aux nouveaux. Prendre le seam le plus haut possible. Si de nouveaux seams sont nécessaires, les proposer au point le plus haut atteignable. Moins il y a de seams dans le code, mieux c'est — le nombre idéal est un.

Vérifier auprès de l'utilisateur que ces seams correspondent à ce qu'il attend.

4. Rédiger la spec avec le gabarit ci-dessous, puis la publier dans l'issue tracker du projet. Appliquer le label de triage `ready-for-agent` — pas besoin de triage supplémentaire. Sur un vrai tracker, titrer l'issue `spec: <feature-slug> — <titre>` : `ready-for-agent` ne distingue rien, `to-tickets` l'applique aussi à chacun de ses tickets, et c'est ce préfixe de titre qui rend la spec retrouvable par le balayage de l'étape 1. Sur le tracker markdown local, le chemin `.scratch/<feature-slug>/spec.md` porte déjà la marque.

<spec-template>

## Énoncé du problème

Le problème que rencontre l'utilisateur, de son point de vue à lui.

## Solution

La solution à ce problème, du point de vue de l'utilisateur.

## User stories

Une LONGUE liste numérotée de user stories. Chaque user story suit le format :

1. En tant que <acteur>, je veux <fonctionnalité>, afin de <bénéfice>

<user-story-example>
1. En tant que client d'une banque mobile, je veux voir le solde de mes comptes, afin de prendre de meilleures décisions sur mes dépenses
</user-story-example>

Cette liste de user stories doit être extrêmement fournie et couvrir tous les aspects de la fonctionnalité.

## Décisions d'implémentation

La liste des décisions d'implémentation prises. Cela peut inclure :

- Les modules qui seront construits ou modifiés
- Les interfaces de ces modules qui seront modifiées
- Les clarifications techniques apportées par le développeur
- Les décisions d'architecture
- Les changements de schéma
- Les contrats d'API
- Des interactions spécifiques

Ne PAS inclure de chemins de fichiers précis ni d'extraits de code. Ils peuvent devenir obsolètes très vite.

Exception : si un prototype a produit un extrait qui encode une décision plus précisément que la prose ne le pourrait (machine à états, reducer, schéma, forme d'un type), l'inclure dans la décision concernée et noter brièvement qu'il vient d'un prototype. Ne garder que les parties porteuses de décision — pas une démo qui tourne, juste l'essentiel.

## Décisions de test

La liste des décisions de test prises. Inclure :

- Une description de ce qui fait un bon test (ne tester que le comportement externe, pas les détails d'implémentation)
- Quels modules seront testés
- L'art antérieur pour ces tests (c'est-à-dire des tests similaires déjà présents dans le code)

## Hors-scope

Une description de ce qui est hors du périmètre de cette spec.

## Notes complémentaires

Toute note supplémentaire sur la fonctionnalité.

</spec-template>

## Ensuite

`/to-tickets`, avec la spec qui vient d'être publiée : son chemin sur le tracker markdown local, son numéro d'issue sur un vrai tracker. C'est la référence que sa première étape récupère ; sans elle, il repart de la conversation. Ne pas le lancer soi-même : annoncer à l'utilisateur la commande exacte à taper, référence comprise.
