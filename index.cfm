<cfwebsocket name="triagrWebsocket" onMessage="messageHandler" onError="errorHandler" onOpen="openHandler" subscribeTo="paratureTickets" />

<!DOCTYPE html>
<html ng-app="triagrApp">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

	<title>Triagr</title>

	<!--FONTS-->
	<link href='http://fonts.googleapis.com/css?family=Bree+Serif|Roboto:400,900,500,300,700,400italic,100' rel='stylesheet' type='text/css'>

	<!-- JQUERY -->
	<script src="//code.jquery.com/jquery-1.11.2.min.js"></script>
	<script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>


	<!-- ANGULAR.JS -->
	<script src="//ajax.googleapis.com/ajax/libs/angularjs/1.4.3/angular.min.js"></script>

	<!-- BOOTSTRAP -->
	<!-- Latest compiled and minified Bootstrap JavaScript -->
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
	<!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
	<!-- Bootstrap theme -->
	<link rel="stylesheet" href="css/bootstrap/cosmo.css">

	<!-- JQUERY PLUGINS -->
	<script src="//cdnjs.cloudflare.com/ajax/libs/chosen/1.0/chosen.jquery.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/chosen/1.0/chosen.proto.min.js"></script>
	<script src="js/redactor/redactor.js"></script>

	<script src="js/jquery.highlight-5.js"></script>
	<script src="js/bootstrap-notify.js"></script>

	<!-- <script src="js/redactor/redactor_codeMirror.min.js"></script> -->
	<!-- include the css and sprite -->
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/chosen/1.1.0/chosen.min.css">
	<link rel="image_src" href="https://cdnjs.cloudflare.com/ajax/libs/chosen/1.1.0/chosen-sprite.png">
	<link rel="stylesheet" type="text/css" href="js/redactor/redactor.css">
	<link rel="stylesheet" type="text/css" href="css/animate.css">
	<link rel="stylesheet" href="http://css-spinners.com/css/spinner/spinner.css" type="text/css">

	<style>
		.highlight { padding: 1px 3px; }
		.bg-info, .bg-warning, .bg-success, .bg-danger { color: white; }
		.redactor-editor { background-color: white; }
		#loadingCat { border-radius: 150px; }
		main { padding-top: 75px; }
		#refreshBtn { position: absolute; top: 0; right: 25px; }
		.accountURL { word-wrap: break-word; }
    .ticketLink { color: white; text-decoration: underline;}
    .ticketLink:hover { color: white; }
    .update-log .ticketLink { color: #9954bb;}
    .update-log .ticketLink:hover { color: #9954bb; }
    .update-log .panel-body { border-bottom: 1px solid #ddd; }
    .labels span a { color: white; }
    .hideMe { display: none !important; }
    #main { width: 100%; }
	</style>



	<cfinclude template="trello.cfm">
	<cfinclude template="setDatasource.cfm">
	<script>
		var sandbox = Boolean(<cfoutput>#useSandbox#</cfoutput>);
		var isModuleADropdown = Boolean(<cfoutput>#isModuleADropdown#</cfoutput>);
		var paratureTimeout = parseInt(<cfoutput>#paratureTimeout#</cfoutput>);
		var ticketViewID = parseInt(<cfoutput>#ticketViewID#</cfoutput>);
		var ticketViewIDSandbox = parseInt(<cfoutput>#ticketViewIDSandbox#</cfoutput>);
		var triageActionID = parseInt(<cfoutput>#triageActionID#</cfoutput>);
		var triageActionIDSandbox = parseInt(<cfoutput>#triageActionIDSandbox#</cfoutput>);
		var triageQueueID = parseInt(<cfoutput>#triageQueueID#</cfoutput>);
		var triageQueueIDSandbox = parseInt(<cfoutput>#triageQueueIDSandbox#</cfoutput>);
		var salesActionID = parseInt(<cfoutput>#salesActionID#</cfoutput>);
		var salesQueueID = parseInt(<cfoutput>#salesQueueID#</cfoutput>);
		var ssActionID = parseInt(<cfoutput>#ssActionID#</cfoutput>);
		var ssQueueID = parseInt(<cfoutput>#ssQueueID#</cfoutput>);
		var normalThreshold = parseInt(<cfoutput>#normalThreshold#</cfoutput>);
		var highThreshold = parseInt(<cfoutput>#highThreshold#</cfoutput>);
		var criticalThreshold = parseInt(<cfoutput>#criticalThreshold#</cfoutput>);
		var ticketsToPull = parseInt(<cfoutput>#ticketsToPull#</cfoutput>);
		var datasource = "<cfoutput>#dataSource#</cfoutput>";
		var sessionUsername = "<cfoutput>#session.username#</cfoutput>";
		var apiKey = "<cfoutput>#session.apiKey#</cfoutput>";
		var sessionUsername = "<cfoutput>#session.username#</cfoutput>";
		var apiKey = "<cfoutput>#session.apiKey#</cfoutput>";
		var order = "";
		var myTickets = false;
		var noTriage = false;
    var hideActionsBar = false;
    <cfset hideActionsBar = false>

		<cfif IsDefined('URL.ticketViewID')>
			ticketViewID = <cfoutput>#URL.ticketViewID#</cfoutput>;
		</cfif>
		<cfif IsDefined('URL.ticketsToPull')>
			ticketsToPull = <cfoutput>#URL.ticketsToPull#</cfoutput>;
		</cfif>
		<cfif IsDefined('URL.order')>
			order = "<cfoutput>#URL.order#</cfoutput>";
		</cfif>
		<cfif IsDefined('URL.myTickets') and URL.myTickets>
			myTickets = true;
		</cfif>
		<cfif IsDefined('URL.noTriage') and URL.noTriage>
			noTriage = true;
		</cfif>
		<cfif IsDefined('URL.hideActionsBar')>
      <cfset hideActionsBar = true>
			hideActionsBar = true;
		</cfif>

	</script>
	<!-- ANGULAR STUFF -->
	<script src="js/redactor/angular-redactor.js"></script>
	<script src="js/ui-bootstrap.js"></script>
	<script src="js/scripts-angular2.js"></script>
	<script src="js/dirPagination.js"></script>

	<script src="js/tickets.js"></script>
	<script src="js/app.js"></script>
</head>

<body ng-controller="TriagrController as triagr">
	<nav class="navbar navbar-default navbar-fixed-top">
	  <div class="container-fluid">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="index.cfm">Triagr <span class="badge"> {{triagr.ticketsCount}}</span></a>

		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
			<ul class="nav navbar-nav">
			  <li><a href="index.cfm?ticketViewID=12175&ticketsToPull=50&order=Date_Created_asc_">No Response</a></li>
				<li class="dropdown">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Views <span class="caret"></span></a>
					<ul class="dropdown-menu">
            <li><a href="index.cfm?ticketViewID=12102&ticketsToPull=20&order=Date_Created_asc_" title="Product Family = Finalsite, Updated after 6/30/15, Summary is not null, Team is null. Adjust URL parameter to pull more or fewer tickets.">No Team (lmt. 20)</a></li>
    				<li><a href="index.cfm?ticketViewID=12096&ticketsToPull=20&order=Date_Created_asc_" title="Product Family = Finalsite, Updated after 6/30/15, Summary is not null, Priority is null. Adjust URL parameter to pull more or fewer tickets.">No Priority (lmt. 20)</a></li>
						<li><a href="index.cfm?ticketViewID=12061&ticketsToPull=20&order=Date_Created_asc_" target="_blank">Triaged - Date Created - Oldest 20</a></li>
						<li><a href="index.cfm?ticketViewID=12061&ticketsToPull=20&order=Date_Updated_asc_" target="_blank">Triaged - Date Updated - Oldest 20</a></li>
						<li><a href="index.cfm?ticketViewID=12197&ticketsToPull=50&order=Date_Updated_asc_" target="_blank">Triaged Design - Date Updated - Oldest 50</a></li>
            <li><a href="index.cfm?myTickets=true">My Tickets</a></li>
					</ul>
				</li>
        <li><a href="http://cfaux01/devtools/" target="_blank">DevTools</a></li>
        <li><a href="https://staff.finalsite.com/page.cfm?p=815" target="_blank">Site List</a></li>
		<li><a>|</a></li>
		<li><a href="#">Last Updated: {{triagr.lastPull | date:'h:mm a'}}</a></li>
		</ul>
	  </div>
	</nav>



	<main class="container" id="main">
    <div class="row">
    		<div id="loading" class="text-center" ng-show="triagr.loading">
    			<img src="images/calmingcatsmall-cropped.gif" id="loadingCat" />
    		</div>
    		<div class="text-center" ng-show="!triagr.loading && !triagr.ticketsCount">
    			<h3>No new tickets.</h3>
    			<h3>Good work.</h3>
          <p></p>
    		</div>

    		<div class="col-lg-6 col-md-12 col-sm-12" ng-repeat="ticket in triagr.tickets">
    			<section class="panel panel-default" id="{{ticket.num}}" ng-show="ticket.visible">
    				<div class="panel-heading">
    					<h3>
    					<span class="labels">
    						<span class="label label-danger" ng-show="ticket.status.indexOf('Closed') != -1">CLOSED</span>
                <span class="label label-danger" ng-show="ticket.urgencyLabel.indexOf('Critical') != -1 || ticket.queue == 'Critical'">Critical</span>
    						<span class="label label-warning" ng-show="ticket.urgencyLabel.indexOf('High') != -1">High Urgency</span>
    						<span class="label label-primary" ng-show="ticket.status.indexOf('Triaged') != -1">Triaged</span>
    						<span class="label label-primary" ng-show="ticket.status.indexOf('Sprinted') != -1">Sprinted</span>
    						<span class="label label-success" ng-show="ticket.account.slaName.indexOf('Premium') != -1">Premium SLA</span>
    						<span class="label label-info" ng-show="ticket.status.length && ticket.status.indexOf('Recycled') != -1">Recycled</span>
    						<span class="label label-info" ng-show="ticket.vacation">Vacation</span>
    						<span class="label label-info" ng-show="ticket.queue.length && ticket.status.indexOf('Requested Update') != -1">Requested Update</span>
                <span class="label label-primary" ng-show="ticket.account.composer" title="This is a Composer site.">C</span>
                <span class="label label-primary" ng-show="ticket.account.composer_redesign"><cfif hideActionsBar><a href="http://{{ticket.account.keyword}}.redesign.finalsite.com/admin/fs" target="_blank"></cfif>C. Redesign<cfif hideActionsBar></a></cfif></span>
                <span class="label label-primary" ng-show="ticket.account.theme">Theme</span>
    						<span class="label label-primary" ng-show="ticket.ticketTypeLabel.indexOf('Upload') != -1">Data Upload</span>
    						<span class="label label-primary" ng-show="ticket.moduleLabel.indexOf('Integration') != -1">Integration</span>
    						<span class="label label-primary" ng-show="ticket.enteredBy.indexOf('API User') != -1">Phone Call</span>
    						<span class="label label-primary" ng-show="ticket.busyNotification">BSN</span>
    						<span class="label label-warning" ng-show="ticket.ticketTypeLabel.indexOf('Callback') != -1">Callback Requested</span>
    						<span class="label label-primary" ng-show="ticket.details.indexOf('finalsiteapply.com') != -1 || ticket.moduleLabel.indexOf('Finalsite Apply') != -1">Apply</span>
    						<span class="label label-danger" ng-show="ticket.summary.toLowerCase().indexOf('out of office') != -1 ||
                                                          ticket.summary.toLowerCase().indexOf('out of the office') != -1 ||
                                                          ticket.details.toLowerCase().indexOf('out of office') != -1 ||
                                                          ticket.details.toLowerCase().indexOf('out of the office') != -1 ||
                                                          ticket.contact.name.indexOf('postmaster') != -1">TRASH</span>
    						<span class="label label-danger" ng-show="ticket.productFamilyLabel.indexOf('SchoolSuite') != -1 || ticket.account.slaName.indexOf('SS') != -1">SchoolSuite</span>
    						<span class="label label-success" ng-show="ticket.status.indexOf('Solved') != -1">Solved</span>
    						&nbsp;

    					</span>

    				</div>
    				<div class="panel-body">
    					<div class="col-md-3">
    						<ul class="list-group">
    							<li class="list-group-item"><span class="glyphicon glyphicon-time" aria-hidden="true"></span>
    								 <span popover="Updated: {{ticket.dateUpdated | date:'h:mm a | EEE, MMM d, yyyy'}}" popover-trigger="mouseenter" ><b>{{ticket.dateCreated | date:'h:mm a'}}</b> | {{ticket.dateCreated | date:'EEE, MMM d, yyyy'}}</span>
    							</li>
                  <li class="list-group-item" ng-hide="ticket.initialResponseUser.length" style="background-color: orange;">
                    <span class="glyphicon glyphicon-time" title="Initial Response Timer" aria-hidden="true"></span> {{ticket.elapsedTime}}
                  </li>
    							<li class="list-group-item <cfif hideActionsBar>hideMe</cfif>"><span class="glyphicon glyphicon-tag" aria-hidden="true"></span>
    								<a class="lead" href="{{ticket.url}}" title="Ticket Number" target="_blank">  {{ticket.num}}</a>
    							</li>
    							<li class="list-group-item">
                    <span class="glyphicon glyphicon-folder-open" title="Queue" aria-hidden="true"></span> &nbsp;{{ticket.queue}}</a>
    							</li>
    							<li class="list-group-item" ng-show="ticket.enteredBy.length && ticket.enteredBy.indexOf('API User') == -1">
    								<span class="glyphicon glyphicon-user" aria-hidden="true"></span> Entered By: {{ticket.enteredBy}}
    							</li>
                  <li class="list-group-item" ng-show="ticket.ticketTypeLabel.length"><span class="glyphicon glyphicon-cog" aria-hidden="true"></span>  {{ticket.ticketTypeLabel}} </li>
    						  <li class="list-group-item" ng-show="ticket.moduleLabel.length"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span>  {{ticket.moduleLabel}} </li>
    								 <li class="list-group-item">
    									<span class="label label-default">Team</span>
    									<select chosen ng-model="ticket.team" ng-options="team.optionID as team.optionLabel for team in triagr.team.options | orderBy:'optionLabel'" ng-change="triagr.updateTeam(ticket)">
    									</select>
    								</li>
    								<li class="list-group-item  <cfif hideActionsBar>hideMe</cfif>">
    									<span class="label label-default">Priority <span ng-show="ticket.initialPriority != ''"> - (Initial: {{ticket.initialPriorityLabel}})</span><span ng-show="ticket.initialPriority == ''" ng-click="triagr.updateInitialPriority(ticket)"> - SET INITIAL PRIORITY</span></span>
    									<select chosen ng-model="ticket.priority" ng-options="priority.optionID as priority.optionLabel for priority in triagr.priority.options | orderBy:'optionLabel':true"  ng-change="triagr.updatePriority(ticket)">
    									</select>
                      <button class="btn btn-primary btn-xs" ng-show="false" ng-click="triagr.updateInitialPriority(ticket)">Set Default</button>
    								</li>
                </ul>
              </div>
              <div class="col-md-3">
                <ul class="list-group">
    							<li class="list-group-item" ng-show="ticket.contact.name.length">
    								<span class="glyphicon glyphicon-user" title="Contact" aria-hidden="true"></span>  {{ticket.contact.name}}
    							</li>
    							<li class="list-group-item" ng-show="ticket.account.name.length">
    								<span class="glyphicon glyphicon-education" aria-hidden="true"></span>  {{ticket.account.name}}
    							</li>
    							<li class="list-group-item" ng-show="ticket.account.keyword.length || ticket.account.server.length">
    								<span class="glyphicon glyphicon-hdd" aria-hidden="true"></span>  <span ng-show="ticket.account.keyword.length">{{ticket.account.keyword}}</span> <span ng-show="ticket.account.server.length">({{ticket.account.server}})</span>
    								<div class="spinner-loader" ng-show="ticket.loadingUpdateAcc">
    									Loading…
    								</div>
    							</li>
    						  <li class="list-group-item <cfif hideActionsBar>hideMe</cfif>" ng-show="ticket.account.url.length"><span class="glyphicon glyphicon-link" aria-hidden="true"></span> <a class="accountURL" href="{{ticket.account.url}}" target="_blank">{{ticket.account.url}}</a> | <a href="{{ticket.account.url+ '/admin/fs'}}" target="_blank">admin</a></li>
    						  <li class="list-group-item" ng-hide="ticket.account.url.length  || ticket.account.name.indexOf('KB Only') != -1 || ticket.contact.name.indexOf('sitelaunch') != -1"><span class="glyphicon glyphicon-link" aria-hidden="true"></span>
    						     <button class="btn btn-primary btn-sm <cfif hideActionsBar>hideMe</cfif>" ng-click="triagr.updateAccount(ticket)" ng-hide="ticket.loadingUpdateAcc">Update Account</button><div class="spinner-loader" ng-show="ticket.loadingUpdateAcc">Loading…</div>
    						  </li>

    						  <li class="list-group-item" ng-show="ticket.account.slaName.length"><span class="glyphicon glyphicon-piggy-bank" aria-hidden="true"></span>  {{ticket.account.slaName}} </li>
    						</ul>

    					</div>
    					<div class="col-md-6">
    						<h4 ng-bind-html="ticket.summary | sanitizeLinks"></h4>
    						<p ng-show="ticket.bugNumber.length"><strong>Dev Number:</strong> <span ng-bind-html="ticket.bugNumber | sanitizeLinks"></span></p>
    						<p ng-show="ticket.relevanturl.length" class="<cfif hideActionsBar>hideMe</cfif>"><strong>Relevant URL:</strong> <span ng-bind-html="ticket.relevanturl | sanitizeLinks"></span></p>
    						<div ng-bind-html="ticket.details<cfif hideActionsBar> | sanitizeLinks</cfif> | highlight:['urgent', 'hurry', 'today', 'tomorrow', 'soon', 'this week', 'homepage', 'home page', 'noon', 'right now', 'hour', ':00', ':30', 'morning', 'help', 'head of school', 'asap', 'critical', 'in the next', 'next day', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']"></div>

    						<div ng-repeat="attachment in ticket.attachments" class="<cfif hideActionsBar>hideMe</cfif>">
    							<p><b>Attachment: </b><a class="attachment" href="{{attachment.url}}" target="_blank">{{attachment.name}}</a></p>
    						</div>
    					</div>
    				</div>
    				<div class="panel-body  <cfif hideActionsBar>hideMe</cfif>">
    					<div class="text-center" ng-show="!ticket.history.length">
    						<a ng-click="triagr.viewHistory(ticket)" ng-show="!ticket.loadingHistory">View History</a>
    						<div class="spinner-loader" ng-show="ticket.loadingHistory">
    							Loading…
    						</div>
    					</div>
    					<div ng-show="ticket.history.length">
    						<div class="row">
    							<div class="col-md-2"><b>Action Date</b></div>
    							<div class="col-md-1"><b>Action Performer</b></div>
    							<div class="col-md-2"><b>Action Type</b></div>
    							<div class="col-md-7"><b>Comments</b></div>
    						</div>
    						<div ng-repeat="action in ticket.history | startFrom:(ticket.currentPage-1)*ticket.pageSize | limitTo:ticket.pageSize">
    							<div class="row">
    								<div class="col-md-2" ng-class="{'bg-success': action.showToCust}">{{action.date | date:'MMM d, yyyy - h:mm a'}}</div>
    								<div class="col-md-1">{{action.performer.name}}</div>
    								<div class="col-md-2">{{action.type}}</div>
    								<div class="col-md-7" ng-bind-html="action.comments | sanitizeLinks"></div>
    							</div>
    						</div>
    						<pagination total-items="ticket.history.length" ng-model="ticket.currentPage"></pagination>
    					</div>
    				</div>
    				<div class="panel-footer <cfif hideActionsBar>hideMe</cfif>">
    					<div class="row">

    						<div class="col-md-10">
    							<textarea rows="5" ng-model="ticket.comment" redactor>
    							</textarea>
    						</div>
    						<div class="col-md-2">
    							<div class="btn-group-vertical pull-right" role="group" aria-label="...">
    								<button type="button" class="btn btn-success" ng-show="ticket.queue.length && (ticket.queue.indexOf('Opened') != -1 || ticket.queue.indexOf('Requested Update') != -1)" ng-click="triagr.triage(ticket)">TRIAGE</button>
    								<button type="button" class="btn btn-warning" ng-show="ticket.queue.length && ticket.queue.indexOf('Opened') == -1 && ticket.queue.indexOf('Requested') == -1" ng-click="triagr.hideTicket(ticket)">Hide Ticket</button>
    								<button type="button" class="btn btn-primary" ng-click="triagr.postComment(ticket)">Comment to Client</button>

    								<div class="btn-group dropup" role="group">
    									<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" >
    										Assign To<span class="caret"></span>
    									</button>
    									<ul class="dropdown-menu">

    										<li ng-repeat="csr in triagr.csrs">
    											<a ng-click="triagr.assignTo(ticket, csr.id, csr.name)">{{csr.name}}</a>
    										</li>

    										<li><a ng-click="triagr.sendToSales(ticket)">TEAM: Client Success</a></li>
    										<li><a ng-click="triagr.sendToSS(ticket)">TEAM: Schoolsuite</a></li>
    									</ul>
    								</div>

    								<div class="btn-group dropup" role="group">
    									<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" >
    										Other Actions <span class="caret"></span>
    									</button>
    									<ul class="dropdown-menu">
                        <li><a ng-click="triagr.hideTicket(ticket)">Hide this Ticket Until Next Refresh</a></li>
                        <li><a ng-click="ticket.comment = ''">Reset Comment Box</a></li>

    										<li><a href="http://staff.finalsite.com/custom/parajira/?task_id=1&ticket_id={{ticket.num}}" target="_blank">Log a Bug</a></li>
    										<li><a href="http://staff.finalsite.com/custom/parajira/?task_id=4&ticket_id={{ticket.num}}" target="_blank">Log an ERQ</a></li>
    										<li><a ng-click="triagr.postInternalComment(ticket)">Post an Internal Comment</a></li>
    										<li><a ng-click="triagr.solveTicket(ticket)">Solve the Ticket</a></li>
    										<li><a ng-click="triagr.hiddenSolveTicket(ticket)">Hidden Solve this Ticket</a></li>
    										<li><a ng-click="triagr.triageNMI(ticket)">Triage (Need More Info) this Ticket</a></li>

    										<li><a ng-click="triagr.trashTicket(ticket)">Trash this Ticket</a></li>
    									</ul>
    								</div>
    							</div>
    						</div>
    					</div>
    				</div>
    			</section>
    		</div>
        <hr ng-hide="triagr.loading || triagr.ticketsCount == 0" />

    </div>
    <section ng-hide="triagr.loading || triagr.ticketsCount == 0" class="update-log panel panel-default">
      <div class="panel-heading">
        <h3>Update Log</h3>
      </div>
      <div class="panel-body" ng-repeat="log in triagr.updateLog">
        <p ng-bind-html="log | sanitizeLinks"></p>
      </div>
    </section>
	</main>




</body>
</html>
