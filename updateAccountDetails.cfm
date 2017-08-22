<cfcontent type="application/json">
<cfinclude template="setDatasource.cfm">
<cfset sandbox = false>

<cfset accID = URL.account>
<cfquery name="siteInfo" dataSource="sites" result="acc">
	SET ARITHABORT ON;
	SELECT
		sitename,
		server,
		ds AS keyword, -- Data Source
		diskpercent, -- Disk Usage Percentage Used
		integrationInfo, -- Integration Notes
		sitestats.value('(/sitestats//metaInfo/siteInfo/accelerator/node())[1]', 'bit') AS accelerator,
		sitestats.value('(/sitestats//metaInfo/siteInfo/clienttype/node())[1]', 'varchar(500)') AS clientType,
		sitestats.value('(/sitestats//metaInfo/siteInfo/internalnotes/node())[1]', 'varchar(5000)') AS internal_notes,
		sitestats.value('(/sitestats//metaInfo/siteInfo/url/node())[1]', 'varchar(200)') AS site_url,
		sitestats.value('(/sitestats//metaInfo/siteInfo/country/node())[1]', 'varchar(200)') AS country,
		sitestats.value('(/sitestats//metaInfo/siteInfo/cdn/node())[1]', 'varchar(200)') AS cdn, --CDN Enabled 1 or 0
		sitestats.value('(/sitestats//metaInfo/siteInfo/diskspace/node())[1]', 'int') AS diskspacetotal,
		sitestats.value('(/sitestats//metaInfo/siteInfo/ga_account/node())[1]', 'varchar(200)') AS ga_account,
		sitestats.value('(/sitestats//metaInfo/siteInfo/diskSpaceUsed/node())[1]', 'float') AS diskSpaceUsed,
		sitestats.value('(/sitestats//metaInfo/siteInfo/diskspace/node())[1]', 'int') AS diskSpace,
		sitestats.value('(/sitestats//metaInfo/siteInfo/timezoneid/node())[1]', 'varchar(200)') AS timeZone,
		/* SALESFORCE Data */
		sf_project_manager, -- Project Manager
		sf_support_comments, -- Anthonys Client Comments
		sf_hosting, -- Total Purchased Disk Space
		sf_billingCity,
		sf_billingState,
		sf_billingCountry,
		sf_billingStreet,
		sf_billingPostalCode,
		sf_phone,
		sf_account_owner,
		sf_website,
		sf_acc_stage,
		sf_client_gauge
		FROM sites 
		WHERE sitestats.value('(/sitestats/metaInfo/siteInfo/parature_account/node())[1]', 'nvarchar(300)') LIKE (<cfqueryparam value="#accID#">) AND sitename not like ('%Batch:%') and sitename not like ('%Enotify:%') AND sitename not like ('%ical:%') AND sitename not like ('%alert:%');
</cfquery>
		
		<!---<cfdump var="#acc#">
		<cfdump var="#siteInfo#">--->
		
<cfset account = {} >
<cfif siteInfo.RecordCount gt 0>	

<cfloop query="siteInfo">
	<cfscript>
		account['id'] = accID;
		account['name'] = trim(siteInfo.sitename);
		account['server'] = trim(siteInfo.server);
		account['keyword'] = trim(siteInfo.keyword);
		account['diskSpaceUsed'] = trim(siteInfo.diskSpaceUsed);
		account['accelerator'] = trim(siteInfo.accelerator);
		account['notes'] = trim(siteInfo.internal_notes);
		account['url'] = trim(siteInfo.site_url);
		account['sf_url'] = trim(LCase(siteInfo.sf_website));
		account['cdn'] = trim(siteInfo.cdn);
		account['phone'] = trim(siteInfo.sf_phone);
		account['googleAccountID'] = trim(siteInfo.ga_account);
		account['clientType'] = trim(siteInfo.clientType);
		account['projectManager'] = trim(siteInfo.sf_project_manager);
		account['diskSpaceMax'] = trim(siteInfo.diskSpace);
		account['timeZone'] = trim(siteInfo.timeZone);
		account['city'] = trim(siteInfo.sf_billingCity);
		account['state'] = trim(siteInfo.sf_billingState);
		account['country'] = trim(siteInfo.sf_billingCountry);
		account['address1'] = trim(siteInfo.sf_billingStreet);
		account['zip'] = trim(siteInfo.sf_billingPostalCode);
		account['clientSuccessManager'] = trim(siteInfo.sf_account_owner);
		account['happiness'] = trim(siteInfo.sf_client_gauge);
	</cfscript>
