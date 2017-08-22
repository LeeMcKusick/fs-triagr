<cfcontent type="application/json">
<cfsetting showDebugOutput="No">
<cfinclude template="trello.cfm">
<cfinclude template="setDatasource.cfm">

<cfif isDefined('URL.ticket')>
	<cfset ticketNum = URL.ticket>
<cfelse>
	<cfset ticketNum = 0>
</cfif>

<cfset TICK = createObject("component","global.parature.ticket") />
<cfset TICK.SANDBOX = useSandbox />
<cfset theTicket = TICK.init( Int(ticketNum), '&_history_=true')>
<cfset actions = theTicket.Ticket.Ticket.ActionHistory.History>

<!---<cfdump var="#actions#">--->
<!---
--->
<cfset history = []>

<cfscript>
	for (action in actions) {
	
		a = StructNew();
		//StructInsert(a, 'date', action.Action_Date['##text']);
		a['date'] = action.Action_Date['##text'];
		a['type'] = action.Action['@name'];
		try {

			a['comments'] = action.Comments['##text'];
		} catch (any e) {
			a['comments'] = '';
		}
		a['showToCust'] = action.Show_To_Customer['##text'];
		
		
		if ( isDefined('action.Action_Performer.Csr.Full_Name') ){
			a['performer']['name'] = action.Action_Performer.Csr.Full_Name['##text'];
		} else if ( isDefined('action.Action_Performer.Customer.Full_Name') ) { 
			a['performer']['name'] = action.Action_Performer.Customer.Full_Name['##text'];
		} else {
			a['performer']['name'] = 'System';
		}
		a['performer']['type'] = action.Action_Performer['@performer-type'];
		
		if ( isDefined('action.Action_Target.Csr.Full_Name') ){
			a['target'] = action.Action_Target.Csr.Full_Name['##text'];
		} else { 
			a['target'] = 'System';
		}
		
		ArrayPrepend(history, a);
	
	}
</cfscript>

<cfoutput>#SerializeJSON(history)#</cfoutput>

