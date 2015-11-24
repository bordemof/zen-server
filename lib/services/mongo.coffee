###
ZENserver
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <@soyjavi>

@namespace    lib/services/mongo
###
"use strict"

mongoose = require "mongoose"
Hope     = require "hope"

module.exports =
  connections: {}

  open: (connection = {}) ->
    promise = new Hope.Promise()
    for host, i in connection.host
      connection.host[i] = host + ":" + connection.port
    url = connection.host.toString() + "/" + connection.db
    if connection.user and connection.password
      url = connection.user + ":" + connection.password + "@" + url


    @connections[connection.name] = mongoose.createConnection "mongodb://#{url}"
    @connections[connection.name].on "error", (error) ->
      console.log "⚑".red, "Error connection:".grey, error.red

      promise.done true, null
      process.exit()
    @connections[connection.name].on "connected", (error) ->
      console.log "✓".green, "MongoDB:#{connection.name}", "connected at".grey, "#{connection.host}/#{connection.db}".underline.green
      promise.done null, true

    promise

  close: ->
    for name of @connections
      @connections[name].close ->
        console.log "✓".green, "MongoDB:/#{name}", "closed connection correctly.".grey
