---
name: grill-with-docs
description: Une interview sans relâche pour affûter un plan ou une conception, qui produit en même temps la documentation associée (ADR et glossaire).
disable-model-invocation: true
---

Appeler l'outil Skill deux fois, pour « grilling » et « domain-modeling ».

## Premier tour, quand un PRD existe

Si `docs/prd.md` est présent, l'entretien porte sur **une seule fonctionnalité** de ce PRD — jamais plusieurs à la fois — et le premier tour la cadre avant de parler du comment.

Lire d'abord :

- **`docs/prd.md`** : il porte déjà le problème, les acteurs, les exigences non fonctionnelles et les métriques. Ne pas les rejouer.
- **`CONTEXT.md` et `docs/adr/`** : les fonctionnalités déjà traitées y ont laissé leur vocabulaire et leurs décisions difficilement réversibles. Elles **contraignent** cet entretien. Le comment de chaque fonctionnalité s'ajoute au précédent — il ne repart jamais d'une page blanche, et rouvrir un ADR existant est une décision explicite, pas un effet de bord.

Poser seulement ce qui est propre à cette fonctionnalité :

1. **Quelle fonctionnalité du PRD** cet entretien réalise-t-il, et l'énoncé qu'en donne le PRD tient-il encore ? En dériver le **slug** en kebab-case et l'annoncer : il nomme le répertoire `.scratch/<feature-slug>/` qui portera cet entretien, la spec et les tickets. C'est ce qui fait circuler le slug par le système de fichiers plutôt que par la conversation.
2. **Le comportement attendu**, du point de vue de l'acteur.
3. **Les limites** : ce que cette fonctionnalité ne fait pas, et ce qui est repoussé à plus tard.
4. **Sa contribution aux métriques** du PRD.

Quatre questions est un plafond, pas un objectif. Si le PRD suffit, sauter ce tour entièrement.

La question 1 est le seul endroit où le gel du PRD est vérifié. Si l'énoncé ne tient plus, ne pas corriger le PRD au fil de l'eau : le signaler, et laisser l'utilisateur décider d'une révision datée avec sa raison.

Les tours suivants sont du `grilling` normal, sur le **comment**. Pas de cloison entre les deux : une fois la fonctionnalité cadrée, la conversation glisse vers la conception, et c'est ce qu'on veut.

Pas de `docs/prd.md` ? Rien de tout ceci ne s'applique — enchaîner directement sur `grilling`.

## Écrire la sortie

Quand l'entretien est terminé, les décisions **difficilement réversibles** partent en ADR et le vocabulaire tranché dans `CONTEXT.md`. C'est `domain-modeling` qui s'en charge, au fil de l'eau, et ça vaut dans tous les cas.

**S'il y avait un PRD** — donc un slug, établi à la question 1 — écrire en plus `.scratch/<feature-slug>/decisions.md` : tout le reste de ce qui a été décidé. Formes de modules, interfaces esquissées, contrats, arbitrages écartés et leur raison, questions laissées ouvertes. Une décision par entrée, dans l'ordre où elle a été prise.

Cet artefact a un lecteur unique, `/to-spec`, et une seule raison d'exister : **que l'entretien survive à une fin de session.** Sans lui, `to-spec` lancé dans une fenêtre neuve n'a rien à synthétiser — il lui est interdit d'interviewer, donc il inventerait.

Il est jetable une fois la spec écrite. Le dire à l'utilisateur, et lui proposer d'enchaîner tout de suite si la session est encore vivante.

**Sans PRD**, il n'y a pas de slug et cet entretien n'appartient pas à la chaîne produit : s'arrêter aux ADR et à `CONTEXT.md`.
