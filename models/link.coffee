mongoose = require('mongoose')

linkSchema = new mongoose.Schema(
  url:
    type: String
    required: true
    unique: true
)

Link = mongoose.model 'Link', linkSchema

module.exports = Link