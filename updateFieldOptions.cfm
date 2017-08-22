<cfinclude template="setDatasource.cfm">
<cfsetting showDebugOutput="No">

<cfset VARIABLES.PARATURE.TICKET = createObject("component","global.parature.ticket") />
<cfset delete = true >

<cfset VARIABLES.PARATURE.TICKET.SANDBOX = false />

<cfset updateFields() >
<cfset VARIABLES.PARATURE.TICKET.SANDBOX = true />
<cfset updateFields() >


<cffunction name="updateFields">

<table>
<tr>
<th>Field ID</th>
<th>Field Label</th>
<th>Option ID</th>
<th>Option Label</th>
<th>Sandbox</th>
</tr>

<cfset VARIABLES.PARATURE.TICKET.init() >

<cfset customFields = VARIABLES.PARATURE.TICKET.SCHEMA.Ticket.Custom_Field>


<cfif isDefined("customFields") and isDefined("delete") and delete eq 'true'>
	<cfquery name="deleteOptions" datasource="#dataSource#">
		DELETE FROM parature_field_option
		WHERE sandbox = <cfqueryparam value="#VARIABLES.PARATURE.TICKET.SANDBOX#">
	</cfquery>
</cfif>

<cfloop array="#customFields#" index="field">
	<cfif isDefined("field.Option")>
		<cfset fieldName = field["@display-name"]>
		<cfset fieldID = field["@id"]>
		<cfloop array="#field.Option#" index="option">
			<cfset optionID = option["@id"]>
			<cfset optionLabel = option["Value"]>
			
			<cfquery name="updateFieldLabels" datasource="#dataSource#">
				IF NOT EXISTS (SELECT fieldID FROM parature_field_option WHERE fieldID = <cfqueryparam value="#fieldID#"> and optionID = <cfqueryparam value="#optionID#"> and sandbox = <cfqueryparam value="#VARIABLES.PARATURE.TICKET.SANDBOX#">)
				BEGIN
					INSERT INTO parature_field_option (fieldName, fieldID, optionLabel, optionID, sandbox) VALUES (<cfqueryparam value="#fieldName#">, <cfqueryparam value="#fieldID#">, <cfqueryparam value="#optionLabel#">, <cfqueryparam value="#optionID#">, <cfqueryparam value="#VARIABLES.PARATURE.TICKET.SANDBOX#">)
				END
				ELSE
				BEGIN
					UPDATE parature_field_option
					SET fieldName = <cfqueryparam value="#fieldName#">,
					optionLabel = <cfqueryparam value="#optionLabel#">
					WHERE fieldID = <cfqueryparam value="#fieldID#"> 
					and optionID = <cfqueryparam value="#optionID#"> 
					and sandbox = <cfqueryparam value="#VARIABLES.PARATURE.TICKET.SANDBOX#">
				END
			</cfquery>
			
			<cfoutput>
			<tr>
			<td>#fieldID#</td>
			<td>#fieldName#</td>
			<td>#optionID#</td>
			<td>#optionLabel#</td>
			<td>#VARIABLES.PARATURE.TICKET.SANDBOX#</td>
			</tr>
			</cfoutput>
		</cfloop>	
	</cfif>
</cfloop>

</table>

</cffunction>
