                                                         January 2011
 
This directory contains procedures which use the IDL SOCKET command to access
Web servers.  

The Infrared Science Archive (IRSA) has a similar set of tools for accessing 
their catalogs -- see  http://irsa.ipac.caltech.edu/tools/irsa_idl.html

Dominic Zarro (LAC/GSFC) has written an independent set of routines to use IDL
sockets to access Web servers.   His routines use object-oriented code and are
available at http://beauty.nascom.nasa.gov/~zarro/idl/sockets/sockets.html

WEBGET() - Use the IDL SOCKET procedure to get data from http servers
QUERYGSC() - Query the Guide Star Catalog (GSC V2.3.2) at the Space
    Telescope Science Institute by position  
QUERYDSS - Query the digital sky survey (DSS) on-line at the European
     Space Observatory (ESO) or STSCI servers
QUERYSIMBAD - Query the SIMBAD or NED name resolvers to obtain J2000
     coordinates
QUERYVIZIER - Positional query of any catalog in the VIZIER database

Dec 2007: QUERYUSNO (to query USNO-A2 catalog) has been removed since the newer
USNO-B1 catalog can be queried with QUERYIVIZIER, e.g.  
IDL> info = queryvizier('usno-b1','m13',5)
