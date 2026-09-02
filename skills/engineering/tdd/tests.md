# Bons et mauvais tests

## Bons tests

**Style intégration** : tester à travers de vraies interfaces, pas des mocks de parties internes.

```typescript
// BON : teste un comportement observable
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Caractéristiques :

- Teste un comportement qui intéresse les utilisateurs ou les appelants
- N'utilise que l'API publique
- Survit aux refactors internes
- Décrit le QUOI, pas le COMMENT
- Une assertion logique par test

## Mauvais tests

**Tests de détails d'implémentation** : couplés à la structure interne.

```typescript
// MAUVAIS : teste des détails d'implémentation
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Signaux d'alerte :

- Mocker des collaborateurs internes
- Tester des méthodes privées
- Faire des assertions sur le nombre ou l'ordre des appels
- Le test casse lors d'un refactor sans changement de comportement
- Le nom du test décrit le COMMENT plutôt que le QUOI
- Vérifier par un moyen externe au lieu de passer par l'interface

```typescript
// MAUVAIS : contourne l'interface pour vérifier
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// BON : vérifie à travers l'interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**Tests tautologiques** : la valeur attendue redit l'implémentation, donc le test passe par construction.

```typescript
// MAUVAIS : la valeur attendue est recalculée comme le code la calcule
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// BON : la valeur attendue est un littéral indépendant et connu
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```
