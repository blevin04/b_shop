/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
admin.initializeApp();


const app = express();
app.use(cors());
app.use(bodyParser.json());

// M-Pesa Confirmation Callback Endpoint
app.post("/mpesa/confirmation", async (req, res) => {
  try {
    const callbackData = req.body;

    // Log the callback data
    console.log("M-Pesa Confirmation Data:", callbackData);

    // Store the callback data in Firestore
    const ref = admin.firestore().collection("mpesaConfirmations");
    await ref.add({
      ...callbackData,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Respond to Safaricom with success
    res.status(200).send({
      ResponseCode: "00000000",
      ResponseDesc: "Success",
    });
  } catch (error) {
    console.error("Error processing confirmation:", error);
    res.status(500).send({
      ResponseCode: "1",
      ResponseDesc: "Failed",
    });
  }
});

// Export the function
exports.paymentCallback = functions.https.onRequest(app);
// exports.initOrder = functions.firestore.onDocumentCreated(
//     "orders/{orderNum}",
//     (snapshot)=>{
//         const orderdata = snapshot.data;
//         const price = orderdata.data().price;
//         const number = orderdata.data().Number;
//         const orderNum = orderdata.data().orderNumber;
//         //////trigger mpesa //////////
//         let headers = new Headers();
//         headers.append("Content-Type", "application/json");
//         headers.append("Authorization",
//         "Bearer EKgHyrx5gsLahKAsATP1PTvwLGMF");
//         fetch("https://sandbox.safaricom.co.ke/mpesa/c2b/v1/simulate", {
//         method: 'POST',
//         headers,
//         body: JSON.stringify({
//             "ShortCode": 3080510,
//             "CommandID": "CustomerBuyGoodsOnline",
//             "amount": price,
//             "MSISDN": number,
//             "BillRefNumber": orderNum,
//         })
//         })
//         .then(response => response.text())
//         .then(result => console.log(result))
//         .catch(error => console.log(error));

//     }
// )
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
