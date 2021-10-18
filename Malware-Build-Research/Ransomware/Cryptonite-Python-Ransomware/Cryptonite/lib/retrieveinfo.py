import sqlite3

def victim_details():
    connection = sqlite3.connect("Details.db")
    cursor = connection.cursor()
    details = cursor.execute("SELECT * FROM VICTIMS")       
    data_list = details.fetchall()
    return data_list

def fetch_data():
    details = victim_details()
    lat_list = []
    long_list = []
    place_list = []
    unique_key = []
    hostname = []
    dec_key = []
    ip_addr = []
    for detail in details:
        unique_key.append(detail[0])
        hostname.append(detail[1])
        dec_key.append(detail[2])
        ip_addr.append(detail[3])
        lat_list.append(detail[4])
        long_list.append(detail[5])
        place_list.append(detail[6])
    return ( unique_key, hostname, dec_key, ip_addr, lat_list, long_list, place_list)

def query(unique_key):
    connection = sqlite3.connect("Details.db")
    cursor = connection.cursor()
    details = cursor.execute(f"SELECT * FROM VICTIMS WHERE UniqueId='{unique_key}'")
    details = details.fetchall()
    lat_list = []
    long_list = []
    place_list = []
    unique_key = []
    hostname = []
    dec_key = []
    ip_addr = []
    for detail in details:
        unique_key.append(detail[0])
        hostname.append(detail[1])
        dec_key.append(detail[2])
        ip_addr.append(detail[3])
        lat_list.append(detail[4])
        long_list.append(detail[5])
        place_list.append(detail[6])
    return ( unique_key, hostname, dec_key, ip_addr, lat_list, long_list, place_list)

def delete(unique_key):
    connection = sqlite3.connect("Details.db")
    cursor = connection.cursor()
    cursor.execute(f"DELETE FROM VICTIMS WHERE UniqueId='{unique_key}'")
    connection.commit()
    cursor.close()