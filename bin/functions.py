#=========================================================================
#                              StockShaping
#
# Functions defined for use for the "StockShaping" pythonic programme
#
# Author: Eugene Kin Chee Yip
# Maintainer: Eugene Kin Chee Yip
# Date: 8 Jan 2008


# Define list of good characters for URLs.  Define additional list of of good characters for comments.
# Define list of HTML equivalent symbols needed to be escaped.
goodChars_CONST = "_ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."
goodSymbols_CONST = "~`!@#$%^&*()+-={}[]|:;<>,/?" + "\\\"\'\n\r"		# + "_ ."
htmlSymbols = {"\\": "&#92;", "\"": "&quot;", "\'": "&#39;", "\n": "<br/>", "\r": "<br/>"}



#########################################################
#                    Functions
#########################################################


# Function that limits available characters for file/pathnames.
# Used in: Serving media files.
def cleanFilename(filename):
	"""Makes sure filename only contains safe characters."""
	return "".join([ch if ch in goodChars_CONST else "" for ch in filename])


# Function to open a file/pathname in one line of code as read-only.
# File is read into a string; ready for substitutions.
# Used in: Retrieving HTML that requires substitution.
def openFile(filename):
	"""Opens a file specified by the file/pathname."""
	file = open(filename, 'r')
	result = file.read()
	file.close()
	return result


# Function to clean a string so that it does not contain any syntax
# sensitive characters.
# Used in: Posting of comments.
def cleanString(string):
	"""Escapes syntax sensitive characters to asci characters."""
	return "".join([htmlSymbols[ch] if ch in htmlSymbols else ch for ch in string.replace("\r\n", "<br/>")])
	
	
	
	
	
	
