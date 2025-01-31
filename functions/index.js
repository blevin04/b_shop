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
// const {response} = require("express");
// const axios = require("axios");
admin.initializeApp();
const LIPIA_API_KEY ="0f70258e0562d0b0ef88e995d81bdc1efc3e0727";
exports.initPayment = functions.firestore.onDocumentCreated(
    "orders/{orderNum}/",
    async (snapshot) => {
      const orderdata = snapshot.data;
      const price = orderdata.data().price;
      const number = orderdata.data().Number;
      const paymentOndelivery = orderdata.data().OndeliveryPayment;
      // const orderNum = orderdata.data().orderNumber;
      // trigger lipia online //
      const apiUrl = "https://lipia-api.kreativelabske.com/api/request/stk";
      const headers = {
        "Authorization": `Bearer ${LIPIA_API_KEY}`,
        "Content-Type": "application/json",
      };
        // Define the payload
      // const payload = {
      //   number,
      //   price,
      // };
      if (paymentOndelivery == false) {
        try {
          // Send the payment request
          // const response = await axios.post(apiUrl, payload, {headers});
          fetch(apiUrl, {
            method: "POST",
            body: JSON.stringify(
                {"phone": number,
                  "amount": price},
            ),
            headers: headers,

          }).then( async (response) => {
            return response.json();
          }).then(async (datas)=>{
            const data = datas.data;
            console.log("Payment processed successfully:", datas);
            await admin.firestore().collection("orders").
                doc(snapshot.params.orderNum).update({
                  "Live": true,
                  "PaymentState": "Success",
                  "LipiaOnlineResponse": data,
                });
          });
          // // Log the successful response
          // console.log("Payment processed successfully:", response.data);

          // await snapshot.ref.update({
          //   PaymentState: "success",
          //   lipiaResponse: response.data,
          // });
        } catch (error) {
          // Handle errors and log them
          await admin.firestore().collection("orders").
              doc(snapshot.params.orderNum).update({
                "PaymentState": "failed",
                "LipiaResponce": error.data,
              });
          console.error("Error processing payment:",
              (error.response.data || error.message));
          // Update Firestore document with error status
          // await snapshot.ref.update({
          //   PaymentState: "failed",
          //   error: error.response.data || error.message,
          // });
        }
      }
    },
);
exports.updateStock = functions.firestore.onDocumentUpdated(
    "orders/{orderId}",
    async (snapshot) => {
      const orderdata = snapshot.data;
      const items = orderdata.before.data().items;
      const prev = orderdata.before.data().Live;
      const after = orderdata.after.data().Live;
      if (prev == false && after == true) {
        try {
          if (typeof items == typeof null) {
            console.log("arrives");
            for (const [key, value] of Object.entries(items)) {
              const productData = await admin.firestore().
                  collection("Products").
                  doc(key).get();
              let stock = productData.data().Stock;
              const bought = value[2];
              stock -=bought;
              await admin.firestore().collection("Products").
                  doc(key).update({
                    "Stock": stock,
                  }).then((responce) => {
                    console.log("Update Happened ", responce);
                  });
            }
          }
          console.log("Successfully updated stock");
        } catch (error) {
          console.log("Exception Occured", error);
        }
      }
    },
);
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
