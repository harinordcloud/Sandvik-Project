@description('Name of the alert')
@minLength(1)
param alertName string

@description('Location of the alert')
@minLength(1)
param location string = 'westeurope'

@description('Description of alert')
param alertDescription string

@description('Severity of alert {0,1,2,3,4}')
@allowed([
  0
  1
  2
  3
  4
])
param alertSeverity int = 0

@description('Specifies whether the alert is enabled')
param isEnabled bool = true

@description('Full Resource ID of the resource emitting the metric that will be used for the comparison. For example /subscriptions/00000000-0000-0000-0000-0000-00000000/resourceGroups/ResourceGroupName/providers/Microsoft.compute/virtualMachines/VM_xyz')
@minLength(1)
param resourceGroupId string

@description('Name of the metric used in the comparison to activate the alert.')
@minLength(1)
param query string

@description('Name of the measure column used in the alert evaluation.')
param metricMeasureColumn string = 'AggregatedValue'

@description('Operator comparing the current value with the threshold value.')
@allowed([
  'Equals'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string = 'LessThan'

@description('The threshold value at which the alert is activated.')
param threshold int

@description('The number of periods to check in the alert evaluation.')
param numberOfEvaluationPeriods int = 1

@description('The number of unhealthy periods to alert on (must be lower or equal to numberOfEvaluationPeriods).')
param minFailingPeriodsToAlert int = 1

@description('How the data that is collected should be combined over time.')
@allowed([
  'Average'
  'Minimum'
  'Maximum'
  'Total'
  'Count'
])
param timeAggregation string = 'Average'

@description('Period of time used to monitor alert activity based on the threshold. Must be between one minute and one day. ISO 8601 duration format.')
@allowed([
  'PT1M'
  'PT5M'
  'PT10M'
  'PT15M'
  'PT30M'
  'PT1H'
  'PT6H'
  'PT12H'
  'PT24H'
])
param windowSize string = 'PT10M'

@description('how often the metric alert is evaluated represented in ISO 8601 duration format')
@allowed([
  'PT5M'
  'PT10M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT10M'

@description('The ID of the action group that is triggered when the alert is activated or deactivated')
param actionGroupId string 

param dimensions object

param tags object = {
  'af-applicationname': 'nordcloud-monitoring'
  'af-applicationowner': 'mail_address'
  'af-costassignment': '12345'
}

resource alert 'Microsoft.Insights/scheduledQueryRules@2022-06-15' = {
  name: alertName
  location: location
  tags: tags
  properties: {
    description: alertDescription
    severity: alertSeverity
    enabled: isEnabled
    targetResourceTypes: [
      'Microsoft.Compute/virtualMachines'
    ]
    scopes: [
      resourceGroupId
    ]
    skipQueryValidation: true
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          query: query
          metricMeasureColumn: metricMeasureColumn
          dimensions: [dimensions]
          operator: operator
          threshold: threshold
          timeAggregation: timeAggregation
          failingPeriods: {
            numberOfEvaluationPeriods: numberOfEvaluationPeriods
            minFailingPeriodsToAlert: minFailingPeriodsToAlert
          }
        }
      ]
    }
    autoMitigate: true
    actions: {
      actionGroups: [
         actionGroupId
      ]
    }
  }
}
