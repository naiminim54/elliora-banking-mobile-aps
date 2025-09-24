# Cahier des charges — Version Mobile (Flutter)

le projet est déja créer /aps_mobile
---

## 1️⃣ Objectif (mobile)

Construire une **application mobile Flutter** qui reproduit les mêmes fonctionnalités que la version web :

* Authentification (mock)
* Consultation des comptes
* Consultation des transactions (recherche, tri, pagination, filtres)
* Initiation d’un virement (mêmes validations et confirmation)
* Feedback utilisateur clair (success / error)

Aucun nouvel écran ni fonctionnalité supplémentaire — juste adaptation mobile du dashboard actuel.

---

## 2️⃣ Stack technique (mobile)

* **Flutter** (version stable recommandée — compatible avec null-safety)
* **Dart** (version correspondante)
* Packages minimaux nécessaires :

  * `http` — pour appeler les mêmes endpoints mock (GET/POST).
  * `intl` — formatage monnaie/date (XAF).
  * `shared_preferences` — stockage simple du token (équivalent localStorage).
  * `flutter_test` — tests unitaires.
* Animations : API Flutter native (AnimatedContainer, showModalBottomSheet, etc.).
* Notifications/toasts : `ScaffoldMessenger` / `SnackBar` (équivalent Sonner).

> Remarque : j’utilise uniquement des outils Flutter standards et indispensables pour respecter *exactement* le cahier de charges web.

---

## 3️⃣ Comportement & UX (strictement équivalent au web)

* **Login**

  * Formulaire username/password.
  * POST `/api/auth/login` (même shape).
  * Stockage du token en `shared_preferences`.
  * Redirection vers l’écran Dashboard mobile.
  * En cas d’erreur : `SnackBar` rouge.
* **Dashboard (écran principal mobile)**

  * Affiche cartes de comptes (solde formaté en XAF).
  * Chaque carte propose deux actions : **Voir transactions** et **Faire un virement**.
  * Le Dashboard mobile reprend la logique et contenu des `AccountCard.tsx` sans ajouter d’éléments.
* **Transactions (écran / modal)**

  * Récupère `GET /api/accounts/:accountId/transactions`.
  * Affiche la liste (liste virtuelle / `ListView.builder`).
  * Fonctions : recherche texte, tri (date / montant), filtres (date range, type débit/crédit), pagination (client ou simulée côté mobile — même comportement que web).
  * Loader, empty state, erreurs -> `SnackBar`.
* **Virement**

  * Formulaire : compte source (picker), numéro bénéficiaire, montant.
  * Validations identiques : montant > 0, montant ≤ solde du compte source.
  * Confirmation récapitulative (modal) avant envoi.
  * POST `/api/transfer`. Gérer success / error et afficher `SnackBar`.
  * Animation modal / transition via widgets Flutter natifs.
* **Gestion erreurs**

  * Afficher erreurs réseau, erreurs validation, loader et empty states comme sur le web.
* **Internationnalisation / Format**

  * Montants formatés en XAF via `intl.NumberFormat.currency(locale: 'fr_CM', name: 'XAF')` (ou locale appropriée).
* **Comportement réseau**

  * Réutiliser exactement les endpoints mock fournis par le backend Next.js (pas de changements d’API).
  * Même gestion des codes d’erreur (401, 400, etc.) et mêmes messages.

---

## 4️⃣ Structure projet Flutter (correspondance avec structure web)

```
/lib
  /api
    api_client.dart         // fonctions utilitaires fetch (GET/POST)
  /auth
    auth_service.dart       // login, token get/set (shared_preferences)
    login_page.dart         // écran login
  /screens
    dashboard_page.dart     // écran principal -> liste cartes comptes
    transactions_page.dart  // écran liste transactions + filtres
    transfer_page.dart      // écran/formulaire virement (modal)
  /widgets
    account_card.dart       // composant carte de compte
    transactions_list.dart  // widget liste transactions (recherche/tri/filtre/pagination)
    transfer_confirm.dart   // modal récapitulatif
  /utils
    format.dart             // formatters (currency, date)
    validate.dart           // validation (montant etc.)
  main.dart                 // route initiale / injection services
/tests
  validate_transfer_test.dart
  format_currency_test.dart
README.md
time_log.txt
```

> Cette arborescence **reproduit fidèlement** la structure logique du repo Web fournie dans ton cahier de charge.

---

## 5️⃣ API à utiliser (identique au Web — *même contrats*)

Tu réutilises **tel quel** les endpoints mock du web :

1. **POST** `/api/auth/login`

   * Request body: `{ username, password }`
   * Réponse mock attendue: token + user (ou 401)

2. **GET** `/api/accounts`

   * Retourne liste comptes `{ id, type, currency, balance }`

3. **GET** `/api/accounts/:accountId/transactions`

   * Retourne `{ items, page, pageSize, total }` (mêmes champs)

4. **POST** `/api/transfer`

   * Body: `{ fromAccountId, toAccountNumber, amount }`
   * Réponse mock: `{ transferId, status, estimatedCompletion }` ou erreur 400

> Aucun changement des endpoints, payloads ou codes de réponse — strictement conforme au cahier de charge.

---

## 6️⃣ Composants / Widgets clés (mapping avec composants web)

* `AccountCard` → `account_card.dart` : affiche solde, boutons “Voir transactions” et “Faire un virement”.
* `TransactionsList` → `transactions_list.dart` : recherche, tri, filtres, pagination.
* `TransferModal` → implémenté comme un `showModalBottomSheet` ou `Dialog` (`transfer_page.dart` + `transfer_confirm.dart`).
* `Toasts` Sonner → remplacés par `SnackBar` (même rôle, mêmes messages).

---

## 7️⃣ Validation & Tests unitaires (même que web)

* `tests/validate_transfer_test.dart`

  * Tester la fonction Dart dans `validate.dart` : rejeter montants invalides (> solde, ≤ 0).
* `tests/format_currency_test.dart`

  * Tester `format.dart` : affichage montant en XAF identique au web.

Commandes de test : `flutter test`

---

## 8️⃣ Documentation exigée (README + time\_log)

README.md (doit contenir **exactement** les mêmes éléments que la version Web, adaptés à Flutter) :

* Setup : Flutter stable (SDK), `flutter pub get`, `flutter run`, `flutter test`
* Description API mock (mêmes endpoints et exemples de payloads)
* Instructions pour lancer les tests
* Lien vidéo démo (si tu fournis)
* `time_log.txt` : détail heures de travail

---

## 9️⃣ Contraintes et règles à respecter (strictement)

* **Ne pas ajouter** de fonctionnalité non présente dans le cahier de charge web.
* **Ne pas modifier** les endpoints, structures de réponses ou règles de validation.
* **Ne pas créer** un “nouveau” dashboard séparé — il faut **adapter / modifier** l’écran Dashboard actuel pour supporter mobile (re-usage de la logique métier et des mêmes données).
* UI/UX mobile doit rester une **transposition** (responsive/optimisée) du contenu et du flux existant.
* Tests unitaires : mêmes scénarios que sur web.
