const mongoose = require('mongoose');

mongoose.connect(process.env.MONGO_URI)
    .then(() => {
        console.log('Connected to the whitelist DB!');
    })
    .catch((err) => {
        console.log('Error connecting to MongoDB:', err);
    });