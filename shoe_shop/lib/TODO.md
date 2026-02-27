# TODO: Implement Per-User Favorite Shoes

## Overview
Modify the app to allow each user to have their own list of favorite shoes, stored per-user in Firestore.

## Steps
- [ ] Update FavoriteProvider to use per-user favorites collection (`favorites/{uid}/items`)
- [ ] Update FavoritelistScreen to query user's personal favorites
- [ ] Add FavoriteProvider to main.dart providers
- [ ] Update shoe_card.dart and shoe_detail_screen.dart to use updated FavoriteProvider
- [ ] Test the implementation

## Current Status
- FavoriteProvider currently uses global `shoes.is_favorite` field
- Need to migrate to per-user storage like CartProvider
