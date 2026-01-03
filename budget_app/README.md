# Budget App - Application Mobile de Gestion de Budget

**Développé par:** Hassiatou Souley & Essonam Maximin  
**Année universitaire:** 2024-2025  
**Technologies:** Flutter + Supabase

## 📱 Description

Application mobile permettant de gérer ses finances personnelles de manière simple et intuitive. Elle offre un suivi des dépenses, des revenus et une visualisation graphique du budget mensuel.

## ✨ Fonctionnalités

- **Dashboard** - Vue d'ensemble du budget avec solde, revenus et dépenses
- **Transactions** - Historique complet avec tri par date
- **Ajouter Dépense/Revenu** - Formulaires simples avec catégories
- **Statistiques** - Graphiques circulaire et linéaire
- **Conseils** - Conseils de gestion financière
- **Paramètres** - Profil et déconnexion

## 🚀 Installation

### Prérequis

- Flutter SDK (3.35+)
- Android Studio ou VS Code
- Un compte Supabase

### 1. Cloner le projet

```bash
cd C:\Users\Hassiatou\Desktop\mobile
cd budget_app
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Configurer Supabase

1. Créez un projet sur [supabase.com](https://supabase.com)
2. Allez dans **SQL Editor** et exécutez le contenu de `supabase_setup.sql`
3. Allez dans **Settings > API** et copiez:
   - Project URL
   - anon/public key

4. Modifiez `lib/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'VOTRE_URL_SUPABASE';
  static const String supabaseAnonKey = 'VOTRE_ANON_KEY';
}
```

### 4. Lancer l'application

```bash
flutter run
```

## 📁 Structure du projet

```
lib/
├── main.dart                 # Point d'entrée
├── config/
│   └── supabase_config.dart  # Configuration Supabase
├── models/
│   ├── category.dart         # Modèle catégorie
│   ├── transaction_model.dart # Modèle transaction
│   └── user.dart             # Modèle utilisateur
├── providers/
│   ├── auth_provider.dart    # Gestion authentification
│   └── transaction_provider.dart # Gestion transactions
├── services/
│   ├── auth_service.dart     # Service auth Supabase
│   ├── category_service.dart # Service catégories
│   └── transaction_service.dart # Service transactions
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── dashboard_screen.dart
│   ├── add_expense_screen.dart
│   ├── add_income_screen.dart
│   ├── transactions_screen.dart
│   ├── stats_screen.dart
│   ├── tips_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── budget_summary.dart
│   ├── transaction_card.dart
│   ├── category_chip.dart
│   └── chart_widgets.dart
└── theme/
    └── app_theme.dart        # Thème sombre fintech
```

## 🎨 Design

- **Thème:** Sombre style fintech
- **Couleurs:**
  - Fond: `#0D0D0D`, `#1A1A2E`
  - Revenus: `#00D09C` (vert néon)
  - Dépenses: `#FF6B6B` (rouge corail)
- **Police:** Poppins

## 📊 Base de données Supabase

### Tables

| Table | Description |
|-------|-------------|
| `categories` | Catégories de transactions (ex: Nourriture, Salaire) |
| `transactions` | Transactions avec montant, type, date |

### Sécurité (RLS)

Row Level Security activé - chaque utilisateur ne voit que ses propres données.

## 📦 Dépendances

| Package | Usage |
|---------|-------|
| supabase_flutter | Backend & Auth |
| provider | State management |
| fl_chart | Graphiques |
| intl | Formatage dates/nombres |
| google_fonts | Typographie |

## 🧪 Lancer les tests

```bash
flutter test
```

## 📱 Générer l'APK

```bash
flutter build apk --release
```

L'APK sera dans `build/app/outputs/flutter-apk/app-release.apk`

## 📄 License

Projet universitaire - 2024-2025
