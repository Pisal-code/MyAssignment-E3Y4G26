**👟 Shoe Shop Mobile Application**

Course: Mobile Application (RUPP)
Grade: E3Y4G26
Group: 7

===================================================================================================================================================================================================

**📱 Project Overview**

This project is a mobile e-commerce application developed using Flutter integrated with Firebase (Firestore API) as the backend service.

The application functions as a Shoe Shop, allowing users to browse products, add items to favorites, manage a shopping cart, and place orders. Firebase Firestore is used to provide real-time data synchronization, ensuring that all updates (add, remove, modify) are instantly reflected across devices while maintaining data consistency.

*****************************************************************************************
**🛠 Technologies Used**

- Flutter – Cross-platform mobile application development
- Firebase Authentication – User login and authentication
- Firebase Firestore – Real-time cloud database
  
*****************************************************************************************
**👥 Group Information**

**Group 7**

1. Pisal
2. Tra
3. Hongly
4. Piseth
5. Somnang
*****************************************************************************************

🔐 **Test User Accounts**

The following user accounts are available for testing:
=======================================================
Name	        Email	              Password
=======================================================
Pisal         sal@rupp.edu.kh     12345678
Tra	          tra@rupp.edu.kh     12345678
Hongly	      hongly@rupp.edu.kh  12345678
Piseth	      piseth@rupp.edu.kh  12345678
Somnang	      somnang@rupp.edu.kh 12345678
=======================================================

*****************************************************************************************

**🗄 Firestore Database Structure**

The application uses three main collections in Firebase Firestore:


1️⃣ Order Collection
- Stores all successfully placed orders.
- Each order is linked to the authenticated user.
- Contains order details such as selected shoes, total amount, and order status.

2️⃣ Shoe Collection
- Stores all product data.
- Includes fields such as:
    - Name
    - Category
    - Price
    - Description
    - Image path (stored as string)

3️⃣ User Collection
- Stores user profile information.
- Contains:
    - Name
    - Email
    - Profile image
    - Account-related details

**🔑 Firestore Access:**
The Firestore database is restricted for security purposes.
If access to the database is required, please contact:

📧 visalpon007@gmail.com

Authorization will be granted upon request.

✅ Key Features
- User Authentication (Login / Logout)
- Product Listing
- Product Detail View
- Add to Favorites
- Shopping Cart Management
- Place Order
- Real-time Data Updates with Firestore
- User Profile Management

===================================================================================================================================================================================================
