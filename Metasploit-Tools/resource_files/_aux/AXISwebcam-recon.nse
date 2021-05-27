---
-- Nmap NSE AXISwebcam-recon.nse - Version 1.9
-- Copy to: /usr/share/nmap/scripts/AXISwebcam-recon.nse
-- Update NSE database: sudo nmap --script-updatedb
-- execute: nmap --script-help AXISwebcam-recon.nse
---

-- SCRIPT BANNER DESCRIPTION --
description = [[

Module Author: r00t-3xp10it & Cleiton Pinheiro
NSE script to detect if target [ip]:[port][/url] its an AXIS Network Camera transmiting (live).
This script also allow is users to send a fake User-Agent in the tcp packet <agent=User-Agent-String>
and also allow is users to input a diferent uri= [/url] link to be scan, IF none uri= value its inputed, then
this script tests a List of AXIS default [/url's] available in our database to brute force the HTML TITLE tag.
'Remark: This nse script will NOT execute againts webcams found that require authentication logins'

Some Syntax examples:
nmap --script-help AXISwebcam-recon.nse
nmap -sV -Pn -p 80-86,92,8080-8082 --open --script AXISwebcam-recon.nse 216.99.115.136
nmap -sV -Pn -p 80-86,92,8080-8082 --open --script AXISwebcam-recon.nse --script-args "uri=/view/viewer_index.shtml" 217.78.137.43
nmap -sS -Pn -p 80-86,92,8080-8082 --script AXISwebcam-recon.nse --script-args "agent=Mozilla/5.0 (compatible; EvilMonkey)" 50.93.227.204
nmap -sS -Pn -p 80,8080-8082 --open --script AXISwebcam-recon.nse --script-args "agent=Mozilla/5.0 (compatible),uri=/fd" 194.150.15.187
nmap -sS -v -Pn -n -T5 -iR 700 -p 92,8080-8086 --open --script=http-headers.nse,AXISwebcam-recon.nse -D 65.49.82.3 -oN webcam_reports.txt

]]


---
-- @usage
-- nmap --script-help AXISwebcam-recon.nse
-- nmap -sV -Pn -p 80-86,92,8080-8082 --open --script AXISwebcam-recon.nse 216.99.115.136
-- nmap -sV -Pn -p 80-86,92,8080-8082 --open --script AXISwebcam-recon.nse --script-args "uri=/view/viewer_index.shtml" 217.78.137.43
-- nmap -sS -Pn -p 80-86,92,8080-8082 --script AXISwebcam-recon.nse --script-args "agent=Mozilla/5.0 (compatible; EvilMonkey)" 50.93.227.204
-- nmap -sS -Pn -p 80-86,92,8080-8082 --open --script AXISwebcam-recon.nse --script-args "agent=Mozilla/5.0 (compatible),uri=/" 194.150.15.187
-- @output
-- PORT     STATE SERVICE VERSION
-- 8080/tcp open  http    Boa httpd
-- | AXISwebcam-recon:
-- |   STATUS: AXIS WEBCAM FOUND
-- |     TITLE: Live view  - AXIS 211 Network Camera version 4.11
-- |       WEBCAM ACCESS: http://216.99.115.136:8080/view/index.shtml
-- |       Module Author: r00t-3xp10it & Cleiton Pinheiro
-- |_
-- @args payload.uri the path name to search. Default: /view/index.shtml
-- @args payload.agent User-agent to send in request - Default: iPhone,safari
---


author = "r00t-3xp10it & Cleiton Pinheiro"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"safe", "discovery"}


-- DEPENDENCIES (lua nse libraries) --
local stdnse = require ('stdnse') --> nse args usage
local shortport = require "shortport"
local string = require "string"
local http = require "http"
local os = require "os" --> required for (sleep)
-- define loop limmit(s)
f = 0
limmit = 0


-- SET VALUES COLOR TERMINAL USE IN FUNCTION --
local colors = {
  -- attributes
  reset = 0,
  clear = 0,
  bright = 1,
  dim = 2,
  underscore = 4,
  blink = 5,
  reverse = 7,
  hidden = 8,

  -- foreground
  black = 30,
  red = 31,
  green = 32,
  yellow = 33,
  blue = 34,
  magenta = 35,
  cyan = 36,
  white = 37,

  -- background
  onblack = 40,
  onred = 41,
  ongreen = 42,
  onyellow = 43,
  onblue = 44,
  onmagenta = 45,
  oncyan = 46,
  onwhite = 47,
}

-- FUNCTION SET COLOR TERMINAL --
local function makecolor(value)
  value =  string.char(27) .. '[1;' .. tostring(value) .. 'm'
return value
end

