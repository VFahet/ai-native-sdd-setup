# Quand mocker

Mocker uniquement aux **frontières du système** :

- API externes (paiement, e-mail, etc.)
- Bases de données (parfois — préférer une base de test)
- Le temps et l'aléatoire
- Le système de fichiers (parfois)

Ne pas mocker :

- Tes propres classes et modules
- Les collaborateurs internes
- Tout ce que tu contrôles

## Concevoir pour la mockabilité

Aux frontières du système, concevoir des interfaces faciles à mocker :

**1. Utiliser l'injection de dépendances**

Passer les dépendances externes en paramètre plutôt que de les créer en interne :

```typescript
// Facile à mocker
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Difficile à mocker
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. Préférer les interfaces façon SDK aux fetchers génériques**

Créer une fonction spécifique par opération externe, plutôt qu'une fonction générique avec de la logique conditionnelle :

```typescript
// BON : chaque fonction est mockable indépendamment
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// MAUVAIS : mocker impose de la logique conditionnelle dans le mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

L'approche SDK signifie :
- Chaque mock renvoie une forme unique et précise
- Aucune logique conditionnelle dans la mise en place du test
- On voit plus facilement quels endpoints un test exerce
- Le typage est sûr par endpoint
