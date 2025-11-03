# foodly - Pantry Manager

A minimal, Material 3-compliant Flutter app for kitchen pantry management and discovering recipes based on available ingredients.

## Features

-  **Barcode Scanning**: Real-time barcode recognition using device camera (mobile_scanner)
-  **Product Search**: Search foods by name via Open Food Facts API
-  **Recipe Suggestions**: Get recipes based on stored ingredients (Spoonacular API)
-  **Expiry Tracking**: Monitor expiring and expired foods with visual indicators

## APIs Used

### 1. Open Food Facts
- **Endpoint**: `https://world.openfoodfacts.org/api/v0`
- **Features**: Barcode lookup
- **Auth**: No authentication required

### 2. Spoonacular
- **Endpoint**: `https://api.spoonacular.com/recipes/findByIngredients`
- **Features**: Recipe suggestions by ingredients
- **Auth**: API key required (set in `.env`)
- **Get Key**: https://spoonacular.com/food-api

## API Limitations

### Spoonacular API Constraints
- **Free Tier**: With free tier plan you have 50 points per day then no more calls
- **API Cost**: Calling the endpoint requires 1 point and 0.01 points per recipe returned.
- **Recipe Search Limit**: between 1 and 100 results per request

