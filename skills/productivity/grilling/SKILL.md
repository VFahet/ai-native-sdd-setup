---
name: grilling
description: Soumettre l'utilisateur à un grilling sans relâche sur un plan, une décision ou une idée. À utiliser quand l'utilisateur veut mettre sa réflexion à l'épreuve, ou emploie une formule de déclenchement du type « grill » ou « grilling ».
---

Interroger l'utilisateur sans relâche jusqu'à parvenir à une compréhension partagée. Cartographier l'échange sous forme d'**arbre de conception** : chaque décision se ramifie en celles qui en dépendent.

Travailler l'arbre par **tours**. La **frontière**, c'est l'ensemble des décisions dont les prérequis sont déjà tranchés : les questions que tu peux poser _maintenant_ sans deviner des réponses que tu n'as pas encore entendues. Poser toute la frontière en un seul tour : numéroter chaque question et donner ta réponse recommandée. Puis attendre les réponses de l'utilisateur avant le tour suivant.

Formater un tour ainsi :

```
❓ **Q1** - **<titre de la question>** : <corps de la question, possiblement sur plusieurs paragraphes, pouvant inclure des choix multiples>

➡️ <ta réponse recommandée>

---

❓ **Q2** - **<titre de la question>** : <corps de la question, possiblement sur plusieurs paragraphes, pouvant inclure des choix multiples>

➡️ <ta réponse recommandée>
```

Chaque tour auquel l'utilisateur répond remodèle l'arbre : les décisions tranchées repoussent la frontière vers l'extérieur et débloquent les questions qui en dépendaient. Recalculer la frontière et poser le tour suivant. Une question dont la réponse dépend d'une autre question encore ouverte dans ce tour appartient à un tour _ultérieur_, pas à celui-ci.

Trouver les _faits_ est ton travail, jamais celui de l'utilisateur. Quand une question de la frontière nécessite un fait tiré de l'environnement (système de fichiers, outils, etc.), dépêcher un sous-agent pour le trouver ; ne pas demander à l'utilisateur ce que tu pourrais chercher toi-même. Ne pas rester bloqué dessus : une exploration en cours est un prérequis non tranché, donc seules les questions qui en découlent attendent le rapport du sous-agent ; poser dès maintenant le reste de la frontière. Les _décisions_ appartiennent à l'utilisateur : les lui soumettre une par une et attendre.

La session est terminée quand la frontière est vide : chaque branche de l'arbre de conception visitée, rien laissé en supposition tacite. Ne pas agir dessus tant que l'utilisateur n'a pas confirmé que vous êtes parvenus à une compréhension partagée.
