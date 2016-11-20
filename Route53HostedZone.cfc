component extends="Route53" hint="Manages AWS Route 53 Hosted Zones" output="false" {
	// function init()
	public Route53HostedZone function init(required string AWSAccessKeyID, required string secretAccessKey, string baseURL) hint="initializer" {
		super.init(arguments.AWSAccessKeyID, arguments.secretAccessKey);

		// This is the base URL for REST-based communication with Amazon Route 53.
		if (structKeyExists(arguments, "baseURL")) {
			variables.baseURL = arguments.baseURL;
		} else {
			variables.baseURL = "https://route53.amazonaws.com/2010-10-01";
		}

		return this;
	} // init()

	// function createHostedZone()
	public struct function createHostedZone(required string name, required string callerReference, string comment)
		hint="Creates a Route 53 DNS hosted zone.  local.s_result.status_code will be 201 if successful, false otherwise."
	{
		local.destinationURL = "/hostedzone";

		if (structKeyExists(arguments, "comment")) {
			local.comment = arguments.comment;
		} else {
			local.comment = "";
		}

		local.xml = '<?xml version="1.0" encoding="UTF-8"?>
		<CreateHostedZoneRequest xmlns="https://route53.amazonaws.com/doc/2010-10-01/">
		   <Name>' & arguments.name & '</Name>
		   <CallerReference>' & arguments.callerReference & '</CallerReference>
		   <HostedZoneConfig>
		      <Comment>' & local.comment & '</Comment>
		   </HostedZoneConfig>
		</CreateHostedZoneRequest>';

		local.httpService = getHTTPService(destinationURL=local.destinationURL, method="POST");
		local.httpService.addParam(type="XML", name="message", value=local.xml);
		return local.httpService.send();
	} // createHostedZone()

	// function deleteHostedZone()
	public struct function deleteHostedZone(string ID) hint="Deletes a specific hosted zone.  Just send the hosted zone ID without the /hostedzone/ part." {
		local.destinationURL = "/hostedzone/" & arguments.ID;
		local.httpService = getHTTPService(destinationURL=local.destinationURL, method="DELETE");
		return local.httpService.send();
	} // deleteHostedZone()

	// function getHostedZone()
	public struct function getHostedZone(string ID) hint="Gets a specific hosted zone.  Just send the hosted zone ID without the /hostedzone/ part." {
		local.destinationURL = "/hostedzone/" & arguments.ID;
		local.httpService = getHTTPService(destinationURL=local.destinationURL, method="GET");
		return local.httpService.send();
	} // getHostedZone()

	// function listHostedZones()
	public struct function listHostedZones(string marker, numeric maxItems) hint="Returns up to 100 hosted zones" {
		local.destinationURL = "/hostedzone";

		if (structKeyExists(arguments, "marker")) {
			local.destinationURL = local.destinationURL & "?marker=" & arguments.marker;
			local.nextURLDelimiter = "&";
		} else {
			local.nextURLDelimiter = "?";
		}

		if (structKeyExists(arguments, "maxItems") and (maxItems eq int(maxItems)) and (maxItems ge 0)) local.destinationURL = local.destinationURL & local.nextURLDelimiter & "maxItems=" & arguments.maxItems;
		local.httpService = getHTTPService(destinationURL=local.destinationURL, method="GET");
		return local.httpService.send();
	} // listHostedZones()
}