</cfloop>
		<!---<cfdump var="#account#">--->
<cfquery name="updateAccount" datasource="#dataSource#">
	IF NOT EXISTS (SELECT accountID FROM parature_accounts WHERE accountID = <cfqueryparam value="#accID#"> and sandbox = <cfqueryparam value="#sandbox#">)
		BEGIN
			INSERT INTO parature_accounts (
				accountID,
				accountName,
				keyword,
				url,
				sf_url,
				server,
				address,
				city,
				state,
				zip,
				country,
				clientType,
				projectManager,
				cdnEnabled,
				diskSpaceCurrent,
				diskSpaceMax,
				internalNotes,
				timeZone,
				phoneNumber,
				googleAccountID,
				accelerator,
				happiness,
				clientSuccessManager,
				sandbox,
				lastUpdated )
			VALUES (
				<cfqueryparam value="#account['id']#">,
				<cfqueryparam value="#account['name']#">,
				<cfqueryparam value="#account['keyword']#">,
				<cfqueryparam value="#account['url']#">,
				<cfqueryparam value="#account['sf_url']#">,
				<cfqueryparam value="#account['server']#">,
				<cfqueryparam value="#account['address1']#">,
				<cfqueryparam value="#account['city']#">,
				<cfqueryparam value="#account['state']#">,
				<cfqueryparam value="#account['zip']#">,
				<cfqueryparam value="#account['country']#">,
				<cfqueryparam value="#account['clientType']#">,
				<cfqueryparam value="#account['projectManager']#">,
				<cfqueryparam value="#account['cdn']#">,
				<cfqueryparam value="#account['diskSpaceUsed']#">,
				<cfqueryparam value="#account['diskSpaceMax']#">,
				<cfqueryparam value="#account['notes']#">,
				<cfqueryparam value="#account['timeZone']#">,
				<cfqueryparam value="#account['phone']#">,
				<cfqueryparam value="#account['googleAccountID']#">,
				<cfqueryparam value="#account['accelerator']#">,
				<cfqueryparam value="#account['happiness']#">,
				<cfqueryparam value="#account['clientSuccessManager']#">,
				<cfqueryparam value="#sandbox#">,
				<cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
			);
		END
		ELSE 
		BEGIN
			UPDATE parature_accounts
			SET
				accountName = <cfqueryparam value="#account['name']#">,
				keyword = <cfqueryparam value="#account['keyword']#">,
				url = <cfqueryparam value="#account['url']#">,
				sf_url = <cfqueryparam value="#account['sf_url']#">,
				server = <cfqueryparam value="#account['server']#">,
				address = <cfqueryparam value="#account['address1']#">,
				city = <cfqueryparam value="#account['city']#">,
				state = <cfqueryparam value="#account['state']#">,
				zip = <cfqueryparam value="#account['zip']#">,
				country = <cfqueryparam value="#account['country']#">,
				clientType = <cfqueryparam value="#account['clientType']#">,
				projectManager = <cfqueryparam value="#account['projectManager']#">,
				cdnEnabled = <cfqueryparam value="#account['cdn']#">,
				diskSpaceCurrent = <cfqueryparam value="#account['diskSpaceUsed']#">,
				diskSpaceMax = <cfqueryparam value="#account['diskSpaceMax']#">,
				internalNotes = <cfqueryparam value="#account['notes']#">,
				timeZone = <cfqueryparam value="#account['timeZone']#">,
				phoneNumber = <cfqueryparam value="#account['phone']#">,
				googleAccountID = <cfqueryparam value="#account['googleAccountID']#">,
				accelerator = <cfqueryparam value="#account['accelerator']#">,
				happiness = <cfqueryparam value="#account['happiness']#">,
				clientSuccessManager = <cfqueryparam value="#account['clientSuccessManager']#">,
				lastUpdated = <cfqueryparam value="#Now()#" cfsqltype="cf_sql_timestamp">
			WHERE accountID = <cfqueryparam value="#account['id']#"> 
				and sandbox = <cfqueryparam value="#sandbox#">;
		END
</cfquery>

</cfif>

	
	<cfoutput>#SerializeJSON(account)#</cfoutput>