-- SET VALUES COLOR TERMINAL --
local green_color = makecolor(colors.green)
local white_color = makecolor(colors.white)
local error_color = makecolor(colors.red)   
local reset_color = makecolor(colors.reset)
local yellow_color = makecolor(colors.yellow)

-- COLORING MADE BY MODULE --
local by_module = white_color.."r00t-3xp10it & Cleiton Pinheiro"..reset_color


-- THE RULE SECTION --
-- portrule = shortport.http --> Scan only the selected ports/proto/service_name in open state
portrule = shortport.port_or_service({80, 81, 82, 83, 84, 85, 86, 92, 8080, 8081, 8082, 8083, 55752, 55754}, "http, http-proxy", "tcp", "open")


-- THE ACTION SECTION --
action = function(host, port)
print(yellow_color.."Brute forcing Network Camera URL (uri)"..reset_color)
os.execute("sleep 0.5")
-- Define User Input uri variable
uri = stdnse.get_script_args(SCRIPT_NAME..".uri") or "/indexFrame.shtml"

-- Check User Input uri response
local check_uri = http.get(host, port, uri)
if ( check_uri.status == 401 ) then
print("|["..error_color..check_uri.status..reset_color.."] => http://"..host.ip..":"..port.number..uri..error_color.." (AUTH LOGIN FOUND)"..reset_color)
elseif ( check_uri.status == 404 ) then
print("|["..error_color..check_uri.status..reset_color.."] "..host.ip.." => "..uri)
   -- None User Input uri found => using table {uril} List
   uril = {"/webcam_code.php", "/view/view.shtml", "/indexFrame.shtml", "/view/index.shtml", "/view/index2.shtml", "/webcam/view.shtml", "/ViewerFrame.shtml", "/RecordFrame?Mode=", "/MultiCameraFrame?Mode=", "/view/viewer_index.shtml", "/visitor_center/i-cam.html", "/index.shtml", "/stadscam/Live95j.asp", "/sub06/cam.php", "/CgiStart"}
   -- loop Through {table} of uri url's
   for i, intable in pairs(uril) do
      local res = http.get(host, port, intable)
      if ( res.status == 200 ) then
         print("|["..green_color..res.status..reset_color.."] "..host.ip.." => "..intable)
         uri = intable --> define uri variable now
         break --> break execution (loop) if a match string its found (uri).
      else
        limmit = limmit+1 --> count how many interactions (loops done)
        print("|["..error_color..res.status..reset_color.."] "..host.ip.." => "..intable)
         os.execute("sleep 0.5")
         if ( limmit == 15 ) then --> why 15? Because its the number of URI links present in the {table} list.
            print("|[ABORT]: "..error_color.."None Match (uri) has been found in AXISwebcam-recon database."..reset_color)
            print("|[NOTES]: "..yellow_color.."--script-args uri=/CgiStart?page=Single&Mode=Motion&Language=1"..reset_color)
            print("|_")
            os.execute("sleep 1")
            return --> --> exit() if none match its found in our database   
         end
      end
   end
-- Diferent error codes (mosquito needs this seting)
elseif ( check_uri.status == 400 or check_uri.status == 403 or check_uri.status == 405 or check_uri.status == 500 or check_uri.status == 502 or check_uri.status == 503 or check_uri.status == 307 or check_uri.status == 302 or check_uri.status == 301 or check_uri.status == nil ) then
   print("|["..error_color..check_uri.status..reset_color.."] "..host.ip.." => "..uri)
   do return end --> exit if any of this error codes returns
else
   print("|["..green_color..check_uri.status..reset_color.."] "..host.ip.." => "..uri)
end
print(" _")


-- Manipulate TCP packet 'header' with false information about attacker :D
local options = {header={}}   --> manipulate 'header' request ..
options['header']['User-Agent'] = stdnse.get_script_args(SCRIPT_NAME..".agent") or "Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25" --> use iPhone,safari User-agent OR your own...
options['header']['Accept-Language'] = "en-GB,en;q=0.8,sv" --> use en-GB as attacker default install language
options['header']['Cache-Control'] = "no-store" -->  Instruct webserver to not write it to disk (do not to cache it)


