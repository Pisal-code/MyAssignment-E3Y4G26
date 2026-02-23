const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore(); // THIS fixes the 'db is not defined' errors
const shoesData = require("./shoes.json"); // now it’s a proper array

exports.importShoes = functions.https.onRequest(async (req, res) => {
  try {
    const batch = db.batch();
    shoesData.forEach((shoe) => {
      const docRef = db.collection("shoes").doc(String(shoe.id || Date.now()));
      batch.set(docRef, {
        id: shoe.id !== undefined ? shoe.id : 0,
        name: shoe.name !== undefined ? shoe.name : "Unknown",
        description: shoe.description !== undefined ? shoe.description : "",
        price: shoe.price !== undefined ? shoe.price : 0,
        old_price: shoe.old_price !== undefined ? shoe.old_price : null,
        image_url: shoe.image_url !== undefined ? shoe.image_url : null,
        status: shoe.status !== undefined ? shoe.status : "Inactive",
        bestSelling: shoe.bestSelling !== undefined ? shoe.bestSelling : false,
        stock: shoe.stock !== undefined ? shoe.stock : 0,
        is_favorite: shoe.is_favorite !== undefined ? shoe.is_favorite : false,
        category: shoe.category !== undefined ? shoe.category : "Uncategorized",
      });
    });
    await batch.commit();
    res.send({success: true, message: "Shoes imported successfully!"});
  } catch (error) {
    console.error(error);
    res.status(500).send({success: false, error: error.message});
  }
});
