---
name: to-questionnaire
description: "Transforme une décision que l'utilisateur ne peut pas trancher seul en un questionnaire Markdown, destiné à la personne qui détient le contexte manquant."
disable-model-invocation: true
---

Transformer ce que l'utilisateur ne peut pas trancher seul en **questionnaire** : un document Markdown qu'il remet à une personne, à remplir en asynchrone ou à parcourir ensemble en réunion. Le destinataire détient une connaissance qui manque à l'utilisateur ; le questionnaire va la chercher.

**Griller l'envoi, pas le sujet.** N'interviewer l'utilisateur que sur l'**envoi**, à quoi il peut toujours répondre : à qui le document part, et ce dont il a besoin en retour. Les questions du document visent ensuite l'**écart** entre ce que sait le destinataire et ce dont l'utilisateur a besoin.

1. **À qui part-il ?** Demander, en un seul échange, le rôle du destinataire, son expertise et sa relation à l'utilisateur. C'est ce qui fixe le ton du questionnaire et la quantité de contexte qu'il doit porter. Terminé quand tu sais qui est le destinataire et ce qu'il sait que l'utilisateur ignore.

2. **De quoi as-tu besoin en retour ?** Demander, en un seul échange, les décisions ou les faits précis que l'utilisateur ne peut pas résoudre seul et qu'il attend de cette personne. Terminé quand tu tiens une liste concrète de ce que l'utilisateur doit pouvoir faire ou décider en repartant.

3. **Écrire le questionnaire.** Rédiger les questions qui visent l'écart établi aux étapes 1 et 2, en suivant la structure ci-dessous. L'écrire dans `to-questionnaire-<slug>.md` dans le répertoire courant (le slug vient du sujet) et annoncer le chemin. Terminé quand le fichier existe et que chaque élément nommé à l'étape 2 est couvert par une question.

## Structure du document

Cadrer le document comme un **questionnaire de découverte** : l'utilisateur manque de contexte, le destinataire le détient. Ordonner les questions de la plus importante à la moins importante — l'asynchrone ne donne souvent qu'une seule passe — et les grouper sous des titres `##` par thème dès qu'il y en a plus d'une poignée. Écrire le document avec le gabarit ci-dessous.

<questionnaire-template>

# <Titre du questionnaire>

**Objet :** pourquoi ce questionnaire existe, et la décision qui en dépend.

**De :** <l'utilisateur>, **À :** <le destinataire>, **Usage de tes réponses :** <où elles vont>

## Contexte

Un paragraphe pour situer un destinataire qui n'était pas dans la tête de l'utilisateur. De quoi répondre correctement, pas une page.

## Comment répondre

Échéance et effort approximatif. Les réponses partielles et les « je ne sais pas » sont utiles : signaler ce dont on n'est pas sûr plutôt que de sauter la question.

## <Titre de thème>

Une section `##` par thème. Sous chacune, ses questions, la plus importante d'abord. Chaque question porte une seule idée, jamais deux, avec une amorce de réponse juste en dessous, et une ligne _pourquoi c'est important_ seulement là où la question pourrait être mal lue ou appeler une réponse expédiée.

<question-example>
### Quelle charge le système doit-il encaisser au lancement ?

_Pourquoi c'est important : cela décide si l'on provisionne pour des pics de trafic maintenant ou si on le reporte._

>
</question-example>

## Autre chose ?

Une question fourre-tout pour finir : y a-t-il quelque chose que nous n'avons pas demandé et que nous devrions savoir ?

</questionnaire-template>
