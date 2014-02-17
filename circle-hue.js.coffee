dotenv = require('dotenv')
dotenv.load()

request = require('request')
hue = require("node-hue-api")
# https://github.com/peter-murray/node-hue-api
HueApi = hue.HueApi
lightState = hue.lightState

# Set light state to 'on' with warm white value of 500 and brightness set to 100%
red = lightState.create().on().rgb(255, 0, 0).brightness(100)
green = lightState.create().on().rgb(0, 255, 0).brightness(100)
api = null

firstRun = true

displayBridges = (bridge) ->
  console.log("Hue Bridges Found: " + JSON.stringify(bridge))
  host = bridge[0].ipaddress
  username = process.env.HUE_USERNAME
  api = new HueApi(host, username)

fetchBuildStatus = ->
  circlePollUrl = "https://circleci.com/api/v1/project/yerdle/yerdle2/tree/production?circle-token=#{process.env.CIRCLE_API_TOKEN}&limit=1"
  request { url: circlePollUrl, headers: { 'Accept': 'application/json' } }, (error, response, body) ->
    #console.log body
    build = JSON.parse(body)[0]
    if build.outcome == "failed"
      console.log "failed"
      api.setLightState(1, red)
          .done()
    else
      console.log "success"
      api.setLightState(1, green)
          .done()

  setTimeout(fetchBuildStatus, 60 * 1000)

hue.locateBridges().then(displayBridges).done()
fetchBuildStatus()
