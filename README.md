# Humblebot
[humblebot](http://telegram.me/humblebot) was a **telegram bot** seeking humblebundle keys on twitter and sending them to users telegram

##Instructions
-Edit config file with your data

```coffeescript
config = 
  token: 'authorization token provided by @botfather'
  web:
    port: process.env.PORT or 3000
    domain: 'https://tg-humblebot.herokuapp.com' # Your domain, must have a valid certificate
  mongodb: process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://USER:PASSWORD@ds039880.mongolab.com:39880/tg-humblebot' # Mongodb url
  twitter: #Twitter stuff
    consumer_key: ''
    consumer_secret: ''
    access_token: ''
    access_token_secret: ''
module.exports = config
```

-Install dependencies
```shell
npm install
```
-Run
```shell
 coffee index.coffee
```
