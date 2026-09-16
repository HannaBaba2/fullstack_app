# Fullstack App — Projet de certification Flutter

Application Flutter connectee a de vraies APIs REST publiques, avec authentification JWT,
architecture Feature-First / Clean, cache local (Hive) et mode hors-ligne.

## Sommaire
- [Fonctionnalites](#fonctionnalites)
- [APIs utilisees](#apis-utilisees)
- [Architecture](#architecture)
- [Gestion du reseau et des tokens](#gestion-du-reseau-et-des-tokens)
- [Cache local et mode hors-ligne](#cache-local-et-mode-hors-ligne)
- [Installation et configuration](#installation-et-configuration)
- [Lancer les tests](#lancer-les-tests)
- [Identifiants de demo](#identifiants-de-demo)
- [Limites connues](#limites-connues)

## Fonctionnalites

- **Authentification** (login / register / logout) avec token type JWT, persiste localement.
- **3 ecrans de donnees** issues d'une API REST : Posts, Albums, Todos.
- **Cache local** avec Hive : chaque liste recuperee est mise en cache automatiquement.
- **Mode hors-ligne** : si le reseau est indisponible, l'app affiche les dernieres donnees
  connues avec une banniere "Hors ligne — donnees en cache affichees".
- **Gestion d'erreurs reseau** : messages utilisateur clairs (pas de connexion, erreur serveur,
  session expiree) avec bouton "Reessayer".

## APIs utilisees

| Usage | API | Base URL |
|---|---|---|
| Authentification (JWT simule) | [reqres.in](https://reqres.in) | `https://reqres.in` |
| Donnees (Posts / Albums / Todos) | [JSONPlaceholder](https://jsonplaceholder.typicode.com) | `https://jsonplaceholder.typicode.com` |

Ces deux APIs publiques et gratuites (aucune cle requise) ont ete choisies pour que le projet
soit **immediatement testable** sans configuration de compte ou de cle API. La configuration
se trouve dans un seul fichier : `lib/core/network/dio_client.dart` (classe `ApiConfig`) — il
suffit de changer les `baseUrl` pour brancher un backend reel (le vôtre, OpenWeatherMap, TMDB…).

> Note : JSONPlaceholder n'impose pas d'authentification reelle. Le token JWT recupere via
> reqres.in est neanmoins injecte sur **chaque** appel vers cette API (voir `AuthInterceptor`)
> afin de demontrer le mecanisme d'intercepteur tel qu'il fonctionnerait sur un vrai backend
> protege.

## Architecture

Architecture **Feature-First**, chaque feature suit la Clean Architecture en 3 couches :

```
lib/
├── core/                        # Code transverse, partage par toutes les features
│   ├── di/injector.dart         # Injection de dependances (get_it)
│   ├── error/                   # exceptions.dart (data) + failures.dart (domain/UI)
│   ├── network/                 # DioClient, AuthInterceptor, NetworkInfo
│   ├── storage/token_storage.dart
│   └── utils/                   # Result<T> (Either-like), DataWithSource<T>
│
├── app/                         # Shell de navigation (AuthGate, HomeShell, widgets partages)
│
└── features/
    ├── auth/
    │   ├── data/                # datasources (remote + local), models, repository impl
    │   ├── domain/               # entities, repository (interface), usecases
    │   └── presentation/         # provider (state), screens
    ├── posts/     (meme structure)
    ├── albums/    (meme structure)
    └── todos/     (meme structure)
```

**Flux de dependance** (regle de la Clean Architecture, toujours respectee) :

```
presentation  →  domain  ←  data
   (UI)         (interfaces)   (implementations)
```

- `domain/` ne depend de rien d'externe (pas de Dio, pas de Hive) : uniquement des entites et
  des interfaces (`XxxRepository`). C'est la couche testable et stable.
- `data/` implemente les interfaces du domain via des **datasources** (`remote` = API,
  `local` = Hive) et un **repository** qui orchestre les deux (repository pattern).
- `presentation/` consomme les use cases du domain via un `ChangeNotifier` (Provider).

### Repository pattern

Chaque repository (`PostsRepositoryImpl`, `AlbumsRepositoryImpl`, `TodosRepositoryImpl`,
`AuthRepositoryImpl`) est le seul point d'entree pour les donnees : il decide s'il faut appeler
le reseau, alimenter le cache, ou repartir sur le cache en cas d'erreur/absence de reseau. Ni
l'UI ni le domain ne savent que Dio ou Hive existent.

### Gestion des erreurs -> `Result<T>`

Pour eviter les exceptions qui remontent jusqu'a l'UI, un type `Result<T>` (equivalent simplifie
d'un `Either<Failure, T>`) est utilise partout :

```dart
Future<Result<DataWithSource<List<Post>>>> getPosts();
```

`Result.fold(onError, onSuccess)` est appele depuis les providers pour transformer proprement
une erreur en message affichable.

## Gestion du reseau et des tokens

- `lib/core/network/dio_client.dart` : deux instances Dio (une pour l'auth, une pour les
  donnees), enregistrees separement dans `get_it` (`instanceName: 'authDio' / 'dataDio'`).
- `lib/core/network/auth_interceptor.dart` :
  - **injecte** `Authorization: Bearer <token>` sur chaque requete sortante vers l'API de
    donnees ;
  - **intercepte les 401**, tente un **refresh du token**, rejoue la requete originale en cas
    de succes, et sinon force une deconnexion propre (`AuthProvider.forceLogout()`).
  - Le backend de demo (reqres.in) n'exposant pas de vrai endpoint `/refresh`, la methode
    `_attemptRefresh()` simule le renouvellement en rappelant `/api/login`. Le reste du flux
    (retry, queue, deconnexion sur echec) est directement reutilisable avec un vrai endpoint de
    refresh token.

## Cache local et mode hors-ligne

- **Hive** est utilise (pas de generation de code necessaire : les modeles sont serialises en
  `Map<String, dynamic>` avant stockage, via `toJson()` / `fromJson()`).
- Une box Hive dediee par feature : `posts_cache_box`, `albums_cache_box`, `todos_cache_box`,
  plus `auth_box` pour la session (token / refresh token / email).
- Logique de chaque repository :
  1. Verifie la connectivite (`NetworkInfo`, base sur `connectivity_plus`).
  2. Si connecte : appelle l'API, **met a jour le cache**, retourne les donnees fraiches
     (`isFromCache: false`).
  3. Si non connecte, ou si l'appel API echoue : retombe sur le cache Hive
     (`isFromCache: true`) et l'UI affiche la banniere hors-ligne.
  4. Si le cache est vide egalement : retourne un `Failure` explicite affiche a l'utilisateur
     avec un bouton "Reessayer".

## Installation et configuration

### Prerequis
- Flutter SDK ≥ 3.19 (Dart ≥ 3.0)
- Un emulateur/simulateur ou un appareil physique

### Etapes

```bash
git clone <url-du-repo>
cd fullstack_app
flutter pub get
flutter run
```

Aucune cle API n'est necessaire : les deux backends utilises (reqres.in et JSONPlaceholder)
sont publics et gratuits. Pour brancher votre propre backend, modifiez uniquement
`lib/core/network/dio_client.dart` (`ApiConfig.authBaseUrl` / `ApiConfig.dataBaseUrl`) et
adaptez les payloads dans `auth_remote_datasource.dart` si besoin.

## Lancer les tests

```bash
flutter test
```

3 fichiers de tests unitaires couvrent la couche repository (avec `mocktail` pour simuler les
datasources et le `NetworkInfo`) :

- `test/features/auth/data/repositories/auth_repository_impl_test.dart`
- `test/features/posts/data/repositories/posts_repository_impl_test.dart`
- `test/features/todos/data/repositories/todos_repository_impl_test.dart`

Scenarios couverts : succes reseau, absence de reseau (fallback cache), erreur serveur avec et
sans cache disponible, identifiants invalides (401), session non renouvelable.

## Identifiants de demo

L'ecran de connexion est pre-rempli avec un compte de demo valide sur reqres.in :

```
email:    eve.holt@reqres.in
password: cityslicka
```

## Limites connues

- JSONPlaceholder n'appliquant pas reellement l'authentification, le 401/refresh-token n'est
  observable qu'en simulant une erreur (l'interceptor et son test unitaire couvrent cependant le
  comportement attendu).
- Pas de generation de code (`build_runner`/`hive_generator`) : les modeles Hive sont stockes en
  `Map` brute pour garder le projet simple a builder sans etape de generation supplementaire.
