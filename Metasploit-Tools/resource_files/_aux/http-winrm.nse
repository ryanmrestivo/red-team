local comm = require "comm"
local nmap = require "nmap"
local http = require "http"
local shortport = require "shortport"

local wsmanrequest = "/wsman"

description = [[
This script will detect if a web server is running the WS-Management protocol.
]]
---
--@usage
--
--@args
--
--@output
--

categories = {"default", "safe"}

author = {"Sean Warnock swarnock[.]warnocksolutions.com"}

license = {"Same as Nmap--See https://nmap.org/book/man-legal.html"}

--dependencies = ""

portrule = shortport.portnumber({80,443,5985,5986}, "tcp")

action = function(host, port)


  --options['header']['Content-Type'] = 'text/xml'
  local response = http.post(host,port,wsmanrequest, { ['header'] = { ['content-type'] = 'application/soap+xml;charset=UTF-8' , ['User-Agent'] = 'Microsoft WinRM Client', ['WSMANIDENTIFY'] ='unauthenticated'}})

--if 404 then it is NOT wsman
-- Basic realm="OPENWSMAN"
  if response.status == 401 and string.match(response.body, "401 Unauthorized\x0D") then
  --if response.status == 401 then
    return "OpenWS Management"
  elseif response.status == 200 then
    return response.body
  elseif response.status == 301 then
    return "Potential"
  end
  --return response
end
