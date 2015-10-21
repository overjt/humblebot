mongoose = require('mongoose')

userSchema = new mongoose.Schema(
  username: String
  user_id:
    type: Number
    required: true
    unique: true
  user_fullname: String
  alert_active: Boolean
)

User = mongoose.model 'User', userSchema

module.exports = User