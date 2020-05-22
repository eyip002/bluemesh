#!/usr/bin/python
"""=========================================================================
                              Circuit Editor


 Author: Eugene Kin Chee Yip
 Maintainer: Eugene Kin Chee Yip
 Date: 28 March 2008
 
"""

# Import required python modules
import	cherrypy		# Webserving
import	socket			# Reading local IP address of server

from functions import *

__author__ = "Eugene Kin Chee Yip"
__copyright__ = "2008"
__credits__ = "Random people"

__version__ = "0.01 alpha"
__maintainer__ = "Eugene Kin Chee Yip"
__email__ = "eugene.yip@gmail.com"
__status__ = "prototype"



class circuitEditor:
	def __init__(self):
		print "circuitEditor.__init__"
		
	#########################################################
	#                    Main webpages
	#########################################################
	
	#====== Homepage of http://localhost:80/ =========
	def index(self):
		"""This is the Homepage."""
		return "Flex demo"
	index.exposed = True
	


	#########################################################
	#                   Returning files
	#########################################################

	#============== Returns htmls =================
	def htmls(self, filename):
		"""Take a filename and return the corresponding html file."""
		return open('htmls/' + cleanFilename(filename))
		
	htmls.exposed = True


	#============== Returns images =================
	def images(self, filename):
		"""Take a filename and return the corresponding ico/gif/png/jpg."""
		cherrypy.response.headers['Content-Type'] = 'image/ico/gif/png/jpg'
		return open('images/' + cleanFilename(filename))
		
	images.exposed = True


	#============= Returns stylesheets ===============
	def stylesheets(self, filename):
		"""Take a filename and return the corresponding CSS."""
		cherrypy.response.headers['Content-Type'] = 'text/css'
		return open('stylesheets/' + cleanFilename(filename))
		
	stylesheets.exposed = True


	#============= Returns javascripts ===============
	def scripts(self, filename):
		"""Take a filename and return the corresponding javascript."""
		cherrypy.response.headers['Content-Type'] = 'text/javascript'
		return open('scripts/' + cleanFilename(filename))
		
	scripts.exposed = True


	#============= Returns flash files ===============
	def flashes(self, filename):
		"""Take a filename and return the corresponding adobe flash object."""
		cherrypy.response.headers['Content-Type'] = "application/x-shockwave-flash"
		return open(cleanFilename(filename))
	
	flashes.exposed = True


	#========== Returns java applications ============
	def javas(self, folder, filename):
		"""Take a filename and return the corresponding java applet."""
		cherrypy.response.headers['Content-Type'] = 'application/x-java-applet'
		return open('javas/' + cleanFilename(folder) + '/' + cleanFilename(filename))
		
	javas.exposed = True
	
	


#====                           ======                              ====#
#                           Server session                              #
#========================================================================

cherrypy.server.socket_host = socket.gethostbyname(socket.gethostname())
cherrypy.quickstart(circuitEditor(), config = 'serverconfig.conf')

#=================

print
print "*Done with server*"
print
