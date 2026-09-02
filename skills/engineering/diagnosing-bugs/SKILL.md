---
name: diagnosing-bugs
description: Boucle de diagnostic pour les bugs difficiles et les régressions de performance. À utiliser quand l'utilisateur dit « diagnostique ça » / « debug ça », ou signale quelque chose de cassé, qui plante, qui échoue ou qui est lent.
---

# Diagnostiquer les bugs

Une discipline pour les bugs difficiles. Ne sauter une phase que si c'est explicitement justifié.

En explorant le code, lire `CONTEXT.md` (s'il existe) pour se faire un modèle mental clair des modules concernés, et vérifier les ADR de la zone touchée.

## Caviarder

Ce skill t'amène à montrer des commandes, des sorties et des artefacts capturés. **Caviarder d'abord chaque secret** : écrire `<REDACTED>` à la place. Construire les boucles autour de variables d'environnement, pour que le secret reste dans l'environnement plutôt que dans ce que tu montres. Les artefacts capturés transportent des en-têtes d'authentification : ne citer que les lignes qui portent le signal.

Si la sortie caviardée ne suffit pas à diagnostiquer le bug, le dire et demander à l'utilisateur.

## Phase 1 : construire une boucle de feedback

**C'est ça, le skill.** Tout le reste est mécanique. Si tu as un signal pass/fail **serré** sur le bug (un signal qui vire au rouge sur _ce_ bug), tu trouveras la cause ; bissection, test d'hypothèses et instrumentation ne font que le consommer. Sans ce signal, tu auras beau contempler le code, rien ne te sauvera.

Y consacrer un effort disproportionné. **Être agressif. Être créatif. Refuser d'abandonner.**

### Façons d'en construire une, à peu près dans cet ordre

1. **Test qui échoue** au seam qui atteint le bug, quel qu'il soit : unitaire, intégration, e2e.
2. **Script curl / HTTP** sur un serveur de dev en marche.
3. **Invocation CLI** avec une entrée de fixture, en comparant stdout à un snapshot de référence.
4. **Script de navigateur headless** (Playwright / Puppeteer) qui pilote l'UI et fait des assertions sur le DOM / la console / le réseau.
5. **Rejouer une trace capturée.** Enregistrer sur disque une vraie requête réseau / payload / journal d'événements, puis la rejouer à travers le chemin de code, en isolation.
6. **Harnais jetable.** Monter un sous-ensemble minimal du système (un service, dépendances mockées) qui exerce le chemin de code du bug avec un seul appel de fonction.
7. **Boucle de propriétés / fuzzing.** Si le bug est « sortie parfois fausse », lancer 1000 entrées aléatoires et chercher le mode de défaillance.
8. **Harnais de bissection.** Si le bug est apparu entre deux états connus (commit, jeu de données, version), automatiser « démarrer à l'état X, vérifier, recommencer » pour pouvoir le passer à `git bisect run`.
9. **Boucle différentielle.** Passer la même entrée dans l'ancienne version puis dans la nouvelle (ou dans deux configs) et comparer les sorties par diff.
10. **Script bash HITL.** Dernier recours. Si un humain doit cliquer, c'est _lui_ qu'on pilote, avec `scripts/hitl-loop.template.sh`, pour que la boucle reste structurée. La sortie capturée te revient.

Construire la bonne boucle de feedback, et le bug est corrigé à 90 %.

### Resserrer la boucle

Traiter la boucle comme un produit. Une fois que tu as _une_ boucle, la **resserrer** :

- Puis-je la rendre plus rapide ? (Mettre en cache le setup, sauter les inits sans rapport, restreindre la portée du test.)
- Puis-je rendre le signal plus net ? (Faire l'assertion sur le symptôme précis, pas sur « ça n'a pas planté ».)
- Puis-je la rendre plus déterministe ? (Figer le temps, fixer la graine du RNG, isoler le système de fichiers, geler le réseau.)

Une boucle instable de 30 secondes vaut à peine mieux que pas de boucle ; une boucle déterministe de 2 secondes est serrée, un super-pouvoir de débogage.

### Bugs non déterministes

L'objectif n'est pas une reproduction propre mais un **taux de reproduction plus élevé**. Boucler le déclencheur 100×, paralléliser, mettre le système sous charge, réduire les fenêtres temporelles, injecter des sleeps. Un bug qui se manifeste une fois sur deux est débogable ; à 1 %, non — continuer à faire monter le taux jusqu'à ce qu'il le devienne.

### Quand tu ne peux vraiment pas construire de boucle

S'arrêter et le dire explicitement. Lister ce qui a été tenté. Demander à l'utilisateur : (a) l'accès à l'environnement qui reproduit le bug, (b) un artefact capturé et caviardé (fichier HAR, dump de logs, core dump, enregistrement d'écran horodaté), ou (c) l'autorisation d'ajouter une instrumentation temporaire en production. **Ne pas** passer aux hypothèses sans boucle.

### Critère de fin : une boucle serrée qui vire au rouge

La phase 1 est terminée quand la boucle est **serrée** et **capable de virer au rouge** : tu peux nommer **une commande** (un chemin de script, une invocation de test, un curl) que tu as **déjà lancée au moins une fois** (montrer l'invocation et sa sortie, caviardée), et qui est :

- [ ] **Capable de virer au rouge** : elle emprunte le vrai chemin de code du bug et fait l'assertion sur le **symptôme exact de l'utilisateur**, donc elle peut virer au rouge sur ce bug et repasser au vert une fois corrigé. Pas « ça tourne sans erreur » ; elle doit pouvoir _attraper ce bug précis_.
- [ ] **Déterministe** : même verdict à chaque exécution (bugs instables : un taux de reproduction élevé et stabilisé, cf. ci-dessus).
- [ ] **Rapide** : des secondes, pas des minutes.
- [ ] **Exécutable par l'agent** : tu peux la lancer sans surveillance ; un humain dans la boucle uniquement via `scripts/hitl-loop.template.sh`.

Si tu te surprends à lire du code pour bâtir une théorie avant que cette commande existe, **stop : sauter directement à une hypothèse est exactement l'échec que ce skill prévient.** Pas de commande capable de virer au rouge, pas de phase 2.

## Phase 2 : reproduire + minimiser

Lancer la boucle. La regarder virer au rouge quand le bug apparaît.

Confirmer :

- [ ] La boucle produit le mode de défaillance décrit par l'**utilisateur**, pas une autre défaillance qui se trouve à côté. Mauvais bug = mauvaise correction.
- [ ] La défaillance est reproductible sur plusieurs exécutions (ou, pour les bugs non déterministes, reproductible à un taux suffisant pour pouvoir déboguer).
- [ ] Tu as capturé le symptôme exact (message d'erreur, sortie fausse, temps de réponse lent) pour que les phases suivantes puissent vérifier que la correction le traite vraiment.

### Minimiser

Une fois au rouge, réduire la reproduction au **plus petit scénario qui vire encore au rouge**. Retirer entrées, appelants, config, données et étapes **une par une**, en relançant la boucle après chaque coupe, et ne garder que ce qui est porteur pour la défaillance.

Pourquoi s'embêter : une reproduction minimale rétrécit l'espace des hypothèses en phase 3 (moins de pièces mobiles à suspecter) et devient le test de non-régression propre en phase 5.

Terminé quand **chaque élément restant est porteur** : en retirer un seul fait repasser la boucle au vert.

Ne pas avancer tant que tu n'as pas reproduit **et** minimisé.

## Phase 3 : formuler des hypothèses

Produire **3 à 5 hypothèses classées** avant d'en tester la moindre. N'en générer qu'une seule ancre le raisonnement sur la première idée plausible.

Chaque hypothèse doit être **falsifiable** : énoncer la prédiction qu'elle produit.

> Format : « Si <X> est la cause, alors <changer Y> fera disparaître le bug / <changer Z> l'aggravera. »

Si tu ne peux pas énoncer la prédiction, l'hypothèse n'est qu'une intuition : la jeter ou l'affûter.

**Montrer la liste classée à l'utilisateur avant de tester.** Il a souvent une connaissance du domaine qui reclasse tout instantanément (« on vient justement de déployer un changement sur la n° 3 »), ou connaît des hypothèses déjà écartées. Point de contrôle peu coûteux, gros gain de temps. Ne pas bloquer dessus ; si l'utilisateur est absent, continuer avec ton classement.

## Phase 4 : instrumenter

Chaque sonde doit correspondre à une prédiction précise de la phase 3. **Ne changer qu'une variable à la fois.**

Préférence d'outils :

1. **Inspection au débogueur / REPL** si l'environnement le permet. Un point d'arrêt vaut dix logs.
2. **Logs ciblés** aux frontières qui départagent les hypothèses.
3. Jamais de « on logue tout et on grep ».

**Taguer chaque log de debug** avec un préfixe unique, par exemple `[DEBUG-a4f2]`. Le nettoyage final se réduit alors à un seul grep. Les logs non tagués survivent ; les logs tagués meurent.

**Variante perf.** Pour les régressions de performance, les logs sont en général le mauvais outil. À la place : établir une mesure de référence (harnais de chronométrage, `performance.now()`, profileur, plan de requête), puis bissecter. Mesurer d'abord, corriger ensuite.

## Phase 5 : corriger + test de non-régression

Écrire le test de non-régression **avant la correction**, mais seulement s'il existe un **seam correct** pour l'accueillir.

Un seam correct est un seam où le test exerce le **vrai motif du bug** tel qu'il se produit au site d'appel. Si le seul seam disponible est trop superficiel (test à un seul appelant alors que le bug en demande plusieurs, test unitaire incapable de reproduire la chaîne qui a déclenché le bug), un test de non-régression posé là donne une fausse confiance.

**S'il n'existe pas de seam correct, c'est en soi le constat.** Le noter. L'architecture du code empêche de verrouiller le bug. Le signaler pour la phase suivante.

S'il existe un seam correct :

1. Transformer la reproduction minimisée en test qui échoue à ce seam.
2. Le regarder échouer.
3. Appliquer la correction.
4. Le regarder passer.
5. Relancer la boucle de feedback de la phase 1 sur le scénario d'origine (non minimisé).

## Phase 6 : nettoyage

Obligatoire avant de déclarer terminé :

- [ ] La reproduction d'origine ne se reproduit plus (relancer la boucle de la phase 1)
- [ ] Le test de non-régression passe (ou l'absence de seam est documentée)
- [ ] Toute l'instrumentation `[DEBUG-...]` est retirée (`grep` sur le préfixe)
- [ ] Les prototypes jetables sont supprimés (ou déplacés dans un emplacement de debug clairement identifié)
- [ ] L'hypothèse qui s'est révélée juste est énoncée dans le message de commit / de PR, pour que le prochain à déboguer en apprenne quelque chose
