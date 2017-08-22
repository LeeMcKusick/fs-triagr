<cfset VARIABLES.PARATURE.SLA = createObject("component","global.parature.web_service") />


<cfinclude template="setDatasource.cfm">

<cfset VARIABLES.PARATURE.SLA.SANDBOX = false />
<cfset updateSlaData() >
<cfset VARIABLES.PARATURE.SLA.SANDBOX = true />
<cfset updateSlaData() >






<cffunction name="updateSlaData">
	<cfset callData = VARIABLES.PARATURE.SLA.call("list", "Sla")>
	<cfset slas = callData.Sla>
	
	<cfquery name="deleteSLAs" datasource="#dataSource#">
		DELETE from parature_sla
		where sandbox = <cfqueryparam value="#VARIABLES.PARATURE.SLA.SANDBOX#">
	</cfquery>
	<cfoutput><h3>Sandbox: #VARIABLES.PARATURE.SLA.SANDBOX#. SLAs deleted</h3></cfoutput>
	<cfloop array="#slas#" index="i">

		<cfset slaId = i["@id"] >
		<cfset slaName = i.Name["##text"]>
		<cfquery name="updateSLAs" datasource="#dataSource#">
			IF NOT EXISTS (SELECT slaID FROM parature_sla WHERE slaID = <cfqueryparam value="#slaId#"> and sandbox = <cfqueryparam value="#VARIABLES.PARATURE.SLA.SANDBOX#">)
			BEGIN
				INSERT INTO parature_sla (slaID, slaName, sandbox) VALUES (<cfqueryparam value="#slaId#">, <cfqueryparam value="#slaName#">, <cfqueryparam value="#VARIABLES.PARATURE.SLA.SANDBOX#">)
			END
			ELSE
			BEGIN
				UPDATE parature_sla
				SET slaName = <cfqueryparam value="#slaName#">
				WHERE slaID = <cfqueryparam value="#slaId#">
				and sandbox = <cfqueryparam value="#VARIABLES.PARATURE.SLA.SANDBOX#">
			END
		</cfquery>
		<cfoutput>		
			#slaId# : #slaName# Added<br>
		</cfoutput>
	</cfloop>
</cffunction>