const { setGlobalOptions } = require('firebase-functions/v2');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const iyzipayApp = require('./iyzipay');

admin.initializeApp();

setGlobalOptions({ region: 'europe-west2' });

// Pazartesi gece 4 te çalışıyor
exports.resetAppointments = onSchedule(
  { schedule: 'every Monday 04:00', timeZone: 'Europe/Istanbul' },
  async () => {
    try {
      const usersRef = admin.firestore().collection('Users');
      const usersSnapshot = await usersRef.get();

      let batch = admin.firestore().batch();
      let batchCounter = 0;

      for (const userDoc of usersSnapshot.docs) {
        const userRef = userDoc.ref;
        const userData = userDoc.data();

        // Reset `istaken` values properly by making a deep copy
        if (userData.sellerDetails && userData.sellerDetails.selectedHoursByDay) {
          const updatedHours = JSON.parse(JSON.stringify(userData.sellerDetails.selectedHoursByDay));

          Object.keys(updatedHours).forEach((day) => {
            updatedHours[day] = updatedHours[day].map((hourSlot) => ({
              ...hourSlot,
              istaken: false,
            }));
          });

          batch.update(userRef, { 'sellerDetails.selectedHoursByDay': updatedHours });
          batchCounter++;
        }

        // Delete old appointments
        const appointmentBuyerRef = userRef.collection("appointmentbuyer");
        const appointmentSellerRef = userRef.collection("appointmentseller");

        const appointmentsBuyer = await appointmentBuyerRef.get();
        const appointmentsSeller = await appointmentSellerRef.get();

        appointmentsBuyer.forEach((doc) => {
          batch.delete(doc.ref);
          batchCounter++;
        });

        appointmentsSeller.forEach((doc) => {
          const data = doc.data();
          const details = data.appointmentDetails;
          // Only update if isWithdrawalButtonPressed is true
          if (details && details.isWithdrawalButtonPressed === true) {
            batch.delete(doc.ref);
            batchCounter++;
          } 
        });

        // appointmentsSeller.forEach((doc) => {
        //   batch.delete(doc.ref);
        //   batchCounter++;
        // });

        // Commit batch every 500 writes to avoid Firestore limits
        if (batchCounter >= 500) {
          await batch.commit();
          batch = admin.firestore().batch();
          batchCounter = 0;
        }
      }

      // Commit remaining batch writes
      if (batchCounter > 0) {
        await batch.commit();
      }

      console.log('Appointments successfully reset and deleted!');
    } catch (error) {
      console.error('Error resetting appointments:', error);
    }
  }
);
// exports.runVerificationFunction = onSchedule(

//   {schedule : 'every 30 minutes', timeZone: 'Europe/Istanbul'},
//   async ()=> {
    
//     try {
//       const usersRef = admin.firestore().collection('Users');
//       const usersSnapshot = await usersRef.get();

//       for (const userDoc of usersSnapshot.docs) {
//         const userRef = userDoc.doc('');
//       }
//     } catch (e) {
//     }
//   }
// );

exports.api = onRequest({ region: 'europe-west2' }, iyzipayApp);




