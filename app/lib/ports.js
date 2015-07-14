exports.init = function init( elmApp ) {
	elmApp.ports.portsServiceRequests.subscribe( function( request ) {
		console.log( "lib/ports" );

		var response = 0;

		function requestType( request ) {
			return request;
		}

		switch( request ) {
			default:
				response = Math.random() * 5;
				break;
		}

		setTimeout( function() {
			elmApp.ports.portsServiceResponses.send( response );
		}, 2000 );
	});
};