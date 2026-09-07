const mongoose = require('mongoose');

const chatSchema = new mongoose.Schema({
  carId: { type: String, required: true },
  carTitle: { type: String, default: '' },
  carImage: { type: String, default: '' },
  buyerId: { type: String, required: true },
  buyerName: { type: String, required: true },
  sellerId: { type: String, required: true },
  sellerName: { type: String, required: true },
  messages: [
    {
      senderId: String,
      senderName: String,
      text: String,
      createdAt: { type: Date, default: Date.now }
    }
  ],
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Chat', chatSchema);
