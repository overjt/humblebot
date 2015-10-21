BotAPI = require("teleapiwrapper").BotAPI
mongoose = require 'mongoose'
User = require './models/user'
Link = require './models/link'
Twit = require 'twit'

class TelegramBot

  constructor: (config) ->
    botToken = config.token
    webHookUrl = config.web.domain
    urlMongo = config.mongodb
    twitter_auth = config.twitter
    if botToken? and webHookUrl? and urlMongo? and twitter_auth?
      @bot = new BotAPI botToken
      @name = ''
      @username = ''
      self = @
      @lastUpdateId = 0
      @bot.getMe (err, res) ->
        if err?
          return console.log err
        self.name = res.result.first_name
        self.username = res.result.username.toLowerCase()
        console.log "Hello, I am #{self.username}"

      @bot.setWebhook webHookUrl ,(err, res) ->
        if err?
          return console.log err
        console.log "WebHook url: #{webHookUrl}"

      mongoose.connect urlMongo, (err, res) ->
        if err
          console.log 'ERROR connecting to: ' + urlMongo + '. ' + err
        else
          console.log 'Succeeded connected to: ' + urlMongo

      #untalover
      T = new Twit(twitter_auth)

      stream1 = T.stream('statuses/filter', track: 'humblebundle gift')
      stream1.on 'tweet', (tweet) ->
        self.parseTweet tweet

      stream1.on 'disconnect', (msg) ->
        console.log msg

      stream2 = T.stream('statuses/filter', track: 'humblebundle key')
      stream2.on 'tweet', (tweet) ->
        self.parseTweet tweet

      stream2.on 'disconnect', (msg) ->
        console.log msg

      User.findOne {username: "OverJT"}, (err, user_obj) ->
        if err
          throw err
        if user_obj?
          self.bot.sendMessage user_obj.user_id, "Hola, me reinicié :3"
    else
      throw new Error("Not enough parameters provided. I need a token and a webhook url")

  processMsg: (data) ->
    self = @
    if data.message.text?
      match = data.message.text.match '^\/([a-zA-Z0-9_]{1,64})(?:@([a-zA-Z0-9_]{5,32}))?(?: (.*))?$'
      if match?
        if not match[2]? or match[2].toLowerCase() is @username
          if match[1].toLowerCase() is "start"
            msg = "¡Welcome, #{data.message.from.first_name}!\n\nAvailable commands:\n\n/help - Shows this message\n/enable - Allows the bot to send you the gift links as soon as they're published.\n/disable - Disables the messages"
            @bot.sendMessage data.message.chat.id, msg

          else if match[1].toLowerCase() is "enable"
            User.findOneAndUpdate { user_id: data.message.from.id }, { username: data.message.from.username || '', user_fullname: data.message.from.first_name || '', alert_active: true  },{upsert: true}, (err, user) ->
              if err
                throw err
              if user is null
                msg = "Hello #{data.message.from.first_name}\n¡You have enabled gift link alerts!\nYou can disable them by sending /disable"
              else
                msg = "¡You have enabled gift link alerts!\nYou can disable them by sending /disable"
              self.bot.sendMessage data.message.chat.id, msg
          else if match[1].toLowerCase() is "disable"
            User.findOneAndUpdate { user_id: data.message.from.id }, { alert_active: false }, (err, user) ->
              if err
                throw err
              self.bot.sendMessage data.message.chat.id, "¡You have disabled gift link alerts!\nyou can reenable them using the /enable command"
          else if match[1].toLowerCase() is "help"
            msg = "Available commands:\n\n/help - Shows this message\n/enable - Allows the bot to send you the gift links as soon as they're published.\n/disable - Disables the messages\n\nComments or suggestions contact @OverJT"
            @bot.sendMessage data.message.chat.id, msg

  parseTweet: (tweet) ->
    self = @
    user = tweet.user.screen_name
    msg = tweet.text
    urlRegex = /(https?:\/\/[^\s]+)/g
    matchs = msg.match(urlRegex)
    if matchs?
      for link in matchs
        Link.findOne { url: link }, (err, link_obj) ->
          if err
            throw err
          if link_obj is null

            User.find {alert_active: true}, (err, users_list) ->
              if err
                throw err
              for user_obj in users_list
                self.bot.sendMessage user_obj.user_id, "#{link}"

            link_obj = new Link(
              url: link
            )
            link_obj.save()
module.exports = TelegramBot