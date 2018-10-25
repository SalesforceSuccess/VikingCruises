@RestResource(urlMapping='/VikingCampaigns/*')
global with sharing class VikingCampaigns {
    
    public Class VikingCampagin
    {
    	public String Name{get;set;}
    	public String CampaignCode{get;set;}
    	public String City{get;set;}
    	public Datetime EventDate{get;set;}
    	public Integer 	Capacity{get;set;}
    	public Integer RegisterNumber{get;set;}
    	public String QRCodeUrl{get;set;}
    	public String FormUrl {get;set;}
    }	


    @HttpGet
    global static String getAllCampaigns()
    {
    	List<Campaign> vikingCampaings = new List<Campaign>();
    	vikingCampaings = [Select Id,Name,date__c,CampaignCode__c,Capacity__c,City__c,Registration_Number__c,(Select Id,Name From Charket__WeChatCampaignFlows__r limit 1) from Campaign where date__c > today];
    	
    	List<Charket__WeChatQRCode__c> campaignCodes = new List<Charket__WeChatQRCode__c>();
    	campaignCodes = [Select Id,Charket__WhatId__c,Charket__Url__c From Charket__WeChatQRCode__c Where Charket__IsActive__c = True];

    	Set<Id> campaingFlowIds = new Set<Id>();

    	for(Campaign item : vikingCampaings)
    	{
    		if(item.Charket__WeChatCampaignFlows__r.size() > 0)
    		{
    			Charket__WeChatCampaignFlow__c campaignFlow = item.Charket__WeChatCampaignFlows__r[0];
    			campaingFlowIds.add(campaignFlow.Id);
    		}
    		
    	}

    	List<Charket__WeChatCampaignFlowStep__c> followSteps = new List<Charket__WeChatCampaignFlowStep__c>();
    	followSteps = [Select Id,Name,Charket__Type__c,Charket__WeChatCampaignFlow__c,Charket__Rules__c From Charket__WeChatCampaignFlowStep__c Where Charket__IsActive__c = True And Charket__Type__c = 'Registration' AND Charket__WeChatCampaignFlow__c in: campaingFlowIds];
    	

    	Map<String,String> flowMapFlowRegisterationStep = new Map<String,String>();
    	Map<Id,Charket__WeChatCampaignFlowStep__c> campaginFlowMapCampaginSteps = new Map<Id,Charket__WeChatCampaignFlowStep__c>();
    	for(Id flowID : campaingFlowIds)
    	{
    		for(Charket__WeChatCampaignFlowStep__c step : followSteps)
    		{
    			if(step.Charket__WeChatCampaignFlow__c == flowID)
    			{
    				flowMapFlowRegisterationStep.put(flowID, step.Id);
    				campaginFlowMapCampaginSteps.put(flowID, step);

    			}
    		}
    	}

    	Map<String,String> campaingMapFlowSteps = new Map<String,String>();
    	for(Campaign item : vikingCampaings)
    	{
    		if(item.Charket__WeChatCampaignFlows__r.size() > 0)
    		{
    			Charket__WeChatCampaignFlow__c campaignFlow = item.Charket__WeChatCampaignFlows__r[0];
    			campaingMapFlowSteps.put(item.Id, flowMapFlowRegisterationStep.get(campaignFlow.Id));
    		}
    		
    	}

    	List<VikingCampagin> results = new List<VikingCampagin>();
    	for(Campaign item : vikingCampaings)
    	{
    		if(item.Charket__WeChatCampaignFlows__r.size() > 0)
    		{
    				VikingCampagin vcActivities  = new VikingCampagin();
		    		vcActivities.Name = item.Name;
		    		vcActivities.CampaignCode = item.CampaignCode__c;
		    		vcActivities.City  = item.City__c;
		    		vcActivities.RegisterNumber = (Integer)item.Registration_Number__c;
		    		vcActivities.EventDate = item.Date__c;
		    		vcActivities.Capacity =(Integer)item.Capacity__c;

		    		for(Charket__WeChatQRCode__c qrcode : campaignCodes)
		    		{
		    			if(campaingMapFlowSteps.get(item.Id) == qrcode.Charket__WhatId__c)
		    			{
		    				vcActivities.QRCodeUrl = qrcode.Charket__Url__c; 
		    			}
		    		}

		    		String rules =  campaginFlowMapCampaginSteps.get(item.Charket__WeChatCampaignFlows__r[0].Id).Charket__Rules__c;
		    		String flowStepId = campaginFlowMapCampaginSteps.get(item.Charket__WeChatCampaignFlows__r[0].Id).Id;

		    		Map<String,Object> mapCampaigns = (Map<String,Object>)JSON.deserializeUntyped(rules);
		    		Map<String,Object> campaginForm =(Map<String,Object>)mapCampaigns.get('Form');
		    		vcActivities.FormUrl = (String)campaginForm.get('FormURL') + '&spid='+flowStepId;

		    		results.add(vcActivities);
    		}
    		

    	}
    	String jsonResults = '';
    	jsonResults = JSON.serialize(results);

    	return jsonResults;

    }
}