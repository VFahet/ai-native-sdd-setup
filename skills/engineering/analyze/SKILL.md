---
name: analyze
description: "Relit les artefacts de la chaîne les uns contre les autres — PRD, spec, ADR, glossaire, tickets — et rapporte ce qui s'y contredit, avant qu'une ligne de code soit écrite. Trois axes en sous-agents parallèles : Descente, Cohérence, Constructibilité. À utiliser après `/to-tickets` et avant le premier `/implement`, ou quand l'utilisateur demande si sa chaîne est cohérente."
disable-model-invocation: true
---

Confronter les artefacts de la chaîne **les uns aux autres**, pas au code. Le code n'existe pas encore : c'est tout l'intérêt.

Trois axes, dans des **sous-agents parallèles** pour ne pas polluer leurs contextes respectifs ; ce skill agrège ensuite leurs constats.

- **Descente** : ce qui est exigé en haut se retrouve-t-il en bas ?
- **Cohérence** : les artefacts se contredisent-ils entre eux ?
- **Constructibilité** : un agent peut-il exécuter ces tickets tels quels ?

**Ce skill ne modifie rien.** Il rapporte. Ne pas réécrire une spec pour la faire coller aux tickets, ne pas reposer un label, ne pas compléter un critère d'acceptation manquant — chacun de ces gestes inverse silencieusement lequel des deux artefacts fait foi. L'utilisateur décide, puis relance le skill qui corrige.

L'issue tracker devrait t'avoir été fourni. Si `docs/agents/issue-tracker.md` est absent, dire à l'utilisateur de lancer `/setup-sdlc`.

## Frontière avec `/code-review`

`/code-review` confronte du **code** à une intention. `/analyze` confronte des **intentions entre elles**, avant qu'il y ait du code.

Un constat qui demande de lire un diff n'appartient pas ici. Un constat qui aurait été visible avant la première ligne écrite n'appartient pas à `/code-review`. Les deux dérivent l'un vers l'autre dès qu'on relâche cette frontière, et on se retrouve avec deux skills qui rapportent la même chose deux fois.

## Process

### 1. Rassembler le périmètre

L'utilisateur passe un `<feature-slug>`, ou rien. Sans argument, prendre la fonctionnalité la plus récemment découpée, l'annoncer, et continuer.

Réunir, en notant ce qui manque :

- `docs/prd.md` — les exigences non fonctionnelles et la ligne de cette fonctionnalité
- `docs/specs/<feature-slug>.md` — la spec et son **statut**
- `docs/adr/` — les ADR qui couvrent la zone
- `CONTEXT.md` — le glossaire du domaine
- les **tickets** — via `docs/agents/issue-tracker.md` : les enfants de l'epic sur un vrai tracker, les fichiers de `.scratch/<feature-slug>/issues/` en markdown local
- l'**epic**, sur un vrai tracker

**Un artefact absent est un constat, pas un blocage.** Pas de PRD : l'axe Descente tourne sur la seule paire spec → tickets et le dit. Pas de spec : les trois axes s'arrêtent et le skill rapporte que `/to-spec` a été sauté — il n'y a rien à confronter.

Vérifier tout de suite que la spec et les tickets existent tous les deux. Un périmètre vide doit échouer ici, pas à l'intérieur de trois sous-agents.

### 2. Lancer les trois sous-agents en parallèle

Coller la base de référence de son axe **intégralement** — c'est le seul accès du sous-agent à ce qu'il doit chercher.

Pour les artefacts, ne coller que ce dont l'axe a besoin, et passer le chemin du reste. Un PRD, une spec de plusieurs milliers de mots et une dizaine de tickets collés en entier dans trois prompts saturent la fenêtre avant que le travail commence :

- **Descente** : les exigences non fonctionnelles du PRD et la ligne de cette fonctionnalité ; les **titres** des décisions de la spec, ses décisions de test et son hors-scope ; les tickets en entier. Le chemin de la spec pour qu'il zoome au besoin.
- **Cohérence** : le glossaire de `CONTEXT.md`, les titres et décisions des ADR qui couvrent la zone, l'en-tête de la spec (statut, slug), le corps de l'epic, les titres et labels des tickets. Pas le corps de la spec.
- **Constructibilité** : les tickets en entier et les points d'arbitrage de la spec — ceux qu'elle a délibérément différés. Rien d'autre.

Chaque brief se termine par : « Pour chaque constat, cite les **deux** artefacts qui se contredisent, avec la ligne ou le numéro de ticket. Un constat qui n'en cite qu'un est une opinion, pas une contradiction — ne le rapporte pas. Moins de 400 mots. »

