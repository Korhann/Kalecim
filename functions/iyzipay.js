const express = require('express');
const Iyzipay = require('iyzipay');
const { getFirestore } = require('firebase-admin/firestore');

const app = express();
app.use(express.json());

const iyzipay = new Iyzipay({
  apiKey: 'qcEfRXmHiUVZyO76OH7U3FT6MR6gBi2p',
  secretKey: 'NddUCV45JbJVWqaUX3UlIq30rZtjJIMV',
  uri: 'https://api.iyzipay.com'
});

// Ödeme başlatma endpointi
app.post('/checkout-form', async (req, res) => {
  const { name, surname, email, phone, ip, price, sellerId, sellerDocId, buyerId, buyerDocId } = req.body;

  if (!name || !surname || !email || !phone || !ip || !price || !sellerId || !sellerDocId || !buyerId || !buyerDocId) {
    return res.status(400).send({ error: 'Missing required fields' });
  }

  const formattedPrice = Number(price).toFixed(2);

  const request = {
    locale: Iyzipay.LOCALE.TR,
    conversationId: sellerId,
    price: formattedPrice,
    paidPrice: formattedPrice,
    currency: Iyzipay.CURRENCY.TRY,
    basketId: sellerDocId,
    paymentGroup: Iyzipay.PAYMENT_GROUP.PRODUCT,
    callbackUrl: "https://europe-west2-kiralikkaleci-21f26.cloudfunctions.net/api/iyzico-callback",
    buyer: {
      id: buyerId,
      name,
      surname,
      gsmNumber: phone,
      email,
      identityNumber: '11171114128',
      registrationAddress: 'Adres',
      ip,
      city: 'Istanbul',
      country: 'Turkey',
      zipCode: '34000'
    },
    shippingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Adres',
      zipCode: '34000'
    },
    billingAddress: {
      contactName: `${name} ${surname}`,
      city: 'Istanbul',
      country: 'Turkey',
      address: 'Adres',
      zipCode: '34000'
    },
    basketItems: [
      {
        id: 'BI101',
        name: 'Service Payment',
        category1: 'Goalkeeper',
        category2: 'Rental',
        itemType: Iyzipay.BASKET_ITEM_TYPE.VIRTUAL,
        price: formattedPrice
      }
    ],
    // Ekstra: Flutter'dan gelen buyerDocId ve buyerId'yi callback'te kullanmak için customParams'a ekle
    // (iyzico callback'te query parametre olarak dönmez ama POST body'de conversationId ve basketId gelir)
  };

  iyzipay.checkoutFormInitialize.create(request, function (err, result) {
  if (err) {
    console.error('Iyzico error:', err);
    return res.status(500).send({ error: 'Checkout form error', details: err });
  }
  if (result.status !== 'success') {
    console.error('Iyzico API error:', result);
    return res.status(500).send({ error: 'Iyzico API error', details: result });
  }
  res.status(200).send({
    paymentPageUrl: result.paymentPageUrl,
    token: result.token
  });
});
});

// Iyzico callback endpointi (ödeme tamamlanınca iyzico buraya POST atar)
app.post('/iyzico-callback', async (req, res) => {
  const token = req.body.token;
  // conversationId ve basketId ile Flutter'dan gelen buyerId ve buyerDocId'yi eşleştirebilirsin
  const conversationId = req.body.conversationId; // sellerId
  const basketId = req.body.basketId; // sellerDocId

  if (!token) {
    return res.status(400).send('Token missing');
  }

  const request = {
    locale: Iyzipay.LOCALE.TR,
    token: token
  };

  iyzipay.checkoutForm.retrieve(request, async (err, result) => {
    if (err) {
      return res.status(500).send('Retrieve error');
    }
    if (result.status === 'success') {
      // buyerId ve buyerDocId'yi basketId/conversationId ile eşleştirmen gerekebilir
      // Örnek: Firestore'da sellerId ve sellerDocId ile ilgili kaydı bulup güncelle
      // Örnekte buyerId ve buyerDocId'yi Flutter'dan checkout-form ile birlikte kaydettiğini varsayıyoruz

      // Örnek: Firestore'da sellerId altında buyerDocId'yi güncelle
      // (Kendi Firestore yapına göre düzenle)
      try {
        // Burada sellerId ve buyerDocId'yi bir yerde eşleştirdiysen bulup güncelle
        // Örneğin, sellerId altında appointmentbuyer koleksiyonunda buyerDocId dokümanı varsa:
        await getFirestore()
          .collection('Users')
          .doc(result.buyerId) 
          .collection('appointmentbuyer')
          .doc(result.buyerDocId) 
          .update({ 'appointmentDetails.paymentStatus': 'done' });
      } catch (e) {
        console.error('Firestore update error:', e);
      }
    }
    res.status(200).send('OK');
  });
});

// Iyzico ödeme sonucu manuel sorgulama endpointi (opsiyonel)
app.post('/check-payment', async (req, res) => {
  const { token } = req.body;
  if (!token) {
    return res.status(400).send({ error: 'Token missing' });
  }

  const request = {
    locale: Iyzipay.LOCALE.TR,
    token: token
  };

  iyzipay.checkoutForm.retrieve(request, function (err, result) {
    if (err) {
      return res.status(500).send({ error: 'Retrieve error', details: err });
    }
    res.status(200).send(result);
  });
});

module.exports = app;