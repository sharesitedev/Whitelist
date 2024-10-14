const mongoose = require('mongoose');

const GroupSchema = new mongoose.Schema({
    groupId: {
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

module.exports = mongoose.model('groups', GroupSchema);