---
name: implement
description: "Implémente un ticket ou une spec, puis valide le résultat critère d'acceptation par critère d'acceptation avant de commiter."
disable-model-invocation: true
---

Implémenter le travail décrit par l'utilisateur dans le ticket ou la spec, puis **prouver** qu'il est fait.

## 1. Charger le ticket

Lire le ticket en entier — corps, critères d'acceptation, bloqueurs. Si l'utilisateur a passé un chemin ou un numéro, le récupérer via le workflow décrit dans `docs/agents/issue-tracker.md`.

Vérifier que les bloqueurs du ticket sont tous terminés. Si l'un ne l'est pas, le dire et s'arrêter : implémenter un ticket bloqué produit du travail à refaire.

Si le ticket ne porte **aucun critère d'acceptation**, ne pas en inventer en silence. Les proposer à l'utilisateur, les faire valider, et les écrire dans le ticket avant de commencer. On ne peut pas valider contre une cible qui n'existe pas.

## 2. Implémenter

Utiliser `/tdd` autant que possible, aux seams convenus à l'avance. Un seam non confirmé n'est pas un seam.

Lancer le typecheck régulièrement, et les fichiers de test concernés régulièrement. Garder la boucle courte.

Rester dans le périmètre du ticket. Tout ce qui est utile mais hors périmètre se note pour un ticket suivant, ne s'implémente pas ici.

## 3. Valider, critère par critère

C'est l'étape qui distingue « le code est écrit » de « le ticket est fait ». Ne pas la résumer.

Reprendre les critères d'acceptation **un par un, dans l'ordre**. Pour chacun, énoncer :

- La **preuve** : le test qui le couvre, ou la vérification manuelle effectuée avec son résultat observé.
- Le **verdict** : satisfait, partiellement satisfait, ou non satisfait.

Un critère sans preuve nommable n'est pas satisfait. « Ça devrait marcher » n'est pas une preuve ; le nom d'un test qui passe en est une.

Puis lancer la suite de tests **complète**, une fois. Une suite verte sur les fichiers touchés ne dit rien de ce que le changement a cassé ailleurs.

Si un critère n'est pas satisfait : revenir à l'étape 2. Ne pas cocher, ne pas commiter, ne pas signaler le ticket comme terminé.

## 4. Relire

Utiliser `/code-review` pour relire le travail. Son axe **Spec** confronte le diff au ticket d'origine — c'est un second regard sur ce que l'étape 3 vient d'affirmer, et il est indépendant.

Traiter les constats bloquants avant de commiter. Consigner ceux qu'on choisit de ne pas traiter, avec la raison.

## 5. Clore

Cocher les critères d'acceptation dans le ticket, et y consigner la preuve retenue pour chacun.

Commiter sur la branche courante, en référençant le ticket dans le message.

Dire à l'utilisateur quels tickets sont désormais débloqués par celui-ci.
