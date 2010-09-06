-- $Id: t-dontsign.lua,v 1.6 2010/09/06 06:41:46 grooverdan Exp $

-- Copyright (c) 2009, 2010, The OpenDKIM Project.  All rights reserved.

-- "DontSignMailTo" test
-- 
-- Confirms that a signature is not added for a specific recipient.

mt.echo("*** DontSignMailTo test")

-- try to start the filter
sock = "unix:" .. mt.getcwd() .. "/test.sock"
binpath = mt.getcwd() .. "/.."
if os.getenv("srcdir") ~= nil then
	mt.chdir(os.getenv("srcdir"))
end
mt.startfilter(binpath .. "/opendkim", "-x", "t-dontsign.conf", "-p", sock)

-- try to connect to it
e, conn = pcall(mt.connect, sock)
timeout = 20
while not e and timeout > 0
do
	mt.sleep(0.01)
	timeout = timeout - 1
	e, conn = pcall(mt.connect, sock)
end
if not e then
	error( "mt.connect() failed " , conn)
end

-- send connection information
-- mt.negotiate() is called implicitly
if mt.conninfo(conn, "localhost", "127.0.0.1") ~= nil then
	error "mt.conninfo() failed"
end
if mt.getreply(conn) ~= SMFIR_CONTINUE then
	error "mt.conninfo() unexpected reply"
end

-- send envelope macros and sender data
-- mt.helo() is called implicitly
mt.macro(conn, SMFIC_MAIL, "i", "t-dontsign")
if mt.mailfrom(conn, "user@example.com") ~= nil then
	error "mt.mailfrom() failed"
end
if mt.getreply(conn) ~= SMFIR_CONTINUE then
	error "mt.mailfrom() unexpected reply"
end

-- send envelope macros and recipient data
if mt.rcptto(conn, "recipient@example.org") ~= nil then
	error "mt.rcptto() failed"
end
if mt.getreply(conn) ~= SMFIR_CONTINUE then
	error "mt.rcptto() unexpected reply"
end

-- send headers
if mt.header(conn, "From", "user@example.com") ~= nil then
	error "mt.header(From) failed"
end
if mt.getreply(conn) ~= SMFIR_CONTINUE then
	error "mt.header(From) unexpected reply"
end
if mt.header(conn, "Date", "Tue, 22 Dec 2009 13:04:12 -0800") ~= nil then
	error "mt.header(Date) failed"
end
if mt.getreply(conn) ~= SMFIR_CONTINUE then
	error "mt.header(Date) unexpected reply"
end
if mt.header(conn, "Subject", "Signing test") ~= nil then
	error "mt.header(Subject) failed"
end
if mt.getreply(conn) ~= SMFIR_CONTINUE then
	error "mt.header(Subject) unexpected reply"
end

-- send EOH
if mt.eoh(conn) ~= nil then
	error "mt.eoh() failed"
end
if mt.getreply(conn) ~= SMFIR_ACCEPT then
	error "mt.eoh() unexpected reply"
end
