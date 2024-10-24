const mongoose = require("mongoose")

const Todo = new mongoose.Schema({
    todo: {
        type: String,
        require: true
    },
    isCompleted: {
        default: false,
        type: Boolean
    },
    order: {
        type: Number,
    },
    isCreated: {
        type: Date,
        default: () => Date.now()
    }
})

module.exports = new mongoose.model("Todo", Todo)