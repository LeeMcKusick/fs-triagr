$( function() {
	$('data-toggle=offcanvas]').click(function() {
		$('.row-offcanvas').toggleClass('active');
	});
});

function removeTicket(id) {
	angular.element( $('body') ).scope().triagr.removeTicket( id );
}
function clearTicket(id) {
	angular.element( $('body') ).scope().triagr.clearComment( id );
}

function sendMessage(action, t, fieldsToUpdate, csr, csrName) {
	var message = {};
	console.log(t);
	message.action = action;
	message.ticketNum = t.num;
	message.dataSource = datasource;
	message.sandbox = sandbox;
	message.contactID = t.contact.id;
	message.user = sessionUsername;
	message.showToCustomer = 'false';
	message.apiKey = apiKey;
	message.updateInitial = false;

	var comm = t.comment;
	//$('#' + tn + 'commentText').val().replace(/\n/g, '<br/>');

	if (action == "update") {
		message.fieldData = [];

		$.each(fieldsToUpdate, function(i, obj) {
			f = {};
			f.field = obj.field;
			f.fieldID = obj.fieldID;
			f.newValue = t[obj.field];
			f.newLabel = t[obj.field+'Label'];
			message.fieldData.push(f);
		});

/*
		if (field == 'team' ) {
			message.newValue = t.team;
			message.newLabel = t.teamLabel;
		} else if (field == 'priority') {
			message.newValue = t.priority;
			message.newLabel = t.priorityLabel;
		} else if (field == 'initialPriority') {
			message.newValue = t.initialPriority;
			message.newLabel = t.priorityLabel;
		} else if (field == 'productFamily') {
			message.newValue = t.productFamily;
			message.newLabel = t.productFamilyLabel;
		}*/

	} else if (action == "triage") {
		if (sandbox) {
			taid = triageActionIDSandbox;
			tqid = triageQueueIDSandbox;
		} else {
			taid = triageActionID;
			tqid = triageQueueID;
		}
		message.actionID = taid;
		message.queueID = tqid;
		if ( t.comment != '') {
			message.comment = formatXml('<div style="font-size: 16px; font-weight: bold;">'+comm+'</div>');
		} else {
			message.comment = "Triaged by " + message.user;
		}
	} else if (action == 'triageNMI') {
		if (sandbox) {
			tqid = triageQueueIDSandbox;
		} else {
			tqid = triageQueueID;
		}
		message.actionID = 43106;
		message.queueID = tqid;
		if ( t.comment != '') {
			message.comment = formatXml('<div style="font-size: 16px; font-weight: bold;">'+comm+'</div>');
		} else {
			message.comment = "Triaged by " + message.user;
		}
	} else if (action == "sales") {
		message.actionID = 43012;
		message.queueID = 6445;
		if ( comm != '') {
			message.comment = formatXml('<div style="font-size: 16px; font-weight: bold;">'+comm+'</div>');
		} else {
			message.comment = "Assigned to Client Success by " + message.user;
		}
	} else if (action == "schoolsuite") {
		message.actionID = ssActionID;
		message.queueID = ssQueueID;
		if ( comm != '') {
			message.comment = formatXml('<div style="font-size: 16px; font-weight: bold;">'+comm+'</div>');
		} else {
			message.comment = "Assigned to the Schoolsuite queue by " + message.user;
		}
	} else if (action == "comment") {
		message.actionID = 42978;
		message.comment = formatXml(comm);
		message.showToCustomer = 'true';
	} else if (action == "internalComment") {
		message.actionID = 42789;
		message.comment = formatXml(comm);
		message.showToCustomer = 'false';
	} else if (action == "solve") {
		message.actionID = 42992;
		message.comment = formatXml(comm);
		message.showToCustomer = 'true';
	} else if (action == "hiddenSolve") {
		message.action = 'solve';
		message.actionID = 42992;
		message.comment = formatXml(comm);
		message.showToCustomer = 'false';
	} else if (action == "trash") {

	} else if (action == "assignTo") {
		message.actionID = 42988;
		message.csr = csr;
		message.comment = formatXml(comm);
		message.csrName = csrName;
	}

	//console.log( message );
	if ( triagrWebsocket.isConnectionOpen() ) {
		triagrWebsocket.publish("paratureTickets", JSON.stringify(message));
	} else {
		console.log('ERROR');
		displayMessage('Unknown Error, please reload', 'ERROR', 'danger');
		angular.element( $('body') ).scope().triagr.tickets = [];
	}
}

function capString ( str ) {
	return str.charAt(0).toUpperCase() + str.slice(1);
}

