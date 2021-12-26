#!/usr/bin/env python 
# -*- coding:utf-8 -*-
#
# @name:    Spaghetti - Web Application Security Scanner
# @repo:    https://github.com/m4ll0k/Spaghetti
# @author:  Momo Outaadi (M4ll0k)
# @license: See the file 'LICENSE.txt'

import re

from utils import output
from utils import params
from request import request

class Sql:
	def __init__(self,agent,proxy,redirect,timeout,urls,cookie):
		self.urls = urls
		self.cookie = cookie
		self.output = output.Output()
		self.request = request.Request(
			agent = agent,
			proxy = proxy,
			redirect = redirect,
			timeout = timeout
			)

	def dberror(self,data):
		if re.search(r'supplied argument is not a valid MySQL|Column count doesn\'t match value count at row|mysql_fetch_array()|on MySQL result index|You have an error in your SQL syntax;|You have an error in your SQL syntax near|MySQL server version for the right syntax to use|\[MySQL]\[ODBC|Column count doesn\'t match|valid MySQL result|MySqlClient.',data):
			return "MySQL Injection"
		if re.search(r'System.Data.OleDb.OleDbException|\[Microsoft]\[ODBC SQL Server Driver]|\[Macromedia]\[SQLServer JDBC Driver]|SqlException|System.Data.SqlClient.SqlException|Unclosed quotation mark after the character string|mssql_query()|Microsoft OLE DB Provider for ODBC Drivers|Microsoft OLE DB Provider for SQL Server|Incorrect syntax near|Sintaxis incorrecta cerca de|Syntax error in string in query expression|Unclosed quotation mark before the character string|Data type mismatch in criteria expression.|ADODB.Field (0x800A0BCD)|the used select statements have different number of columns',data):
			return "MSSQL-Based Injection"
		if re.search(r'java.sql.SQLException|java.sql.SQLSyntaxErrorException|org.hibernate.QueryException: unexpected char:|org.hibernate.QueryException: expecting \'',data):
			return "Java.SQL Injection"
		if re.search(r'PostgreSQL query failed:|supplied argument is not a valid PostgreSQL result|pg_query() \[:|pg_exec() \[:|valid PostgreSQL result|Npgsql.|PostgreSQL query failed: ERROR: parser:',data):
			return "PostgreSQL Injection"
		if re.search(r'\[IBM]\[CLI Driver]\[DB2/6000]|DB2 SQL error',data):
			return "DB2 Injection"
		if re.search(r'<b>Warning</b>: ibase_|Unexpected end of command in statement|Dynamic SQL Error',data):
			return "Interbase Injection"
		if re.search(r'Sybase message:',data):
			return "Sybase Injection"
		if re.search(r'Oracle error',data):
			return "Oracle Injection"
		if re.search(r'SQLite/JDBCDriver|System.Data.SQLite.SQLiteException|SQLITE_ERROR|SQLite.Exception',data):
			return "SQLite Injection"
		return None
	
	def run(self):
		info = {
		'name'        : 'Sql',
		'fullname'    : 'SQL Injection',
		'author'      : 'Momo Outaadi (M4ll0k)',
		'description' : 'Find SQL Injection Vulnerability'
		}
		self.output.test('Checking sql injection...')
		db = open('data/sql.txt','rb')
		dbfiles = [x.split('\n') for x in db]
		try:
			for payload in dbfiles:
				for url in self.urls:
					# replace queries with payload
					param = params.Params(url,payload[0]).process()
					if len(param) > 1:
						for para in param:
							resp = self.request.send(
								url = para,
								method = "GET",
								payload = None,
								headers = None,
								cookies = self.cookie
								)
							erro = self.dberror(resp.content)
							if erro != None:
								self.output.plus('That site is may be vulnerable to %s at %s'%(erro,para))
					
					elif len(param) == 1:
						resp = self.request.send(
							url = param[0],
							method = "GET",
							payload = None,
							headers = None,
							cookies = self.cookie
							)
						erro = self.dberror(resp.content)
						if erro != None:
							self.output.plus('That site is may be vulnerable to %s at %s'%(erro,param[0]))
		except Exception,e:
			pass
