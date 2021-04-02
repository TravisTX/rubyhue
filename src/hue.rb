require 'net/http'
require 'json'

HueUsername    = "kfZqr9nqnhINjSKYlPXQ4R6TacR9nPE5Q9UOOC14"
HueBridgeIp = "10.0.0.112"

def run
    lights = getLights
    longestName = findLongestName(lights)

    lights.each do |key, light|
        puts getLightDisplay(key, light, longestName)
    end
end

def getLights
    url = "http://#{HueBridgeIp}/api/#{HueUsername}/lights"

    res = Net::HTTP.get(URI(url))
    data = JSON.parse(res)

    result = {}

    data.each do |key, value|
        result[key] = {
            name: value["name"],
            on: value["state"]["on"],
            reachable: value["state"]["reachable"],
            bri: value["state"]["bri"],
            hue: value["state"]["hue"],
            sat: value["state"]["sat"],
        }
    end

    return result
end

def findLongestName lights
    longestName = 0
    lights.each do |key, light|
        length = "#{key} #{light[:name]}".length
        longestName = [longestName, length].max
    end

    return longestName
end

def getLightDisplay lightId, light, longestName
    onDisplay = ""
    v = 0.5
    if light[:on]
        onDisplay = ""
        v = 1
    end

    percentage = (light[:bri].to_f / 254 * 100).to_i

    out = "#{lightId} #{light[:name]}"
    out += " " * (longestName - out.length + 2)
    out += "#{onDisplay} "
    out += getAsciiProgressBar(percentage)
    return out
end

def getAsciiProgressBar percentage
    maxWidth = 10
    unitsFilled = percentage * maxWidth / 100
    unitsRemaining = maxWidth - unitsFilled
    padding = ""
    if (percentage < 100)
        padding = " "
    end
    if (percentage < 10)
        padding = "  "
    end

    return "#{"█" * unitsFilled}#{"░" * unitsRemaining} #{padding}#{percentage}%"
end

run