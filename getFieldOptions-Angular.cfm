<cfcontent type="application/json">
<cfinclude template="setDatasource.cfm">
<cfset useSandbox = false>

<cfquery name="getFields" datasource="#dataSource#">
	SELECT DISTINCT fieldID, fieldName
	FROM parature_field_option
	WHERE sandbox = <cfqueryparam value="#useSandbox#">
	AND (
	fieldName like ('Team') OR
	fieldName like ('Priority') OR
	fieldName like ('Module') OR
	fieldName like ('Ticket Type') OR
	fieldName like ('Product Family') OR
	fieldName like ('Priority (T)') OR
	fieldName like ('Urgency')
	)
</cfquery>

<cfset optionsList = []>
<cfset fieldset = StructNew()>

<cfloop query="getFields">

	<cfset field = StructNew()>
	<cfset StructInsert(field, "fieldID", getFields.fieldID)>
	<cfquery name="getOptions" datasource="#dataSource#">
		SELECT optionLabel, optionID
		FROM parature_field_option
		WHERE fieldID = <cfqueryparam value="#getFields.fieldID#"> and sandbox = <cfqueryparam value=#useSandbox#>
	</cfquery>
	<cfset fieldOptions = []>
	<cfloop query="getOptions">
		<cfset option = StructNew()>
		<cfscript>
			StructInsert(option, "optionLabel", getOptions.optionLabel);
			StructInsert(option, "optionID", getOptions.optionID);
		</cfscript>
		<cfset ArrayAppend(fieldOptions, option)>
	</cfloop>

	<cfset StructInsert(field, "options", fieldOptions)>
	<cfset StructInsert(fieldset, fieldName, field)>

</cfloop>
	<cfset ArrayAppend(optionsList, fieldset)>

<!---<cfdump var="#optionsList#">--->

<cfset optionsJSON = SerializeJSON(optionsList)>
<cfset optionsJSON = Replace(optionsJSON, "'", "\'", "all")>

<cfoutput>#optionsJSON#</cfoutput>
