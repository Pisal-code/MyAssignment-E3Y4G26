# TODO: Implement Per-User Favorite Shoes

## Overview
Modify the app to allow each user to have their own list of favorite shoes, stored per-user in Firestore.

## Steps
- [x] Update FavoriteProvider to use per-user favorites collection (`favorites/{uid}/items`)
- [x] Update FavoritelistScreen to query user's personal favorites
- [x] Add FavoriteProvider to main.dart providers
- [x] Update shoe_card.dart to use updated FavoriteProvider
- [x] Update shoe_grid_card.dart to use updated FavoriteProvider
- [x] Update shoe_detail_screen.dart to use updated FavoriteProvider
- [x] Update login_screen.dart to initialize FavoriteProvider with user ID

## Firestore Structure
```
favorites/
  └── {userId}/
        └── items/
              ├── shoeId: "..."
              ├── name: "..."
              ├── price: 100
              ├── imageUrl: "..."
              └── addedAt: timestamp
```

## Completed ✓
All tasks have been implemented. Each user now has their own separate favorite list stored in Firestore under their unique user ID.

