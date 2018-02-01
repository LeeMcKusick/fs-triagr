(function() {

var app = angular.module('triagrApp', ['triagrTickets', 'angular-redactor', 'ui.bootstrap']);

app.controller('TriagrController', ['$scope','$http', function($scope, $http){
	
	var triagr = this;

	//Set up names and IDs for CSR accounts.
	triagr.csrs = [
		{ name: 'Joe Test 1', id: 22684 },
		{ name: 'Joe Test 2', id: 22466 },
	];

	
	//Set app defaults.
	triagr.tickets = [];
	triagr.updateLog = [];
	triagr.loading = 1;
	triagr.ticketsCount = 0;

	//Fetch select input options
	$http.get('getFieldOptions-Angular.cfm').success (function( data ) {
		triagr.team = data[0].Team;
		triagr.priority = data[0].Priority;
		triagr.productFamily = data[0]["Product Family"];
		triagr.initialPriority = data[0]["Priority (T)"];
	});

	
	/*
	* Updates account details
	*/
	triagr.updateAccount = function(t) {
		t.loadingUpdateAcc = 1;
		$http.get('updateAccountDetails.cfm?account='+t.account.id ).success( function(data) {
			console.log(data);
			t.account.url = data.url;
			t.account.keyword = data.keyword;
			t.account.server = data.server;
			t.loadingUpdateAcc = 0;
		});
	}

	triagr.pushUpdateLog = function(s) {
		var time = new Date();
		triagr.updateLog.unshift(time.getHours() + ":" + time.getMinutes() + ":" + time.getSeconds() + " " + s);
		if (triagr.updateLog.length > 20) {
			triagr.updateLog.pop();
		}
		$scope.$apply();
	}

	/*
	* Refreshes the ticket list. Can either pull from a 
	* list of the current user's tickets, or from a ticket view.
	*/
	triagr.refreshTickets = function() {
		triagr.tickets = [];
		triagr.loading = 1;
		if (myTickets) {
			pullURL = 'getTicketJSON.cfm?myTickets=true'+'&order='+order
		} else {
			pullURL = 'getTicketJSON.cfm?ticketViewID='+ticketViewID+'&ticketsToPull='+ticketsToPull+'&order='+order
		}
		$http.get(pullURL).success( function( data ) {
			triagr.lastPull = Date.now();
			angular.forEach(data, function(t, key) {
				//t.attachments = $.parseJSON( t.attachments );
				t.loadingHistory = 0;
				t.loadingUpdateAcc = 0;
				t.currentPage = 1;
				t.pageSize = 10;
				t.history = [];
				t.visible = 1;
				t.comment = '';
				t.dateCreated = new Date(t.dateCreated);
				t.dateUpdated = new Date(t.dateUpdated);
			 	t.elapsedTime = parseMinutes(workingMinutesBetweenDates(t.dateCreated, Date.now()));
			});
			triagr.tickets = data;
			triagr.ticketsCount = triagr.tickets.length;
			triagr.loading = 0;
		});
	}

	//Refresh tickets when app loads
	triagr.refreshTickets();

	/*
	* Function to remove ticket from view, then remove it
	* from the DOM
	*/
	triagr.removeTicket = function( id ){
		$('#'+id).slideUp( function(){
		var t = $.grep(triagr.tickets, function(obj) {
			return obj.num === id;
		});
		t[0].visible = 0;

		triagr.ticketsCount = triagr.ticketsCount - 1;
		$scope.$apply();
		});
	}

	/*
	* Resets a ticket's comment pane
	*/
	triagr.clearComment = function( id ){
		var t = $.grep(triagr.tickets, function(obj) {
			return obj.num === id;
		});
		t[0].comment = '';
		$scope.$apply();

	}

	/*
	* Updates the ticket's team setting in Parature.
	* Called when Team dropdown changes
	*/
	triagr.updateTeam = function (t) {
		t.teamLabel = jQuery.grep(triagr.team.options, function(obj) {
			return obj.optionID === t.team;
		})[0].optionLabel;

		fieldsToUpdate = [{field: 'team', fieldID: triagr.team.fieldID}];
		sendMessage('update', t, fieldsToUpdate);
	}
	
	/*
	* Updates the ticket's priority setting in Parature.
	* Called when Priority dropdown changes
	*/
	triagr.updatePriority = function (t) {
		t.priorityLabel = jQuery.grep(triagr.priority.options, function(obj) {
			return obj.optionID === t.priority;
		})[0].optionLabel;


		fieldsToUpdate = [{field: 'priority', fieldID: triagr.priority.fieldID}];

		//If it's in the New queue, also set the Priority (T) field.
		if (t.status == "Opened" || t.initialPriority == '') {
			t.initialPriorityLabel = t.priorityLabel;
			t.initialPriority = jQuery.grep(triagr.initialPriority.options, function(obj) {
				return obj.optionLabel === t.priorityLabel;
			})[0].optionID;
			fieldsToUpdate.push( {field: 'initialPriority', fieldID: triagr.initialPriority.fieldID} );
			console.log(t.initialPriority);
		}

		sendMessage('update', t, fieldsToUpdate);
	}

	/*
	* Updates the ticket's initial priority setting in Parature.
	* Called when Priority changes for the first time.
	*/
	triagr.updateInitialPriority = function(t) {
		if (t.priority > 0) {
			t.initialPriorityLabel = t.priorityLabel;
			t.initialPriority = jQuery.grep(triagr.initialPriority.options, function(obj) {
				return obj.optionLabel === t.priorityLabel;
			})[0].optionID;
			fieldsToUpdate = [{field: 'initialPriority', fieldID: triagr.initialPriority.fieldID}];
			//console.log(t.initialPriority);
			sendMessage('update', t, fieldsToUpdate);
		} else {
			displayMessage('Make sure you have a Priority set.', 'OOPS', 'warning');
		}
	}

	/*
	* Updates the ticket's product family setting in Parature.
	* Called when Product Family dropdown changes
	*/
	triagr.updateProductFamily = function (t) {
		t.productFamilyLabel = jQuery.grep(triagr.productFamily.options, function(obj) {
			return obj.optionID === t.productFamily;
		})[0].optionLabel;
		sendMessage('update', t, 'productFamily', triagr.productFamily.fieldID);
	}

	/*
	* Function to Triage ticket
	* Includes error checking for tickets marked with a low 
	* team priority and a high customer urgency.
	* 
	*/
	triagr.triage = function(t) {
		if (t.team > 0 && t.priority > 0 ) {
			if (t.urgencyLabel == 'High' && t.priorityLabel == '150') {
         var c = confirm('This is a "High" urgency ticket, and the priority is still set to 150.\n\nDo you still want to triage this ticket?');
				 if (c) {
					 $('html, body').animate({
					 				scrollTop: $("#"+t.num).offset().top - 70
					 			},
					  350, function() {
					 			});
					 			sendMessage('triage', t);
				 }

			} else {
				$('html, body').animate({
							 scrollTop: $("#"+t.num).offset().top - 70
						 },
				 350, function() {
				 });
						 sendMessage('triage', t);
			}

		} else {
			displayMessage('Make sure you have Team and Priority set.', 'OOPS', 'warning');
		}
	}
	
	/*
	* Posts a private comment
	*/
	triagr.postInternalComment = function(t) {
		if ( t.comment.length ) {
			sendMessage('internalComment', t);
		} else {
			displayMessage('Please enter a comment.', 'OOPS', 'warning');
		}
	}
	
	/*
	* Posts a customer-facing comment to the ticket
	*/
	triagr.postComment = function(t) {
		if ( t.comment.length ) {
			var c = confirm('Are you sure you want to add a public comment for ticket ' + t.num + '?');
			if (c) { sendMessage('comment', t); }
		} else {
			displayMessage('Please enter a comment.', 'OOPS', 'warning');
		}
	}


		triagr.triageNMI = function(t) {
			sendMessage('triageNMI', t);
		}
	/*
	* Send ticket to SS team.
	*/
	triagr.sendToSS = function(t) {
		sendMessage('schoolsuite',t);
	}

	/*
	* Assign a ticket directly to a CSR
	* Checks to make sure Team and Priority are set first.
	*/
	triagr.assignTo = function (t, csr, name) {
		if (t.team > 0 && t.priority > 0 ) {
			var c = confirm('Are you sure you want to send ' + t.num + ' to ' + name + '?');
			if (c) {
				sendMessage('assignTo', t, [], csr, name);
			}
		} else {
			displayMessage('Make sure you have Team and Priority set.', 'OOPS', 'warning');
		}
	}

	/*
	* Send to Sales team
	*/
	triagr.sendToSales = function(t) {
		if (t.team > 0 && t.priority > 0 ) {
			sendMessage('sales',t);
		} else {
			displayMessage('Make sure you have Team and Priority set.', 'OOPS', 'warning');
		}
	}

	/*
	* Solves a ticket with a customer-facing comment.
	*/
	triagr.solveTicket = function(t) {
		if ( t.comment.length && t.team > 0 && t.priority > 0 ) {
			var c = confirm('Are you sure you want to solve ticket ' + t.num + '?');
			if (c) { sendMessage('solve', t); }
		} else {
			displayMessage('Make sure you have Team, Priority, and a comment set.', 'OOPS', 'warning');
		}
	}

	/*
	* Solves a ticket with a private comment.
	*/
	triagr.hiddenSolveTicket = function(t) {
		if ( t.team > 0 && t.priority > 0 ) {
			var c = confirm('Are you sure you want to hidden solve ticket ' + t.num + '?');
			if (c) { sendMessage('hiddenSolve', t); }
		} else {
			displayMessage('Make sure you have Team and Priority set.', 'OOPS', 'warning');
		}
	}
	
	/*
	* Deletes a ticket from the system. Useful for spam tickets, duplicates, etc.
	*/
	triagr.trashTicket = function(t) {
		var c = confirm('Are you sure you want to trash ticket ' + t.num + '?');
		if (c) {
			var c2 = confirm('Are you REALLY sure you want to throw ticket ' + t.num + ' in the TRASH?');
			if (c2) {
				sendMessage('trash', t);
			}
		}
	}

	/*
	* Hides a ticket until next refresh.
	*/
	triagr.hideTicket = function(t) {
		removeTicket(t.num);
	}

	/*
	* Pulls an activity log from the ticket.
	*/
	triagr.viewHistory = function (t) {
		t.loadingHistory = 1;
		$http.get('getTicketActionsJSON.cfm?ticket='+t.num).success (function( data ) {
			console.log( data );
			//t.loadingHistory = 0;
			t.history = data;
		});
	}
}]);

/*
* Angular filter to enable pagination
*/
app.filter('startFrom', function() {
return function(input, start) {
	start = +start; //parse to int
	return input.slice(start);
}
});


})();


