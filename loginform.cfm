<!DOCTYPE html>
<html>
<head>
<title>Triagr</title>

<meta name="viewport" content="width=device-width">

<link href='http://fonts.googleapis.com/css?family=Bree+Serif|Roboto:400,900,500,300,700,400italic,100' rel='stylesheet' type='text/css'>

<script src="//code.jquery.com/jquery-1.11.2.min.js"></script>
<script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>

<script src="js/formatDateTime/jquery.formatDateTime.js"></script>

<script src="js/jquery.cookie.js"></script>
<script src="js/chosen.jquery.min.js"></script>
<script src="js/jquery.hotkeys.js"></script>
<script src="js/jquery.highlight-5.js"></script>

<link rel="stylesheet" type="text/css" href="css/chosen.css">

<link rel="stylesheet" href="https://storage.googleapis.com/code.getmdl.io/1.0.0/material.cyan-pink.min.css">
<script src="https://storage.googleapis.com/code.getmdl.io/1.0.0/material.min.js"></script>
<link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">


<link rel="stylesheet" type="text/css" href="css/styles.css">


</head>
<body>

<div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">
	<header class="mdl-layout__header">
		<div class="mdl-layout__header-row">
			<!-- Title -->
			<span class="mdl-layout-title">Triagr</span>
		</div>
	</header>

	<main class="mdl-layout__content" id="main">
		<div id="loginWrapper">

		<cfoutput> 
			<form action="#CGI.script_name#?#CGI.query_string#" method="Post"> </cfoutput>

				<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label textfield-demo">
					<input class="mdl-textfield__input" name="j_username" type="text" id="username" />
					<label class="mdl-textfield__label" for="password">Username</label>
				</div>
				
				<div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label textfield-demo">
					<input class="mdl-textfield__input" name="j_password" type="password" id="password" />
					<label class="mdl-textfield__label" for="password">Password</label>
				</div>
				
				<br>
				<input  class="mdl-button mdl-js-button mdl-button--raised mdl-button--colored loginSubmit" type="submit" value="Log In"> 
			</form> 
		</div>
	</main>
	
	
</div>

	
	
</body>
</html>