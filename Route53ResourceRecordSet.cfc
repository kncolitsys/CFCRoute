component extends="Route53" hint="Manages AWS Route 53 Resource Record Sets" output="false" {
	// function init()
	public Route53ResourceRecordSet function init(required string AWSAccessKeyID, required string secretAccessKey, string baseURL) hint="initializer" {
		super.init(arguments.AWSAccessKeyID, arguments.secretAccessKey);
		
		// This is the base URL for REST-based communication with Amazon Route 53.
		if (structKeyExists(arguments, "baseURL")) {
			variables.baseURL = arguments.baseURL;
		} else {
			variables.baseURL = "https://route53.amazonaws.com/2010-10-01";
		}
		
		return this;
	} // init()

	// function changeResourceRecordSet()
	public struct function changeResourceRecordSet(required string hostedZoneID, required string action, required string name, required string type, required number TTL, required string value, string comment)
		hint="Changes a resource record set.  Amazon will allow you to add multiple of these in one request, but this function only lets you do one at a time.  See http://docs.amazonwebservices.com/Route53/latest/APIReference/API_ChangeResourceRecordSets.html ."
	{
		local.destinationURL = "/hostedzone/" & arguments.hostedZoneID & "/rrset";
		
		if (structKeyExists(arguments, "comment")) {
			local.comment = arguments.comment;
		} else {
			local.comment = "";
		}

		local.xml = '<?xml version="1.0" encoding="UTF-8"?>
		<ChangeResourceRecordSetsRequest xmlns="https://route53.amazonaws.com/doc/2010-10-01/">
		   <ChangeBatch>
		      <Comment>'
		      	& local.comment &
		      '</Comment>
		      <Changes>
		         <Change>
		            <Action>' & arguments.action & '</Action>
		            <ResourceRecordSet>
		               <Name>' & arguments.name & '</Name>
		               <Type>' & arguments.type & '</Type>
		               <TTL>'& arguments.TTL & '</TTL>
		               <ResourceRecords>
		                  <ResourceRecord>
		                     <Value>' & arguments.value & '</Value>
		                  </ResourceRecord>
		               </ResourceRecords>
		            </ResourceRecordSet>
		         </Change>
		      </Changes>
		   </ChangeBatch>
		</ChangeResourceRecordSetsRequest>';
		
		local.httpService = getHTTPService(destinationURL=local.destinationURL, method="POST");
		local.httpService.addParam(type="XML", name="message", value=local.xml);
		return local.httpService.send();
	} // changeResourceRecordSet()
	
	// function getChange()
	public struct function getChange(required string changeID) hint="Gets the status of a change" {
		local.destinationURL = "/change/" & arguments.changeID;
		local.httpService = getHTTPService(destinationURL=local.destinationURL, method="GET");
		return local.httpService.send();
	} // getChange()

	// function listResourceRecordSets()
	public struct function listResourceRecordSets(required string hostedZoneID, string type, string name, string maxItems) hint="Returns up to 100 resource record sets" {
		local.destinationURL = "/hostedzone/" & arguments.hostedzoneID & "/rrset";
		
		if (structKeyExists(arguments, "type")) {
			local.destinationURL = local.destinationURL & "?type=" & arguments.type;
			local.nextURLDelimiter = "&";
		} else {
			local.nextURLDelimiter = "?";
		}
		
		if (structKeyExists(arguments, "name")) {
			local.destinationURL = local.destinationURL & local.nextURLDelimiter & "name=" & arguments.name;
			local.nextURLDelimiter = "&";
		}
		
		if (structKeyExists(arguments, "maxItems") and (maxItems eq int(maxItems)) and (maxItems ge 0)) local.destinationURL = local.destinationURL & local.nextURLDelimiter & "maxItems=" & arguments.maxItems;
		local.httpService = getHTTPService(destinationURL=local.destinationURL, method="GET");
		return local.httpService.send();
	} // listResourceRecordSets()
}
