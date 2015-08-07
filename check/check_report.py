"""
	A simple module to manage when we should
	send reports for check scripts

	Keep around an sqlite db
"""
import sqlite3
import time

class Check():

	def __init__(self, db):
		self.conn = sqlite3.connect(db)

	# source will either be disk || memory
	def should_report(self):

		query = "SELECT max(sent) FROM log"
		c = self.conn.cursor()
		c.execute(query)
		most_recent = c.fetchone()
		
		recent_epoch = time.mktime(time.strptime(most_recent[0], "%Y-%m-%d %H:%M:%S"))
		now = time.mktime(time.localtime())

		print now
		print recent_epoch

