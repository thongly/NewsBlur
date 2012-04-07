express = require 'express'
mongo = require 'mongodb'

MONGODB_SERVER = if process.env.NODE_ENV == 'dev' then 'localhost' else 'db04'
server = new mongo.Server(MONGODB_SERVER, 27017, 
    auto_reconnect: true
    poolSize: 12)
db = new mongo.Db('newsblur', server)

app = express.createServer()
app.use express.bodyParser()
    
db.open (err, client) =>
    client.collection "feed_icons", (err, @collection) =>
    
app.get /^\/rss_feeds\/icon\/(\d+)\/?/, (req, res) =>
    # console.log "Req: #{req.params}"
    feed_id = parseInt(req.params, 10)
    @collection.findOne _id: feed_id, (err, docs) ->
        if not err and docs and docs.data
            etag = req.header('If-None-Match')
            if etag and docs.color == etag
                res.send 304
            else
                res.header 'etag', docs.color
                res.send new Buffer(docs.data, 'base64'), 
                    "Content-Type": "image/png"
        else
            res.redirect '/media/img/icons/silk/world.png' 
        
app.listen 3030
