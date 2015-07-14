exports.init = function init( Elm ) {
	var app = Elm.fullscreen( Elm.ServiceDemoApp, {
		"portsServiceResponses": 0
	});

	require( './ports' ).init( app );

	return app;
};
