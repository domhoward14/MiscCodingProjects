#!/bin/bash

import Queue, time, threading, datetime, urllib2

hosts = ["http://apple.com", "http://amazon.com", "http://amazon.com"]

queue = Queue.Queue()

class UrlThread(threading.Thread):
	def __init__(self, queue):
		threading.Thread.__init__(self)
		self.queue = queue
	
	def run (self):
		while True:
			host = self.queue.get()
			response = urllib2.urlopen(host)
			html = response.read()
			print html
			self.queue.task_done()
	
def main():

	for host in hosts:
		queue.put(host)
	for t in range(3):
		thread = UrlThread(queue)
		thread.setDaemon(True)
		thread.start()
	queue.join()	
main()
print "got here"	
