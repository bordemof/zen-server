###
ZENserver
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <@soyjavi>

@namespace    lib/services/redis
###
"use strict"

redis = require "redis"
Hope  = require "hope"

Redis =

  open: (connection) ->
    @host = connection.host
    @port = connection.port

    promise = new Hope.Promise()
    @client = redis.createClient @port, @host
    @client.auth connection.password if connection.password?
    @client.on "error", (error) ->
      console.log " ⚑".red, "Error connection:".grey, error.red
      promise.done error, null
    @client.on "connect", =>
      console.log "✓".green, "Redis", "listening at".grey, "#{@host}:#{@port}".underline.green
      promise.done null, true
    promise

  close: ->
    console.log "✓".green, "Redis", "closed connection correctly.".grey
    do @client.quit

  set: (key, value) -> @client.SET String(key), value

  push: (key, value) -> @client.RPUSH String(key), value

  json: (key, value) -> @client.SET String(key), JSON.stringify value

  incr: (key, callback) -> @client.INCR String(key), callback

  decr: (key, callback) -> @client.DECR String(key), callback

  expire: (key, time) -> @client.EXPIRE String(key), time

  remove: (key) -> @client.DEL String(key)

  hgetall: (key, callback) -> @client.HGETALL String(key), callback

  hdel: (key, field) -> @client.hdel String(key), field

  hincrby: (key, field, increment) -> @client.HINCRBY String(key), field, increment

  run: (args...) ->
    @client[args[0]].apply @client, args.slice(1)

  multi: (actions, callback) ->
    @client.multi(actions).exec callback

  length: (key, callback) ->
    @client.LLEN key, (error, result) ->
      callback error, result

  rpop: (key, callback) ->
    @client.RPOP key, (error, result) ->
      result = JSON.parse result if result?
      callback error, result

  lrange: (key, i, j, callback) ->
    @client.LRANGE key, [i,j], (error, result) ->
      result = JSON.parse result if result?
      callback error, result

  exist: (key, callback) ->
    @client.EXISTS key, (error, result) ->
      callback error, result

  get: (key, callback) ->
    @client.GET key, (error, result) ->
      result = JSON.parse result if result?
      callback error, result

  cache: (key, value, expire, json=true) ->
    if json then @json key, value else @set key, value
    @client.EXPIRE String(key), expire

module.exports = Redis