function messageHandler(m) {
	var data = m.data;
	if (data) {
		console.log(data);

		if (typeof data.action !== 'undefined') {
			if (data.success){
				if (data.action == 'triage') {
					displayMessage('Ticket <a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a> was triaged by ' + data.user +'.', 'TRIAGED');
					removeTicket( data.ticketNum );
				} else if (data.action == 'update') {
					//var fnCap = data.field.charAt(0).toUpperCase() + data.field.substring(1);
					//console.log(data.newValue);
					//$('#' + data.ticketNum + data.field).val(data.newValue).trigger("change");

					//$('#' + data.ticketNum + data.field + ' select').val(data.newValue);
					//displayMessage( fnCap +' on ticket ' + data.ticketNum + ' was updated to ' + data.newLabel + ' by ' + data.user + '.', 'UPDATED');
					fieldText = '';
					$.each( data.fieldData, function(i, field) {
						if( i == 0) {
							fieldText = capString(field.field + ' (' + field.newLabel + ')');
						} else {
							fieldText = fieldText + ', ' + capString(field.field);
						}
					});
					displayMessage( fieldText + ' on ticket <a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a>  updated by ' + data.user + '.', 'UPDATED');
				} else if (data.action == 'triageNMI'){
					displayMessage('Ticket <a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a> was triaged as an NMI by ' + data.user + '.', 'NMI')
					removeTicket( data.ticketNum );
				} else if (data.action == 'sales') {
					displayMessage('Ticket ' + data.ticketNum + ' was sent to Sales by ' + data.user +'.', 'SALES', 'info');
					removeTicket( data.ticketNum );
				} else if (data.action == 'schoolsuite') {
					displayMessage('Ticket <a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a> was sent to the Schoolsuite queue by ' + data.user +'.', 'SCHOOLSUITE', 'info');
					removeTicket( data.ticketNum );
				} else if (data.action == 'comment') {
					displayMessage(data.user + ' posted a public comment to ticket <a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a>.', 'COMMENT', 'success');
					clearTicket(data.ticketNum);
				} else if (data.action == 'internalComment') {
					displayMessage(data.user + ' posted an internal comment to ticket <a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a>.', 'COMMENT', 'info');
					clearTicket( data.ticketNum );
				} else if (data.action == 'solve') {
					displayMessage( '<a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a> was solved by ' + data.user +'.', 'SOLVED', 'success');
					removeTicket( data.ticketNum );
				} else if (data.action == 'trash') {
					displayMessage( '<a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a> was trashed by ' + data.user +'.', 'TRASHED', 'warning');
					removeTicket( data.ticketNum );
				} else if (data.action == 'assignTo') {
					displayMessage( '<a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a> was assigned to ' + data.csrName + ' by ' + data.user +'.', 'ASSIGNED', 'success');
					removeTicket( data.ticketNum );
				}
			} else {

			   	displayMessage( data.user + ' encountered an error on Ticket <a target="_blank" class="ticketLink" href="https://supportcenteronline.com/link/desk/3870/4205/Ticket/' + data.ticketNum + '">'+data.ticketNum+'</a>. ' + data.error, 'ERROR', 'danger');
					//$('#' + data.ticketNum + data.field).val().trigger("chosen:updated");
					//$('#' + data.ticketNum + data.field).prepend( $('<option>', { value: '', text: '---' }) ).trigger("chosen:updated");
					//$('#' + data.ticketNum + data.field).val('').trigger("chosen:updated");


			}
		}
	}
}

function openHandler(message) { console.log("Opening channel..."); }

function errorHandler(error) {
	console.log("ERROR");
	displayMessage('Unknown Error, please reload', 'ERROR', 'danger');
	angular.element( $('body') ).scope().triagr.tickets = [];

	/*$('#errorMsgText').text('Error: Connection to Triagr lost. Please reload the page.');
	$('#errorMsg').show();
	$('#content').hide();
	console.log(error); */
}

function displayMessage (message, header, type) {
	$.notify({
		title: '<strong>'+ header +'</strong>',
		message: message
	},{
		type: type,
		delay: 2700
	});


	//notifyMe(header, message);
	console.log('test');
	angular.element( $('body') ).scope().triagr.pushUpdateLog(header + ": " + message);
}

function formatXml( string ) {
	var entityMap = {
		"&": "&amp;",
		"<": "&lt;",
		">": "&gt;",
		'"': '&quot;',
		"'": '&#39;',
		"/": '&#x2F;'
	  };

    return String(string).replace(/[&<>\/]/g, function (s) {
      return entityMap[s];
    });
 }


 function notifyMe(header, message) {
	 var options = {
		 body: message
	 };
	 // Let's check if the browser supports notifications
   if (!("Notification" in window)) {
     console.log("This browser does not support desktop notification");
   }

   // Let's check whether notification permissions have already been granted
   else if (Notification.permission === "granted") {
     // If it's okay let's create a notification
		 var n = new Notification(header, options);
		 setTimeout(n.close.bind(n), 4000);
   }

   // Otherwise, we need to ask the user for permission
   else if (Notification.permission !== 'denied') {
     Notification.requestPermission(function (permission) {
       // If the user accepts, let's create a notification
       if (permission === "granted") {
         var n = new Notification(header, options);
				 setTimeout(n.close.bind(n), 3000);
       }
     });
   }

   // At last, if the user has denied notifications, and you
   // want to be respectful there is no need to bother them any more.
 }
