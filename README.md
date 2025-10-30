# Foodly - Food Inventory Manager

A minimal, Material 3-compliant Flutter app for managing food inventory and discovering recipes based on available ingredients.

## Features

-  **Barcode Scanning**: Real-time barcode recognition using device camera (mobile_scanner)
-  **Product Search**: Search foods by name via Open Food Facts API
-  **Recipe Suggestions**: Get recipes based on stored ingredients (Spoonacular API)
-  **Expiry Tracking**: Monitor expiring and expired foods with visual indicators

## APIs Used

### 1. Open Food Facts
- **Endpoint**: `https://world.openfoodfacts.org/api/v0`
- **Features**: Barcode lookup, product search
- **Auth**: No authentication required

### 2. Spoonacular
- **Endpoint**: `https://api.spoonacular.com/recipes`
- **Features**: Recipe suggestions by ingredients
- **Auth**: API key required (set in `lib/utils/constants.dart`)
- **Get Key**: https://spoonacular.com/food-api