-- Read response from target (http.get)
local response = http.get(host, port, uri, options)
  -- Check if host addr respondes successfull [200]
  if ( response.status == 200 ) then
    local title = string.match(response.body, "<[Tt][Ii][Tt][Ll][Ee][^>]*>([^<]*)</[Tt][Ii][Tt][Ll][Ee]>")
    print("| "..yellow_color.."AXISwebcam-recon"..reset_color..":")    
     -- List {table} of HTTP TITLE tags
     tbl = {"TL-WR740N", 
     "AXIS Video Server", 
     "Live View / - AXIS", 
     "AXIS 2400 Video Server", 
     "Network Camera TUCCAM1", 
     "AXIS 243Q(2) Blade 4.45", 
     "Network Camera Capitanía", 
     "AXIS P5514 Network Camera", 
     "AXIS Q1615 Network Camera", 
     "AXIS P1357 Network Camera", 
     "AXIS M5013 Network Camera", 
     "AXIS M3026 Network Camera", 
     "AXIS M1124 Network Camera", 
     "Network Camera Hwy285/cr43",
     "Login - Residential Gateway",  
     "Axis 2420 Video Server 2.32", 
     "AXIS Q6045-E Network Camera", 
     "AXIS Q6044-E Network Camera", 
     "Network Camera NetworkCamera", 
     "AXIS P1435-LE Network Camera", 
     "AXIS P1425-LE Network Camera", 
     "Axis 2120 Network Camera 2.34", 
     "Axis 2420 Network Camera 2.30", 
     "Axis 2420 Network Camera 2.31", 
     "Axis 2420 Network Camera 2.32", 
     "AXIS P1365 Mk II Network Camera", 
     "AXIS F34 Network Camera 6.50.2.3", 
     "AXIS 214 PTZ Network Camera 4.49", 
     "Axis 2130 PTZ Network Camera 2.30", 
     "Axis 2130 PTZ Network Camera 2.31", 
     "Axis 2130 PTZ Network Camera 2.32", 
     "AXIS P5635-E Mk II Network Camera", 
     "AXIS Q7401 Video Encoder 5.51.5.1", 
     "AXIS Q6045-E Mk II Network Camera", 
     "AXIS P1353 Network Camera 6.50.2.3", 
     "AXIS M3004 Network Camera 5.51.5.1", 
     "AXIS M1145-L Network Camera 6.50.3", 
     "AXIS M2025-LE Network Camera 8.50.1", 
     "Live view / - AXIS 205 version 4.03", 
     "Live view  - AXIS 240Q Video Server", 
     "Live view  - AXIS 221 Network Camera", 
     "Live view  - AXIS 211 Network Camera", 
     "AXIS Q1765-LE Network Camera 5.55.2.3", 
     "Live view  - AXIS P1354 Network Camera",  
     "Live view  - AXIS P1344 Network Camera", 
     "Live view  - AXIS M1114 Network Camera", 
     "Live view  - AXIS M1103 Network Camera", 
     "Live view  - AXIS M1025 Network Camera", 
     "AXIS P1354 Fixed Network Camera 6.50.3", 
     "AXIS P1354 Fixed Network Camera 5.60.1", 
     "AXIS V5914 PTZ Network Camera 5.75.1.11", 
     "Live view - AXIS P5534-E Network Camera", 
     "Live view  - AXIS 215 PTZ Network Camera", 
     "Live view  - AXIS 214 PTZ Network Camera", 
     "Live view  - AXIS 213 PTZ Network Camera", 
     "AXIS P5534 PTZ Dome Network Camera 5.51.5", 
     "AXIS Q6034-E PTZ Dome Network Camera 5.41.4", 
     "AXIS P3354 Fixed Dome Network Camera 5.40.17", 
     "AXIS Q6042-E PTZ Dome Network Camera 5.70.1.4", 
     "AXIS Q3505 Fixed Dome Network Camera 6.30.1.1", 
     "Live view - AXIS 206M Network Camera version 4.11", 
     "Live view  - AXIS 211 Network Camera version 4.11", 
     "Live view  - AXIS 211 Network Camera version 4.10", 
     "Live view / - AXIS 205 Network Camera version 4.04", 
     "Live view / - AXIS 205 Network Camera version 4.05", 
     "AXIS P5635-E Mk II PTZ Dome Network Camera 8.40.2.2", 
     "Live view / - AXIS 205 Network Camera version 4.05.1", 
     "Live view - AXIS 213 PTZ Network Camera version 4.12"}

     -- Loop Through {table} of HTTP TITLE tags
     for i, intable in pairs(tbl) do
       local validar = string.match(title, intable)
       if ( validar ~= nil or title == intable ) then
           print("|\n|   STATUS: "..green_color.."AXIS WEBCAM FOUND"..reset_color.."\n|     TITLE: "..green_color..intable..reset_color.."\n|       WEBCAM ACCESS: "..green_color.."http://"..host.ip..":"..port.number..uri..reset_color.."\n|       Module Author: "..by_module.."\n|_")
           break --> break execution (loop) if a match string its found.
        else
           print("|  TESTING: "..intable)
           os.execute("sleep 0.5")
           f = f+1 --> count how many interactions (loops done)
           if (f == 68) then --> why 68? Because its the number of TITLE tags present in the {table} list.
             print("|_")
             return "\n   STATUS: NONE AXIS WEBCAM FOUND\n     Module Author: r00t-3xp10it & Cleiton Pinheiro\n\n"
           end
        end
     end
  end
end