**Descente** — la spec reprend-elle le PRD, les tickets reprennent-ils la spec :

- Une exigence non fonctionnelle du PRD, **avec son chiffre ou son seuil**, qui contraint cette fonctionnalité et que la spec ne reprend pas. Une exigence restée dans le PRD ne deviendra jamais un critère d'acceptation.
- Une décision d'implémentation de la spec qu'aucun ticket ne porte.
- Une décision de test de la spec qu'aucun ticket ne porte.
- Un ticket qui construit quelque chose que la spec n'a pas demandé — dérive de périmètre, à l'échelle du découpage.
- Un élément du hors-scope de la spec qu'un ticket réintroduit.

**Cohérence** — les artefacts se contredisent-ils :

- Un ticket qui contredit un ADR de `docs/adr/`.
- Du vocabulaire hors du glossaire de `CONTEXT.md` dans la spec ou les tickets, là où le glossaire a un terme — ou pire, un terme du glossaire employé pour autre chose.
- Un **slug divergent** entre la spec, l'epic, les tickets et le nom de branche attendu. C'est le mode de défaillance le plus discret de la chaîne : il ne casse rien tout de suite, et fait rater sa spec à la revue de fonctionnalité.
- Un **statut de spec** incohérent avec l'état des tickets : `Draft` alors que des tickets sont déjà fermés, `Implemented` alors qu'il en reste des ouverts.
- Un corps d'epic qui **recopie** la spec au lieu de la lier — deux corps qui dérivent, et plus rien ne dit lequel fait foi.
- Un **label de triage** qui contredit ce que la spec a demandé. La spec peut poser une instruction contraire explicite ; le défaut de `to-tickets` est `ready-for-agent`, et une décision que la spec réserve à un humain doit porter `ready-for-human`.

**Constructibilité** — un agent peut-il prendre ces tickets tels quels :

- Un ticket **sans critères d'acceptation**. On ne valide pas contre une cible qui n'existe pas.
- Un critère d'acceptation qu'aucune preuve nommable ne pourrait satisfaire — « ça devrait marcher », « c'est propre ».
- Une **arête de blocage déclarée en prose** dans le corps d'un ticket mais pas câblée dans la relation native du tracker. La frontière cesse alors d'être visible dans l'interface, et c'est justement ce que la relation native achète.
- Un **cycle** dans les arêtes de blocage, ou une arête vers un ticket qui n'existe pas.
- Un ticket qui dépend d'un **point d'arbitrage non tranché** de la spec — une décision que la spec a délibérément différée, et qu'un ticket suppose pourtant prise.
- Un ticket qui n'est pas une **tranche verticale** : une couche seule, non démontrable par elle-même.
- Un ticket dont le périmètre ne tient manifestement pas dans une fenêtre neuve.

### 3. Agréger

Présenter les trois rapports sous `## Descente`, `## Cohérence` et `## Constructibilité`, verbatim ou légèrement nettoyés. Ne **pas** fusionner ni reclasser : les axes sont séparés pour qu'aucun ne masque les autres.

Puis une ligne de verdict : le nombre de constats par axe, et — seule agrégation autorisée — **ce qui doit être corrigé avant le premier `/implement`** par opposition à ce qui peut attendre. Le critère : un constat qui produirait du travail à refaire est bloquant ; un constat de vocabulaire ne l'est pas.

Terminer en rappelant que rien n'a été modifié, et en nommant qui corrige quoi : la spec et les ADR relèvent de l'utilisateur, les tickets d'un `/to-tickets` relancé.

## Pourquoi trois axes

Un découpage peut passer un axe et échouer aux autres :

- Des tickets qui reprennent fidèlement la spec, mais dont aucun ne porte de critère d'acceptation → **Descente OK, Constructibilité KO.**
- Des tickets impeccablement constructibles qui ont perdu une exigence chiffrée du PRD → **Constructibilité OK, Descente KO.**
- Les deux au vert, et un slug divergent qui fera rater sa spec à la revue de fonctionnalité → **Cohérence KO**, invisible partout ailleurs.

Les rapporter séparément empêche un axe d'en masquer un autre.

## Ensuite

Rien de bloquant : `/clear`, puis `/implement <référence>` sur les tickets de la frontière — annoncer à l'utilisateur les commandes exactes à taper, référence comprise, le slug ne survivant pas au `/clear`.

Des constats bloquants : nommer qui corrige quoi. Un manque de descente ou de constructibilité se corrige en relançant `/to-tickets` sur la spec ; une contradiction avec un ADR, un statut ou un slug se corrige à la main, par l'utilisateur, dans l'artefact qui fait foi. Relancer `/analyze` après correction — c'est bon marché, il ne produit rien.
