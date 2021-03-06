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
		most_recent = c.fetchone()[0]
		
		# if there are no entries yet
		if most_recent == None:
			return True

		now = int(time.mktime(time.localtime()))

		# if the last time we sent was more than 2 hours ago
		# then send again!
		two_hours = 3600

		if now - most_recent >= two_hours:
			return True
		else:
			return False

	def log_report(self):
		query = "INSERT INTO log values(CURRENT_TIMESTAMP)"
		c = self.conn.cursor()
		c.execute(query)