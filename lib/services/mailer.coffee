###
ZENserver
@description  Mailer service wrapper
@author       Imanol Yañez Sastre <@cerohistorias>

@namespace    lib/services/mailer
###

"use strict"

nodemailer = require('nodemailer');
Hope  = require "hope"

Mailer =
  open: (connection) ->
    @options = connection.options
    promise = new Hope.Promise()
    @client = nodemailer.createTransport("SMTP",connection.configuration)
    console.log "✓".green, "Mailer", "Transport correctly initialized with".grey,"#{connection.configuration.service}".green
    promise.done undefined, true
    promise

  send: (options=@options)->
    @client.sendMail(options,(error, info)->
        if error
            console.log "⚑".red, "Mailer received an error sending message #{error.code}:#{error.message}"
        else
           console.log "✉".green, "Mail corectly sent to #{options.to}"
    )

  close: ->
    console.log "✓".green, "Mailer", "closed transport correctly.".grey
    do @client.close

module.exports = Mailer
