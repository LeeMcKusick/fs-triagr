<cfset tr = createObject('component', 'global.trello.web_service') />
<cfset triageBoard = tr.call('lists/557868c147ee4f352464de16/cards')>

<cfloop array="#triageBoard#" index="i">
	<cfset VARIABLES['' & i.name] = i.desc>
</cfloop> 