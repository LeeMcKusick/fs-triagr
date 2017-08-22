<cfcomponent name="triagr">

	<!--- Define the application settings. ---> 
	<cfset this.name = "triagr" />
    <cfsetting showDebugOutput="No">
	<cfset this.applicationTimeout = createTimeSpan( 2, 0, 0, 0 ) />
	<cfset this.sessionManagement = "Yes">
	<cfset this.sessionTimeout = createTimeSpan( 0, 4, 0, 0 ) />

	<!--- Get the root of the application so that we can start creating mappings that are relative to the current directory. --->
	<cfset this.root = expandPath("../") />
	
	
	
	
	<!--- Now that we have the root directory, let's set up mappings for our assets --->
	<cfset this.mappings[ "/root" ] = "#this.root#" />
	<cfset this.mappings[ "/triage" ] = "#this.root#triagr\" />
	<cfset this.mappings[ "/triagecf" ] = "#this.root#triagr\cf\" />
	<cfset this.mappings[ "/global" ] = "#this.root#assets\cfc\" />
 
	<cfset this.wschannels=[{name="paratureTickets",cfclistener="myTicketListener"}]>

	

	<cfinclude template="setDatasource.cfm">

	<cffunction name="OnRequestStart"> 
		<cfargument name = "request" required="true"/> 
		<cfif IsDefined("Form.logout")> 
			<cflogout> 
		</cfif> 
	 
		<cflogin> 
			<cfif NOT IsDefined("cflogin")> 
				<cfinclude template="loginform.cfm"> 
				<cfabort> 
			<cfelse> 
				<cfif cflogin.name IS "" OR cflogin.password IS ""> 
					<cfoutput> 
						<script>alert( 'You must enter text in both the User Name and Password fields.' );</script>
					</cfoutput> 
					<cfinclude template="loginform.cfm"> 
					<cfabort> 
				<cfelse> 
					<cfquery name="loginQuery" dataSource="#dataSource#"> 
						SELECT        pc.name, tu.password, tu.roles, pc.email, pt.parature_token
						FROM            triagr_users AS tu INNER JOIN
                         parature_csr AS pc ON tu.id = pc.id INNER JOIN
                         parature_csr_n_token AS pcnt ON pc.id = pcnt.parature_csr_id INNER JOIN
                         parature_token AS pt ON pcnt.parature_token_id = pt.keyid
					WHERE 
						pc.email = '#cflogin.name#' 
						AND tu.password = '#cflogin.password#' 
					</cfquery> 
					<cfif loginQuery.Roles NEQ ""> 
						<cfloginuser name="#cflogin.name#" Password = "#cflogin.password#" 
							roles="#loginQuery.Roles#">
							<cflock timeout=20 scope="Session" type="Exclusive"> 
								<cfset Session.username = loginQuery.name> 
								<cfset Session.apiKey = loginQuery.parature_token> 
							</cflock>
					<cfelse> 
						<cfoutput> 
							<H2>Your login information is not valid.<br> 
							Please Try again</H2> 
						</cfoutput>     
						<cfinclude template="loginform.cfm"> 
						<cfabort> 
					</cfif> 
				</cfif>     
			</cfif> 
		</cflogin> 
	 <!---
		<cfif GetAuthUser() NEQ ""> 
			<cfoutput> 
				<form action="index.cfm" method="Post"> 
					<input type="submit" Name="Logout" value="Logout"> 
				</form> 
			</cfoutput> 
		</cfif> 
	 --->
	</cffunction> 
</cfcomponent>