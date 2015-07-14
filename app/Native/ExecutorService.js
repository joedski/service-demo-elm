// This code is compiler-version dependent...

Elm.Native.ExecutorService = Elm.Native.ExecutorService || {};
Elm.Native.ExecutorService.make = function( localRuntime ) {
	localRuntime.Native = localRuntime.Native || {};
	localRuntime.Native.ExecutorService = localRuntime.Native.ExecutorService || {};

	if( localRuntime.Native.ExecutorService.values ) {
		return localRuntime.Native.ExecutorService.values;
	}

	var Task = Elm.Native.Task.make( localRuntime );

	var timeoutTime = 2000; // 2s.

	function requestType( request ) {
		// update this if the request type changes...
		return request;
	}

	function send( request ) {
		return Task.asyncFunction( function( callback ) {
			console.log( "Native.ExecutorService.send" );
			
			var type = requestType( request );

			switch( type ) {
				default:
					succeed();
					break;
			}

			function succeed() {
				callbackAfterTimeout( Task.succeed( Math.random() * 5 ) );
			}

			function fail() {
				callbackAfterTimeout( Task.fail( "Invalid request type: " + type ) );
			}

			function callbackAfterTimeout( taskResult ) {
				setTimeout( function() { callback( taskResult ); }, timeoutTime );
			}
		});
	}

	return localRuntime.Native.ExecutorService.values = {
		// As of writing this, if you wanted a function of 2 values, you'd have to wrap this in a call to F2.
		// So on for functions of 3, 4, or numbers of arguments.
		send: send
	};
};