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
const axios = require("axios");
// const express = require("express");
// const bodyParser = require("body-parser");
// const cors = require("cors");
admin.initializeApp();

// const app = express();
// app.use(cors());
// app.use(bodyParser.json());

// // M-Pesa Confirmation Callback Endpoint
// app.post("/mpesa/confirmation", async (req, res) => {
//   try {
//     const callbackData = req.body;

//     // Log the callback data
//     console.log("M-Pesa Confirmation Data:", callbackData);

//     // Store the callback data in Firestore
//     const ref = admin.firestore().collection("mpesaConfirmations");
//     await ref.add({
//       ...callbackData,
//       timestamp: admin.firestore.FieldValue.serverTimestamp(),
//     });

//     // Respond to Safaricom with success
//     res.status(200).send({
//       ResponseCode: "00000000",
//       ResponseDesc: "Success",
//     });
//   } catch (error) {
//     console.error("Error processing confirmation:", error);
//     res.status(500).send({
//       ResponseCode: "1",
//       ResponseDesc: "Failed",
//     });
//   }
// });

// // Export the function
// exports.paymentCallback = functions.https.onRequest(app);

// const LIPIA_API_KEY = "7acd8e1c198313db8169389635ddaa1a52d7b095";
exports.initPayment = functions.firestore.onDocumentCreated(
    "orders/{orderNum}/",
    async (snapshot) => {
      const orderdata = snapshot.data;
      const price = orderdata.data().price;
      const number = orderdata.data().Number;
      // const orderNum = orderdata.data().orderNumber;
      // trigger lipia online //
      const apiUrl = "https://lipia-api.kreativelabske.com/api/request/stk";
      const headers = {
        "Authorization": "Bearer 7acd8e1c198313db8169389635ddaa1a52d7b095",
        "Content-Type": "application/json",
      };
        // Define the payload
      const payload = {
        number,
        price,
      };
      try {
        // Send the payment request
        const response = await axios.post(apiUrl, payload, {headers});

        // Log the successful response
        console.log("Payment processed successfully:", response.data);

        // Update Firestore document with payment status
        await snapshot.ref.update({
          PaymentState: "success",
          lipiaResponse: response.data,
        });
      } catch (error) {
        // Handle errors and log them
        console.error("Error processing payment:",
            (error.response.data || error.message));
        // Update Firestore document with error status
        await snapshot.ref.update({
          PaymentState: "failed",
          error: error.response.data || error.message,
        });
      }
    },
);
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
