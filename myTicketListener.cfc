<cfscript>
component extends="CFIDE.websocket.ChannelListener"
{
	DATA = {};

	public any function beforePublish(any message, Struct publisherInfo)
      {
		try {
			DATA = message;
			DATA['error'] = '';
			//cfdev01 has a different datasource name for the rss DB.
			serverName = CreateObject("java", "java.net.InetAddress").getLocalHost().getHostName();
			if ( FindNoCase( 'fsdevcf01' , serverName) > 0)
			{ message.dataSource = 'rss_cfauxsql03'; }
			else { message.dataSource = 'rss'; }

			if (message.action eq 'triage') {
				DATA['success'] = triageTicket(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.queueID, message.contactID, message.comment, message.user, message.action, message.apiKey);
			}
			if (message.action eq 'triageNMI') {
				DATA['success'] = assignTicketToQueue(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.queueID, message.contactID, message.comment, message.user, message.action, message.apiKey);
			}
			if (message.action eq 'sales') {
				DATA['success'] = assignTicketToQueue(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.queueID, message.contactID, message.comment, message.user, message.action, message.apiKey);
			}
			if (message.action eq 'schoolsuite') {
				DATA['success'] = assignTicketToQueue(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.queueID, message.contactID, message.comment, message.user, message.action, message.apiKey);
			}
			if (message.action eq 'update') {
				DATA['success'] = updateTicket(message.ticketNum, message.sandbox, message.dataSource, message.fieldData, message.contactID, message.user, message.apiKey);
			}
			if (message.action eq 'comment') {
				DATA['success'] = commentTicket(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.contactID, message.user, message.comment, message.action, message.showToCustomer, message.apiKey);
			}
			if (message.action eq 'internalComment') {
				DATA['success'] = commentTicket(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.contactID, message.user, message.comment, message.action, message.showToCustomer, message.apiKey);
			}
			if (message.action eq 'solve') {
				DATA['success'] = commentTicket(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.contactID, message.user, message.comment, message.action, message.showToCustomer, message.apiKey);
			}
			if (message.action eq 'trash') {
				DATA['success'] = trashTicket(message.ticketNum, message.sandbox, message.dataSource, message.user, message.action, message.apiKey);
			}
			if (message.action eq 'assignTo') {
				DATA['success'] = assignTicket(message.ticketNum, message.sandbox, message.dataSource, message.actionID, message.contactID, message.user, message.comment, message.action, message.showToCustomer, message.apiKey, message.csr);
			}

           return DATA;
		} catch (any e) {
			mailstuff('beforePublish Error', e.message&'<br>'&e.detail);;
		}
  }

	public function trashTicket(ticketNumber, sandbox, dataSource, user, action, key) {
		try {
			trashLog = new Query();
			trashLog.setDatasource(dataSource);
			trashLog.addParam(name="tn", value="#ticketNumber#", CFSQLTYPE="CF_SQL_INTEGER");
			trashLog.addParam(name="act", value="#action#", CFSQLTYPE="CF_SQL_VARCHAR");
			trashLog.addParam(name="us", value="#user#", CFSQLTYPE="CF_SQL_VARCHAR");
			trashLog.addParam(name="dat", value="#CREATEODBCDATETIME( Now() )#", CFSQLTYPE="CF_SQL_TIMESTAMP");
			trashLog.setSQL("
				INSERT INTO triagr_actionLog (ticketNumber, action, username, timestamp)
				VALUES(:tn, :act, :us, :dat)
			");
			trashLog.execute();

			sb = sandbox;
			tn = ticketNumber;
			ds = dataSource;
			ak = key;


			VARIABLES.PARATURE.TICKET = CreateObject('component','global.parature.ticket');
			VARIABLES.PARATURE.TICKET.SANDBOX = sb;
			trashMe = VARIABLES.PARATURE.TICKET.trash(ticket_id=tn, api_key=ak);

			return true;
		} catch (any e) {
			mailstuff('trashTicket Error', 'Type: ' & e.type &'
Message: '& e.message &'
Detail: '& e.detail  );
			DATA['error'] = e.message;
			return false;
		}
	}


	public function triageTicket(ticketNumber, sandbox, dataSource, taid, tqid, contactID, comment, user, action, key) {
		try {
			triageLog = new Query();
			triageLog.setDatasource(dataSource);
			triageLog.addParam(name="tn", value="#ticketNumber#", CFSQLTYPE="CF_SQL_INTEGER");
			triageLog.addParam(name="act", value="#action#", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="fld", value="", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="nl", value="", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="us", value="#user#", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="dat", value="#CREATEODBCDATETIME( Now() )#", CFSQLTYPE="CF_SQL_TIMESTAMP");
			triageLog.setSQL("
				INSERT INTO triagr_actionLog (ticketNumber, action, field, value, username, timestamp)
				VALUES(:tn, :act, :fld, :nl, :us, :dat)
			");
			triageLog.execute();

			sb = sandbox;
			cid = contactID;
			tn = ticketNumber;
			queueID = tqid;
			actionID = taid;
			ds = dataSource;
			cm = comment;
			ak = key;

			VARIABLES.PARATURE.TICKET = CreateObject('component','global.parature.ticket');
			VARIABLES.PARATURE.TICKET.SANDBOX = sb;
			tt = VARIABLES.PARATURE.TICKET.edit(ticket_id=tn,action_id=actionID,comment=cm, api_key=ak);

			return true;
		} catch (any e) {
			DATA['error'] = e.detail;

			mailstuff('triageTicket Error', e.message&'<br>'&e.detail);
			return false;
		}
	}

	public function assignTicketToQueue(ticketNumber, sandbox, dataSource, actionid, queueid, contactID, comment, user, action, key) {
		try {
			triageLog = new Query();
			triageLog.setDatasource(dataSource);
			triageLog.addParam(name="tn", value="#ticketNumber#", CFSQLTYPE="CF_SQL_INTEGER");
			triageLog.addParam(name="act", value="#action#", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="fld", value="", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="nl", value="", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="us", value="#user#", CFSQLTYPE="CF_SQL_VARCHAR");
			triageLog.addParam(name="dat", value="#CREATEODBCDATETIME( Now() )#", CFSQLTYPE="CF_SQL_TIMESTAMP");
			triageLog.setSQL("
				INSERT INTO triagr_actionLog (ticketNumber, action, field, value, username, timestamp)
				VALUES(:tn, :act, :fld, :nl, :us, :dat)
			");
			triageLog.execute();

			sb = sandbox;
			cid = contactID;
			tn = ticketNumber;
			qid = queueid;
			aid = actionid;
			ds = dataSource;
			cm = comment;
			ak = key;

			VARIABLES.PARATURE.TICKET = CreateObject('component','global.parature.ticket');
			VARIABLES.PARATURE.TICKET.SANDBOX = sb;
			tt = VARIABLES.PARATURE.TICKET.edit(ticket_id=tn,action_id=actionID,assigned_queue_id=qid,comment=cm, api_key=ak);

			return true;
		} catch (any e) {
			DATA['error'] = e.detail;

			mailstuff('triageTicket Error', e.message&'<br>'&e.detail);
			return false;
		}
	}

	public function updateTicket(ticketNumber, sandbox, dataSource, fieldData, contactID, user, key) {
		try {
			/*updateLog = new Query();
			updateLog.setDatasource(dataSource);
			updateLog.addParam(name="tn", value="#ticketNumber#", CFSQLTYPE="CF_SQL_INTEGER");
			updateLog.addParam(name="fld", value="#field#", CFSQLTYPE="CF_SQL_VARCHAR");
			updateLog.addParam(name="nl", value="#newLabel#", CFSQLTYPE="CF_SQL_VARCHAR");
			updateLog.addParam(name="us", value="#user#", CFSQLTYPE="CF_SQL_VARCHAR");
			updateLog.addParam(name="dat", value="#CREATEODBCDATETIME( Now() )#", CFSQLTYPE="CF_SQL_TIMESTAMP");
			updateLog.setSQL("
				INSERT INTO triagr_actionLog (ticketNumber, action, field, value, username, timestamp)
				VALUES(:tn, 'Update', :fld, :nl, :us, :dat)
			");
			updateLog.execute();
			*/


		/*	sb = sandbox;
			fid = fieldID;
			newV = newValue;
			cid = contactID;
			tn = ticketNumber;
			ds = dataSource;
			ak = key;*/
			cm = "Updated via Triagr";

			VARIABLES.PARATURE.TICKET = CreateObject('component','global.parature.ticket');
			VARIABLES.PARATURE.TICKET.SANDBOX = sandbox;

			customXML = [];
			//mailstuff('test', 'test' );

			for (f in fieldData){
				ArrayAppend(customXML, '<Custom_Field id="' & f.fieldID & '"><Option id="' & f.newValue & '" selected="true"></Option></Custom_Field>');
			}

			ut = VARIABLES.PARATURE.TICKET.edit(ticket_id=ticketNumber, customer_id=contactID, fields=customXML, api_key=key );
			return true;
		} catch (any e) {
			DATA['error'] = e.detail;

			mailstuff('updateTicket Error', e.message&'<br>'&e.detail);
			return false;
		}
	}

	public function commentTicket (ticketNumber, sandbox, dataSource, actionID, contactID, user, comment, action, showToCust, key) {
		try {
			commentLog = new Query();
			commentLog.setDatasource(dataSource);
			commentLog.addParam(name="tn", value="#ticketNumber#", CFSQLTYPE="CF_SQL_INTEGER");
			commentLog.addParam(name="act", value="#action#", CFSQLTYPE="CF_SQL_VARCHAR");
			commentLog.addParam(name="us", value="#user#", CFSQLTYPE="CF_SQL_VARCHAR");
			commentLog.addParam(name="dat", value="#CREATEODBCDATETIME( Now() )#", CFSQLTYPE="CF_SQL_TIMESTAMP");
			commentLog.setSQL("
				INSERT INTO triagr_actionLog (ticketNumber, action, username, timestamp)
				VALUES(:tn, :act, :us, :dat)
			");
			commentLog.execute();

			aid = actionID;
			sb = sandbox;
			cid = contactID;
			tn = ticketNumber;
			sh = showToCust;
			ds = dataSource;
			cm = comment;
			ak = key;


					VARIABLES.PARATURE.TICKET = CreateObject('component','global.parature.ticket');
					VARIABLES.PARATURE.TICKET.SANDBOX = sb;
					//mailstuff('commentTicket test', tn&'<br>'&aid&'<br>'&cid&'<br>'&sh&'<br>'&cm);

					cmmntTicket = VARIABLES.PARATURE.TICKET.edit( ticket_id=tn, action_id=aid, comment=cm, show_to_customer=sh, api_key=ak);
					//mailstuff('commentTicket result', 'success);
			return true;
		} catch (any e) {
			DATA['error'] = e.detail;

			mailstuff('commentTicket Error', e.message&'<br>'&e.detail);
			return false;
		}

	}

	public function assignTicket (ticketNumber, sandbox, dataSource, actionID, contactID, user, comment, action, showToCust, key, theCsr) {
		try {
			assignLog = new Query();
			assignLog.setDatasource(dataSource);
			assignLog.addParam(name="tn", value="#ticketNumber#", CFSQLTYPE="CF_SQL_INTEGER");
			assignLog.addParam(name="act", value="#action#", CFSQLTYPE="CF_SQL_VARCHAR");
			assignLog.addParam(name="us", value="#user#", CFSQLTYPE="CF_SQL_VARCHAR");
			assignLog.addParam(name="dat", value="#CREATEODBCDATETIME( Now() )#", CFSQLTYPE="CF_SQL_TIMESTAMP");
			assignLog.setSQL("
				INSERT INTO triagr_actionLog (ticketNumber, action, username, timestamp)
				VALUES(:tn, :act, :us, :dat)
			");
			assignLog.execute();

			aid = actionID;
			sb = sandbox;
			cid = contactID;
			tn = ticketNumber;
			sh = showToCust;
			ds = dataSource;
			cm = comment;
			ak = key;
			csr = theCsr;

			VARIABLES.PARATURE.TICKET = CreateObject('component','global.parature.ticket');
			VARIABLES.PARATURE.TICKET.SANDBOX = sb;

			assTick = VARIABLES.PARATURE.TICKET.edit( ticket_id=tn, action_id=aid, assigned_csr_id=csr, comment=cm, show_to_customer=sh, api_key=ak);

			return true;
		} catch (any e) {
			DATA['error'] = e.detail;

			mailstuff('assignTicket Error', e.message&'<br>'&e.detail);
			return false;
		}

	}

	public function mailstuff(subject, contents) {
		mailer = new mail();
		mailer.setType('html');
		mailer.setTo('lee.mckusick@finalsite.com');
		//mailer.setCC('blake.eddins@finalsite.com');
		mailer.setFrom('triagr@finalsite.com');
		mailer.setSubject(subject);
		mailer.setType('Text');
		mailer.send(body=contents);
	}
}
</cfscript>
