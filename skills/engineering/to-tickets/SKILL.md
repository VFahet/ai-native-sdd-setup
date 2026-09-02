---
name: to-tickets
description: Découpe un plan, une spec ou la conversation en cours en un ensemble de tickets tracer bullet, chacun déclarant ce qui le bloque, publiés dans le tracker configuré (les arêtes en texte, un fichier par ticket en local, ou des liens de blocage natifs sur un vrai tracker).
disable-model-invocation: true
---

# To Tickets

Découper un plan, une spec ou une conversation en **tickets** : des tranches verticales *tracer bullet*, chacune déclarant les tickets qui la **bloquent**.

L'issue tracker et le vocabulaire des labels de triage devraient t'avoir été fournis. Si ce n'est pas le cas, dire à l'utilisateur de lancer `/setup-sdlc`.

## Process

### 1. Rassembler le contexte

Travailler à partir de ce qui est déjà dans le contexte de la conversation. Si l'utilisateur passe une référence en argument (un chemin de spec, un numéro ou une URL d'issue), la récupérer et lire son corps complet et ses commentaires.

### 2. Explorer le code (optionnel)

Si tu n'as pas encore exploré le code, le faire pour comprendre son état actuel. Les titres et descriptions de tickets doivent utiliser le vocabulaire du glossaire de domaine du projet, et respecter les ADR qui couvrent la zone concernée.

Chercher les occasions de faire du *prefactoring* pour rendre l'implémentation plus facile. « Make the change easy, then make the easy change. »

### 3. Esquisser les tranches verticales

Découper le travail en tickets **tracer bullet**.

<vertical-slice-rules>

- Chaque tranche traverse toutes les couches (schéma, API, UI, tests) de façon étroite mais COMPLÈTE : verticale, PAS une tranche horizontale d'une seule couche
- Une tranche terminée est démontrable ou vérifiable seule
- Chaque tranche est dimensionnée pour tenir dans une seule fenêtre de contexte neuve
- Tout *prefactoring* doit être fait en premier

</vertical-slice-rules>

Donner à chaque ticket ses **arêtes de blocage** : les autres tickets qui doivent être terminés avant qu'il puisse démarrer. Un ticket sans bloqueur peut démarrer immédiatement.

**Les refactors larges sont l'exception au découpage vertical.** Un **refactor large** est un changement mécanique unique (renommer une colonne, retyper un symbole partagé) dont le **blast radius** s'étend à tout le code : une seule modification casse des milliers de points d'appel d'un coup, et aucune tranche verticale ne peut atterrir au vert. Ne pas le forcer dans un tracer bullet ; le séquencer en **expand–contract**. D'abord *expand* : ajouter la nouvelle forme à côté de l'ancienne, pour que rien ne casse. Puis migrer les points d'appel par lots dimensionnés par le blast radius (par paquet, par répertoire), chaque lot étant son propre ticket bloqué par l'*expand*, la CI restant verte de lot en lot puisque l'ancienne forme existe toujours. Enfin *contract* : supprimer l'ancienne forme une fois qu'aucun appelant ne subsiste, dans un ticket bloqué par tous les lots de migration. Quand même les lots ne peuvent pas rester verts isolément, garder la séquence mais leur faire partager une branche d'intégration, que tous bloquent jusqu'à un ticket final d'intégration et vérification ; le vert n'est promis que là.

### 4. Passer l'utilisateur au gril

Présenter le découpage proposé sous forme de liste numérotée. Pour chaque ticket, montrer :

- **Titre** : nom court et descriptif
- **Bloqué par** : quels autres tickets (le cas échéant) doivent être terminés d'abord
- **Ce qu'il livre** : le comportement de bout en bout que ce ticket rend fonctionnel

Demander à l'utilisateur :

- La granularité te semble-t-elle juste ? (trop grossière / trop fine)
- Les arêtes de blocage sont-elles correctes : chaque ticket ne dépend-il que de tickets qui le conditionnent réellement ?
- Faut-il fusionner ou redécouper certains tickets ?

Itérer jusqu'à ce que l'utilisateur valide le découpage.

### 5. Publier les tickets dans le tracker configuré

Publier les tickets validés. **Comment** dépend du tracker configuré par `/setup-sdlc` ; les tickets sont les mêmes dans les deux cas, seule la forme des arêtes de blocage change :

- **Fichiers locaux** → écrire un fichier par ticket sous `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numérotés à partir de `01` dans l'ordre des dépendances (les bloqueurs d'abord). Le « Bloqué par » de chaque fichier liste les numéros ou titres dont il dépend. Utiliser le gabarit par ticket ci-dessous : un ticket par fichier, jamais un fichier unique regroupant tout.
- **Un vrai issue tracker (GitHub, Linear, …)** → publier une issue par ticket dans l'ordre des dépendances (les bloqueurs d'abord), pour que les arêtes de blocage de chaque ticket puissent référencer de vrais identifiants. Utiliser la relation native de blocage / sous-issue de la plateforme quand elle existe ; sinon, renseigner le « Bloqué par » de chaque ticket avec les issues bloquantes. Appliquer le label de triage `ready-for-agent` sauf instruction contraire ; les tickets sont saisissables par un agent par construction.

Travailler la **frontière** : tout ticket dont les bloqueurs sont tous terminés. Pour une chaîne purement linéaire, cela revient à descendre de haut en bas.

Ne PAS fermer ni modifier une issue parente.

<local-ticket-template>

# <NN> : <Titre du ticket>

**À construire :** le comportement de bout en bout que ce ticket rend fonctionnel, du point de vue de l'utilisateur — pas une liste d'implémentation couche par couche.

**Bloqué par :** les numéros ou titres des tickets qui conditionnent celui-ci, ou « Aucun (peut démarrer immédiatement) ».

**Status:** ready-for-agent

- [ ] Critère d'acceptation 1
- [ ] Critère d'acceptation 2

</local-ticket-template>

<issue-template>

## Parent

Une référence à l'issue parente dans le tracker (si la source était une issue existante, sinon omettre cette section).

## À construire

Le comportement de bout en bout que ce ticket rend fonctionnel, du point de vue de l'utilisateur — pas une implémentation couche par couche.

## Critères d'acceptation

- [ ] Critère 1
- [ ] Critère 2

## Bloqué par

- Une référence à chaque ticket bloquant, ou « Aucun (peut démarrer immédiatement) ».

</issue-template>

Dans les deux formes, éviter les chemins de fichiers précis et les extraits de code : ils deviennent obsolètes vite. Exception : si un prototype a produit un extrait qui encode une décision plus précisément que la prose ne le pourrait (machine à états, reducer, schéma, forme d'un type), l'inclure et noter brièvement qu'il vient d'un prototype. Ne garder que les parties porteuses de décision — pas une démo qui tourne, juste l'essentiel.

Une fois les tickets publiés, **annoncer à l'utilisateur les commandes exactes à taper** pour les tickets de la frontière : `/implement .scratch/<feature-slug>/issues/<NN>-<slug>.md` — le chemin complet — sur le tracker markdown local, `/implement <numéro d'issue>` sur un vrai tracker. Le slug ne survit pas au `/clear` qui suit : il doit voyager dans la commande.

## Ensuite

`/clear`, puis `/implement`, **un ticket à la fois**, dans l'ordre de la frontière — les tickets dont tous les bloqueurs sont terminés, la frontière étant rejouée après chaque ticket clos. Le `/clear` n'est pas une hygiène facultative : chaque ticket est autoportant, donc le contexte du découpage est jetable, et le garder ne fait que ronger la fenêtre du ticket suivant.
