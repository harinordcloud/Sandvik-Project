//https://learn.microsoft.com/en-us/azure/azure-monitor/vm/monitor-virtual-machine-alerts

// param alertSeverity int = 2 

param location string = 'uksouth'
param threshold int = 5
param dimensions object = {
  name: 'Computer'
  operator: 'Include'
  values: [
      '*'
  ]
}

var goldActionGroups = {
  'AC-UK-FME-BRONZE-AG': {
    id: '/subscriptions/SUBSCRIPTIONNUMBER/resourceGroups/RG-UK-FME/providers/microsoft.insights/actionGroups/AC-UK-FME-BRONZE-AG'
    resourceGroupId: '/subscriptions/SUBSCRIPTIONNUMBER/resourceGroups/RG-UK-FME'
  }
 
  }

  
module cpuMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'cpuMonitor-${actionGroup.key}'
  params: {
    alertName: 'BRONZE-Warning-PROD-VM - Alert when CPU usage is higher than 75 percent for the last 30 minutes'
    alertDescription: 'Triggers an alert when CPU usage is higher than 75%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'InsightsMetrics| where Origin == "vm.azm.ms" | where Namespace == "Processor" and Name == "UtilizationPercentage" | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 30m), Computer, _ResourceId'
    operator: 'GreaterThan'
    threshold: 75
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
    alertSeverity: 2
   // windowSize: 'PT30M'
  location: location
  }
}]


module memoryMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'memoryMonitor-${actionGroup.key}'
  params: {
    alertName: 'BRONZE-Warning-PROD-VM - Alert when available memory is lower than 10 percent for the last 10 minutes'
    alertDescription: 'Triggers an alert when available memory is less than 5%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'Perf | where TimeGenerated > ago(10m) | where CounterName == "% Committed Bytes In Use" | project TimeGenerated, CounterName, CounterValue, Computer | summarize UsedMemory = avg(CounterValue) by CounterName, bin(TimeGenerated, 1m), Computer'
    operator: 'GreaterThan'
    threshold: 90
    metricMeasureColumn: 'UsedMemory'
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
    alertSeverity: 2
    windowSize: 'PT10M'
  location: location
  }
}]

module diskSpaceMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'diskSpaceMonitor-${actionGroup.key}'
  params: {
    alertName: 'BRONZE-Warning-PROD-VM - Alert when available disk space is lower than 15 percent for the last 10 minutes'
    alertDescription: 'Triggers an alert when available disk space is lower than 15%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'InsightsMetrics | where Origin == "vm.azm.ms" | where Namespace == "LogicalDisk" and Name == "FreeSpacePercentage" and Tags !has "/mnt" and Tags !has "T:" | extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"]) |summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 10m), Computer, _ResourceId, Disk'
    threshold: 15
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
    alertSeverity: 2
  location: location
  }
}]

module diskIOMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'diskIOMonitor-${actionGroup.key}'
  params: {
    alertName: 'BRONZE-Warning-PROD-VM - Alert when free disk IO throughput is higher than than 85 percent for the last 90 minutes'
    alertDescription: 'Triggers an alert when free disk IO throughput is higher than than 85%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'InsightsMetrics| where Origin == "vm.azm.ms" | where Namespace == "LogicalDisk" and Name == "TransfersPerSecond" and Tags !has "/mnt" and Tags !has "T:" | extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"]) | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 60m), Computer, _ResourceId, Disk'
    threshold: 85
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
    alertSeverity: 2
  // windowSize: 'PT1H'
  location: location
  }
}]
