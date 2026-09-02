# Format de CONTEXT.md

## Structure

```md
# {Nom du contexte}

{Une ou deux phrases décrivant ce qu'est ce contexte et pourquoi il existe.}

## Vocabulaire

**Commande** :
{Une ou deux phrases décrivant le terme}
_À éviter_ : Achat, transaction

**Facture** :
Un document réclamant un paiement, envoyé à un client après la livraison.
_À éviter_ : Note, demande de paiement

**Client** :
Une personne ou une organisation qui passe des commandes.
_À éviter_ : Acheteur, compte, contact
```

## Règles

- **Avoir un avis tranché.** Quand plusieurs mots existent pour le même concept, choisir le meilleur et lister les autres sous `_À éviter_`.
- **Garder des définitions serrées.** Une ou deux phrases maximum. Définir ce que la chose EST, pas ce qu'elle fait.
- **N'inclure que les termes propres au contexte de ce projet.** Les concepts généraux de programmation (timeouts, types d'erreur, patterns utilitaires) n'y ont pas leur place, même si le projet les utilise abondamment. Avant d'ajouter un terme, se demander : est-ce un concept propre à ce contexte, ou un concept général de programmation ? Seul le premier a sa place.
- **Grouper les termes sous des sous-titres** quand des regroupements naturels émergent. Si tous les termes relèvent d'un seul domaine cohérent, une liste à plat convient.

## Dépôts mono-contexte ou multi-contexte

**Mono-contexte (la plupart des dépôts) :** un seul `CONTEXT.md` à la racine du dépôt.

**Multi-contexte :** un `CONTEXT-MAP.md` à la racine du dépôt liste les contextes, où ils vivent, et comment ils se relient entre eux :

```md
# Carte des contextes

## Contextes

- [Commandes](./src/commandes/CONTEXT.md) : reçoit et suit les commandes des clients
- [Facturation](./src/facturation/CONTEXT.md) : génère les factures et traite les paiements
- [Logistique](./src/logistique/CONTEXT.md) : gère la préparation en entrepôt et l'expédition

## Relations

- **Commandes → Logistique** : Commandes émet des événements `OrderPlaced` ; Logistique les consomme pour lancer la préparation
- **Logistique → Facturation** : Logistique émet des événements `ShipmentDispatched` ; Facturation les consomme pour générer les factures
- **Commandes ↔ Facturation** : types partagés pour `CustomerId` et `Money`
```

Le skill déduit la structure qui s'applique :

- Si `CONTEXT-MAP.md` existe, le lire pour trouver les contextes
- S'il n'existe qu'un `CONTEXT.md` à la racine, c'est un dépôt mono-contexte
- Si aucun des deux n'existe, créer paresseusement un `CONTEXT.md` à la racine quand le premier terme est tranché

Quand plusieurs contextes existent, déduire celui auquel le sujet en cours se rattache. Si ce n'est pas clair, demander.