// Simple function that accepts two parameters and calculates the number of hours worked within that range
function workingMinutesBetweenDates(startDate, endDate) {
    // Store minutes worked
    var minutesWorked = 0;

    // Validate input
    if (endDate < startDate) { return 0; }

    // Loop from your Start to End dates (by hour)
    var current = startDate;

    // Define work range
    var workHoursStart = 8;
    var workHoursEnd = 17;
    var includeWeekends = false;

    // Loop while currentDate is less than end Date (by minutes)
    while(current <= endDate){
        // Is the current time within a work day (and if it occurs on a weekend or not)
        if(current.getHours() >= workHoursStart && current.getHours() <= workHoursEnd && (includeWeekends ? current.getDay() !== 0 && current.getDay() !== 6 : true)){
              minutesWorked++;
        }

        // Increment current time
        current.setTime(current.getTime() + 1000 * 60);
    }

    // Return the number of hours
    return minutesWorked;
}

//Parses minutes into a readable date string.
function parseMinutes( mins ) {
	var days = Math.floor( mins / 60 / 24 );
	mins = mins - (days * 60 * 24);
	var hours = Math.floor( mins / 60 );
	var minutes = mins - (hours*60);

	var dateString = days;
	dateString += (days == 1) ? " day, ":" days, ";
	dateString += hours;
	dateString += (hours == 1) ? " hour, ":" hours, ";
	dateString += minutes;
	dateString += (minutes == 1) ? " minute":" minutes";
	console.log(dateString);
	return dateString;
}
