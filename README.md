# Geo Composer 🗺️

[![GitHub](https://img.shields.io/badge/GitHub-mael50%2Fgeo--composer-blue?logo=github)](https://github.com/mael50/geo-composer)

**Geo Composer** est une application web moderne permettant de **sélectionner des communes françaises** et de générer des **zones géographiques personnalisées** (fichiers GeoJSON) en fusionnant leurs contours.

Idéal pour créer des zones de chalandise, des secteurs d'intervention ou des découpages territoriaux sur mesure.

🔗 **Lien du projet :** [https://github.com/mael50/geo-composer](https://github.com/mael50/geo-composer)

---

## 🚀 Fonctionnalités

- **Carte interactive** : Navigation fluide avec `Leaflet`.
- **Sélection flexible** :
  - **Clic** : Sélectionnez des communes individuellement.
  - **Pinceau (Brush Mode)** : Dessinez sur la carte pour sélectionner rapidement de multiples communes.
  - **Par département** : Chargez et sélectionnez des départements entiers.
- **Fusion intelligente** : Utilise `Turf.js` pour fusionner les géométries des communes sélectionnées en un seul polygone.
- **Export GeoJSON** : Téléchargez votre zone créée pour l'utiliser dans d'autres outils SIG (QGIS, Google Earth, etc.).
- **Interface Moderne** : Construit avec **Nuxt 4** et **Nuxt UI**.

## 🛠️ Stack Technique

- **Framework** : [Nuxt 4](https://nuxt.com) (Vue 3)
- **UI Module** : [Nuxt UI](https://ui.nuxt.com)
- **Cartographie** : [Leaflet](https://leafletjs.com) & [Leaflet-Draw](https://github.com/Leaflet/Leaflet.draw)
- **Manipulation Géo** : [Turf.js](https://turfjs.org)
- **Données** : [API Géo (Etalab)](https://geo.api.gouv.fr)

## 📦 Installation & Utilisation

### Prérequis
- Node.js 20+ (si exécution locale)
- Docker (optionnel)

### Via Docker (Recommandé)

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/mael50/geo-composer.git
   cd geo-composer
   ```

2. Lancez l'application :
   ```bash
   docker compose up --build
   ```

3. Accédez à l'application sur [http://localhost:3000](http://localhost:3000).

### En Local (Développement)

1. Installez les dépendances :
   ```bash
   npm install
   ```

2. Lancez le serveur de développement :
   ```bash
   npm run dev
   ```

3. Ouvrez [http://localhost:3000](http://localhost:3000).

## 📝 Utilisation

1. **Charger un département** : Utilisez la barre latérale pour choisir un département français.
2. **Sélectionner des communes** :
   - Cliquez sur les communes sur la carte.
   - Activez le mode "Pinceau" (touche `B` ou icône dans la barre d'outils) pour peindre une sélection.
3. **Gérer la sélection** : Vous pouvez tout sélectionner dans le département ou vider la sélection.
4. **Télécharger** : Cliquez sur le bouton "Télécharger GeoJSON" pour obtenir votre zone fusionnée.

## 🤝 Contribuer

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une Pull Request sur le dépôt [GitHub](https://github.com/mael50/geo-composer).

---
*Créé avec ❤️ par Maël.*
