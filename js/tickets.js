(function(){

	var app = angular.module('triagrTickets', []);
	
	app.filter("sanitize", ['$sce', function($sce) {
	  return function(htmlCode){
		return $sce.trustAsHtml( htmlCode );
	  }
	}]);
	
	app.filter("sanitizeLinks", ['$sce', function($sce) {
	  return function(htmlCode){
		return $sce.trustAsHtml( htmlCode.toString().replace(/((http|https|ftp):\/\/[\w?=&.\/-;#~%-]+(?![\w\s?&.\/;#~%"=-]*>))/g, '<a href="$1" target="_blank">$1</a> ') );
	  }
	}]);

	app.filter('highlight', function($sce) {
	  return function(str, termsToHighlight) {
		// Sort terms by length
		termsToHighlight.sort(function(a, b) {
		  return b.length - a.length;
		});
		// Regex to simultaneously replace terms
		var regex = new RegExp('(' + termsToHighlight.join('|') + ')', 'gi');
		return $sce.trustAsHtml(str.toString().replace(regex, '<span class="bg-warning">$&</span>'));
	  };
	});
	

	app.directive("ticketHeader", function() {
		return {
			restrict: "E",
			templateUrl: "templates/ticket/header.html"
		};
	});
	app.directive("ticketContactInfo", function() {
		return {
			restrict: "E",
			templateUrl: "templates/ticket/contact-info.html"
		};
	});
	
	
app.directive('chosen', function() {
  var linker = function(scope, element, attr) {
        // update the select when data is loaded
        scope.$watch(attr.chosen, function(oldVal, newVal) {
            element.trigger('chosen:updated');
        });

        // update the select when the model changes
        scope.$watch(attr.ngModel, function() {
            element.trigger('chosen:updated');
        });
        
        element.chosen({width: '100%', search_contains: true});
    };

    return {
        restrict: 'A',
        link: linker
    };
})
	
	/*
	app.directive("ticketDetails", function() {
		return {
			restrict: "E",
			templateUrl: "templates/ticket/details.html"
		};
	});
	
	app.directive("ticketFields", function() {
		return {
			restrict: "E",
			templateUrl: "templates/ticket/fields.html"
		};
	});
	
	app.directive("ticketActions", function() {
		return {
			restrict: "E",
			templateUrl: "templates/ticket/actions.html"
		};
	});
	*/
	
app.getTicketTypeIcon = function() { 
	switch (this.ticketTypeLabel) {
		case 'Report Problem/Error':
			return tickTypeText = 'bug_report';
			break;
		case 'Ask A Question':
			return tickTypeText = 'help_outline';
			break;
		case 'Request a Service':
			return tickTypeText = 'assistant';
			break;
		case 'Submit Data Upload File':
			return tickTypeText = 'file_upload';
			break;
		case 'Report Slow Website Performance':
			return tickTypeText = 'alarm';
			break;
		case 'Request Callback':
			return tickTypeText = 'phone';
			break;
		default:
			return tickTypeText = 'layers';
	}
}

})();