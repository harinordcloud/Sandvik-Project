//https://learn.microsoft.com/en-us/azure/azure-monitor/vm/monitor-virtual-machine-alerts


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
  'AC-UK-FME-GOLD-AG': {
    id: '/subscriptions/SUBSCRIPTIONNUMBER/resourceGroups/RG-UK-FME/providers/microsoft.insights/actionGroups/AC-UK-FME-GOLD-AG'
    resourceGroupId: '/subscriptions/SUBSCRIPTIONNUMBER/resourceGroups/RG-UK-FME'
  }
 
  }

  
module cpuMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'cpuMonitor-${actionGroup.key}'
  params: {
    alertName: 'GOLD-Critical-PROD-VM - Alert when CPU usage is lower than 5 percent for the last 10 minutes'
    alertDescription: 'Triggers an alert when CPU usage is higher than 95%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'InsightsMetrics| where Origin == "vm.azm.ms" | where Namespace == "Processor" and Name == "UtilizationPercentage" | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 10m), Computer, _ResourceId'
    operator: 'GreaterThan'
    threshold: 95
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
  location: location
  }
}]


module memoryMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'memoryMonitor-${actionGroup.key}'
  params: {
    alertName: 'GOLD-Critical-PROD-VM - Alert when available memory is lower than 5 percent for the last 10 minutes'
    alertDescription: 'Triggers an alert when available memory is less than 5%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'Perf | where TimeGenerated > ago(10m) | where CounterName == "% Committed Bytes In Use" | project TimeGenerated, CounterName, CounterValue, Computer | summarize UsedMemory = avg(CounterValue) by CounterName, bin(TimeGenerated, 1m), Computer'
    operator: 'GreaterThan'
    threshold: 95
    metricMeasureColumn: 'UsedMemory'
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
  location: location
  }
}]

module diskSpaceMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'diskSpaceMonitor-${actionGroup.key}'
  params: {
    alertName: 'GOLD-Critical-PROD-VM - Alert when available disk space is lower than 5 percent for the last 10 minutes'
    alertDescription: 'Triggers an alert when available disk space is lower than 5%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'InsightsMetrics | where Origin == "vm.azm.ms" | where Namespace == "LogicalDisk" and Name == "FreeSpacePercentage" and Tags !has "/mnt" and Tags !has "T:" | extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"]) |summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 10m), Computer, _ResourceId, Disk'
    threshold: threshold
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
  location: location
  }
}]

module diskIOMonitor '../modules/scheduled_query_rules.bicep' = [for actionGroup in items(goldActionGroups): {
  name: 'diskIOMonitor-${actionGroup.key}'
  params: {
    alertName: 'GOLD-Critical-PROD-VM - Alert when free disk IO throughput is higher than than 95 percent for the last 90 minutes'
    alertDescription: 'Triggers an alert when free disk IO throughput is higher than than 95%'
    resourceGroupId: actionGroup.value.resourceGroupId
    query: 'InsightsMetrics| where Origin == "vm.azm.ms" | where Namespace == "LogicalDisk" and Name == "TransfersPerSecond" and Tags !has "/mnt" and Tags !has "T:" | extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"]) | summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 90m), Computer, _ResourceId, Disk'
    threshold: 95
    actionGroupId: actionGroup.value.id
    dimensions: dimensions
  location: location
  }
}]
