<cfscript>
//cfdev01 has a different datasource name for the rss DB.
serverName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
if ( FindNoCase( 'fsdevcf01' , serverName) > 0) 
{ dataSource = 'rss_cfauxsql03'; 
} else { dataSource = 'rss'; }
</cfscript>