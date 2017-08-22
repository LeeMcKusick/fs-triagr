<cfcontent type="application/json">

<cfsetting showDebugOutput="No">

<!--- Get some configuration variables from Trello (Application Settings board --->
<cfinclude template="trello.cfm">

<!--- Sets the datasource based on the server
(since cfdev01 has a different datasource name for rss --->
<cfinclude template="setDatasource.cfm">

<!--- Are we using the sandbox environment? --->
<cfif isdefined('URL.sandbox')>
	<cfset sandbox = URL.sandbox />
<cfelse>
	<cfset sandbox = false />
</cfif>

<!--- What is the ticket view ID that we're using? --->
<cfif sandbox>
	<cfif isdefined('URL.ticketViewIDSandbox')>
		<cfset view = URL.ticketViewIDSandbox>
	<cfelseif isdefined('FORM.ticketViewIDSandbox')>
		<cfset view = FORM.ticketViewIDSandbox>
	<cfelse>
		<cfset view = 12004>
	</cfif>
<cfelse>
	<cfif isdefined('URL.ticketViewID')>
		<cfset view = URL.ticketViewID>
	<cfelseif isdefined('FORM.ticketViewID')>
		<cfset view = FORM.ticketViewID>
	<cfelse>
		<cfset view = 12004>
	</cfif>
</cfif>

<!--- PAGE SIZE--->
<cfif isdefined('URL.ticketsToPull')>
	<cfset ticketsToPull = URL.ticketsToPull>
<cfelseif isdefined('FORM.ticketsToPull')>
	<cfset ticketsToPull = FORM.ticketsToPull>
<cfelse>
	<cfset ticketsToPull = 500>
</cfif>

<!--- ORDER --->
<cfif isdefined('URL.order') and len(trim(URL.order))>
	<cfset order = "&_order_=" & URL.order>
<cfelseif isdefined('FORM.order') and len(trim(FORM.order))>
	<cfset order = "&_order_=" & FORM.order>
<cfelse>
	<cfset order = "">
</cfif>

<cfset myTickets = false>
<cfif isDefined('URL.myTickets') and URL.myTickets>
	<cfset myTickets = true>
</cfif>



<!--- Create the connection to Parature --->
<cfset TICK = createObject("component","global.parature.ticket") />
<cfset TICK.SANDBOX = sandbox />
<cfif myTickets>
	<cfset para_ticket_list = TICK.getList(
		parameters = "&_my_tickets_=true&_status_type_=open&_view_=12093",
		api_key = session.apiKey
	) />
<cfelse>
	<cfset para_ticket_list = TICK.getList(
		parameters = "&_pageSize_=" & ticketsToPull & "&_view_=" & view & order
	) />
</cfif>

<!--- Create object to hold tickets. --->
<cfset tickets = []>

<!--- If a ticket exists, loop over the Ticket object (this contains other tickets), and build the ticket object. --->
<cfif IsDefined("para_ticket_list.Ticket")>
	<cfloop array="#para_ticket_list.Ticket#" index="t">
		<cfset ticket = {}>
		<cfset ticket['num'] = t["@id"] >
		<cfset ticket['url'] = t["@service-desk-uri"] >
		<cfset ticket['contact']['id'] = t.Ticket_Customer.Customer["@id"] >
		<cfset ticket['contact']['name'] = t.Ticket_Customer.Customer.Full_Name["##text"] >
		<cfset ticket['dateCreated'] = t.Date_Created["##text"] >
		<cfset ticket['dateUpdated'] = t.Date_Updated["##text"] >

		<cfif isDefined('t.Ticket_Queue.Queue')>
			<cfset ticket['queue'] = t.Ticket_Queue.Queue.Name["##text"] >
		</cfif>

		<cfset ticket['status'] = t.Ticket_Status.Status.Name["##Text"]>
		<cfset ticket['enteredBy'] = ''>

		<cfif IsDefined('t.Entered_By.Csr.Full_Name')>
			<cfset ticket['enteredBy'] = t.Entered_By.Csr.Full_Name["##Text"]>
		</cfif>

		<cfset ticket['initialResponseUser'] = ''>
		<cfif IsDefined('t.Initial_Response_Userid.Csr.Full_Name')>
			<cfset ticket['initialResponseUser'] = t.Initial_Response_Userid.Csr.Full_Name["##Text"]>
		</cfif>



		<cfset ticket['summary'] = ''>
		<cfset ticket['details'] = ''>
		<cfset ticket['team'] = ''>
		<cfset ticket['teamLabel'] = ''>
		<cfset ticket['module'] = ''>
		<cfset ticket['moduleLabel'] = ''>
		<cfset ticket['priority'] = ''>
		<cfset ticket['priorityLabel'] = ''>
		<cfset ticket['priority'] = ''>
		<cfset ticket['priorityLabel'] = ''>
		<cfset ticket['initialPriority'] = ''>
		<cfset ticket['initialPriorityLabel'] = ''>
		<cfset ticket['urgency'] = ''>
		<cfset ticket['urgencyLabel'] = ''>
		<cfset ticket['ticketType'] = ''>
		<cfset ticket['ticketTypeLabel'] = ''>
		<cfset ticket['subtype'] = ''>
		<cfset ticket['internalType'] = ''>
		<cfset ticket['internalTypeLabel'] = ''>
		<cfset ticket['bugNumber'] = ''>
		<cfset ticket['relevanturl'] = ''>
		<cfset ticket['busyNotification'] = false>
		<cfset ticket['vacation'] = false>


		<cfset attachments = []>
		<cfif IsDefined('t.Ticket_Attachments.Attachment')>
			<cfloop array="#t.Ticket_Attachments.Attachment#" index="att">
				<cfscript>
					attach = {};
					attach['url'] = att["@href"];
					attach['name'] = att.Name;
					ArrayAppend(attachments, attach);
				</cfscript>
			</cfloop>
		</cfif>
		<cfset ticket['attachments'] = attachments>

		<cfloop array="#t.Custom_Field#" index="cf">
			<cfscript>
				if ( cf["@display-name"] IS "Summary"){
					try {
						ticket['summary'] = cf["##text"];
					} catch (any e) {
						ticket['summary'] = '';
					}
				} else if ( cf["@display-name"] IS "Details"){
					try {
						ticket['details'] = cf["##text"];
						ticket['details'] = Replace(ticket['details'], "#chr(10)##chr(10)#", "</p><p>", "all");
						ticket['details'] = "<p>" & ticket['details'] & "</p>";
					} catch (any e) {
						ticket['details'] = '';
					}
				} else if ( cf["@display-name"] IS "URL/Page ID of Relevant Page"){
					try {
						ticket['relevanturl'] = cf["##text"];
					} catch (any e) {
						ticket['relevanturl'] = '';
					}
				} else if ( cf["@display-name"] IS "Dev Number"){
					try {
						ticket['bugNumber'] = cf["##text"];
					} catch (any e) {
						ticket['bugNumber'] = '';
					}
				}
			</cfscript>

			<cfif cf["@data-type"] eq "option">
				<cfloop array="#cf.Option#" index="o">
					<cfif StructKeyExists(o, "@selected") and o["@selected"] eq true>
						<cfscript>
							if (cf["@display-name"] IS 'Team') {
								ticket['team'] = o["@id"];
								ticket['teamLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Priority') {
								ticket['priority'] = o["@id"];
								ticket['priorityLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Priority (T)') {
								ticket['initialPriority'] = o["@id"];
								ticket['initialPriorityLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Module') {
								ticket['module'] = o["@id"];
								ticket['moduleLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Ticket Type') {
								ticket['ticketType'] = o["@id"];
								ticket['ticketTypeLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Urgency') {
								ticket['urgency'] = o["@id"];
								ticket['urgencyLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Internal Type') {
								ticket['internalType'] = o["@id"];
								ticket['internalTypeLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Service Type') {
								ticket['subtype'] = o.Value;
							} else if (cf["@display-name"] IS 'Product Family') {
								ticket['productFamily'] = o["@id"];;
								ticket['productFamilyLabel'] = o.Value;
							} else if (cf["@display-name"] IS 'Is On Vacation (T)') {
								ticket['vacation'] = true;
							} else if (cf["@display-name"] IS 'Priority Level Alert (T)') {
								ticket['busyNotification'] = true;
							}
						</cfscript>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop> <!--- End of custom fields --->

		<!--- Query our database of accounts for account data:
					Account Name,	SLA,	Server,
					Keyword,		URL,	Name
					--->
		<cfquery name="getAccount" datasource="#dataSource#">
			SELECT pa.parature_accountid, pa.parature_accountname, pa.sla, pas.theme, psla.slaName, pa.date_updated, pas.url, pas.server, pas.keyword, pas.composer, pas.composer_redesign
			FROM parature_account pa INNER JOIN (Select slaID, slaName from parature_sla where sandbox = <cfqueryparam value="#sandbox#">) psla on pa.sla = psla.slaID
			LEFT JOIN   parature_accounts AS pas ON pa.parature_accountid = pas.accountID
			WHERE pa.parature_customerid = <cfqueryparam value="#ticket.contact.id#">
		</cfquery>

		<!--- Build Account object --->
		<cfset ticket['account'] = {}>
		<cfset ticket['account']['id'] = getAccount.parature_accountid >
		<cfset ticket['account']['name'] = getAccount.parature_accountname >
		<cfset ticket['account']['sla'] = getAccount.sla >
		<cfset ticket['account']['slaName'] = getAccount.slaName >
		<cfset ticket['account']['url'] = getAccount.url >
		<cfset ticket['account']['server'] = getAccount.server >
		<cfset ticket['account']['keyword'] = getAccount.keyword >
		<cfset ticket['account']['composer'] = getAccount.composer >
		<cfset ticket['account']['theme'] = getAccount.theme >
		<cfset ticket['account']['composer_redesign'] = getAccount.composer_redesign >


		<!--- Tack on the ticket to our master list --->
		<cfset ArrayPrepend(tickets, ticket)>
	</cfloop> <!--- End of tickets --->
</cfif>

<!--- Spit it all out as JSON data --->
<cfoutput>#SerializeJSON(tickets)#</cfoutput>
