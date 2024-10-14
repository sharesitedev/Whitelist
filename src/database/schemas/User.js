const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    robloxId: {
        type: mongoose.SchemaTypes.Number,
        required: true
    },
    Liscences: {
        type: mongoose.SchemaTypes.Array,
        required: true,
        default: []
    },
    Keys: {
        type: mongoose.SchemaTypes.Array,
        required: true,
        default: []
    }
});

module.exports = mongoose.model('users', UserSchema);