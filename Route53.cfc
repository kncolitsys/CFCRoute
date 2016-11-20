component extends="awsconsole.cfcs.ec2" hint="Manages AWS Route 53 Hosted Zones" output="false" {
	// function init()
	public Route53 function init(required string AWSAccessKeyID, required string secretAccessKey, string baseURL) hint="initializer" {
		super.init(arguments.AWSAccessKeyID, arguments.secretAccessKey);
		
		// This is the base URL for REST-based communication with Amazon Route 53.
		if (structKeyExists(arguments, "baseURL")) {
			variables.baseURL = arguments.baseURL;
		} else {
			variables.baseURL = "https://route53.amazonaws.com/2010-10-01";
		}
		
		return this;
	} // init()
	
	/*
		PRIVATE FUNCTIONS
	*/
	// function getFormattedDateTime()
	public date function getFormattedDateTime(date theDate) hint="Takes a date you pass in, or now(), and returns a date formatted the way Amazon wants it." {
		if (structKeyExists(arguments, "theDate") and isDate(arguments.theDate)) {
			local.theDate = arguments.theDate;
		} else {
			local.theDate = now();
		}

		local.formattedNow = dateAdd("h", getTimeZoneInfo().UTCHourOffset, now());
		return lsDateFormat(local.formattedNow, "ddd, dd mmmm yyyy") & " " & lsTimeFormat(local.formattedNow, "HH:MM:SS") & " GMT"; // Sun, 06 Nov 1994 08:49:37 GMT
	} // getFormattedDateTime()
	
	// function getHTTPService()
	public struct function getHTTPService(required string destinationURL, required string method, date theDate) hint="All the calls in here need to create an http object, with some basic headers.  This sets that up and returns it." {
		if (structKeyExists(arguments, "theDate") and isDate(arguments.theDate)) {
			local.formattedNow = getFormattedDateTime(arguments.theDate);
		} else {
			local.formattedNow = getFormattedDateTime();
		}
		
		local.destinationURL = variables.baseURL & arguments.destinationURL;
		local.signature = createSignature(local.formattedNow);
		local.httpService = new http(method=arguments.method, URL=local.destinationURL);
		local.httpService.addParam(type="header", name="x-amz-date", value=local.formattedNow);
		local.httpService.addParam(type="header", name="X-Amzn-Authorization", value="AWS3-HTTPS AWSAccessKeyId=#variables.AWSAccessKeyID#,Algorithm=HmacSHA1,Signature=#local.signature#");
		local.httpService.setCharset("utf-8");
		return local.httpService;
	} // getHTTPService()
}
