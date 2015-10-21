config      = require './config'
tgbot       = require './tgbot'
express     = require 'express'
https       = require 'https'
bodyParser  = require 'body-parser'
bot = null
app = express()
app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()

uniqueId = (length=4) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length

webHookString = uniqueId()

app.post "/webhook#{webHookString}", (request, response) ->
  response.end JSON.stringify('success': true)
  if bot?
    bot.processMsg request.body

app.get "/ping#{webHookString}", (req, res) ->
  res.send "Pong Pong! #{webHookString}"

app.get '/', (req, res) ->
  res.send 'Por acá no es ^_^'

server = app.listen(config.web.port, ->
  if config.web.domain?
    https.get config.web.domain + "/ping#{webHookString}", (res) ->
      result = ''

      res.on 'data', (chunk) ->
        result += '' + chunk

      res.on 'end', ->
        if result != "Pong Pong! #{webHookString}"
          console.log 'The domains do not match'
          process.exit()
        config.web.domain = "#{config.web.domain}/webhook#{webHookString}"
        bot = new tgbot config

      res.on 'error', (e) ->
        console.log 'Error:', err
        process.exit()
  else
    console.log 'a domain is needed'
    process.exit()
)