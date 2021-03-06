angular.module('InescApp').directive 'summaryTable', ['$filter', ($filter) ->
  columns = [
    { sTitle: 'Mês', bSortable: false, sClass: 'month' }
    { sTitle: 'Autorizado', bSortable: false, sClass: 'currency' }
    { sTitle: 'Pago', bSortable: false, sClass: 'currency' }
    { sTitle: 'RP Pago', bSortable: false, sClass: 'currency' }
    { sTitle: 'Pagamentos (Pago + RP Pago)', bSortable: false, sClass: 'currency' }
    { sTitle: 'Mês', bVisible: false } # Usado só para sorting
  ]

  options =
    bPaginate: false
    aaSorting: [[ 5, 'asc' ]]
    sDom: 't'

  processData = (entity) ->
    monthFilter = $filter('month')
    currencyFilter = $filter('currency')
    months = []
    $.each entity.autorizado.drilldown, (i, element) ->
      month = parseInt(element.time.month)
      months[month] ||= {label: element.time.month}
      months[month].autorizado = element.amount
    $.each entity.rppago.drilldown, (i, element) ->
      month = parseInt(element.time.month)
      months[month] ||= {label: element.time.month}
      months[month].rppago = element.rppago
    $.each entity.pago.drilldown, (i, element) ->
      month = parseInt(element.time.month)
      months[month] ||= {label: element.time.month}
      months[month].pago = element.pago
    $.each entity.pagamentos.drilldown, (i, element) ->
      month = parseInt(element.time.month)
      months[month] ||= {label: element.time.month}
      months[month].pagamentos = element.pagamentos
    months.push
      label: 'Total'
      autorizado: entity.autorizado.total
      pago: entity.pago.total
      rppago: entity.rppago.total
      pagamentos: entity.pagamentos.total
    months.filter((month) -> month).map (month, i) ->
      [monthFilter(month.label)
        currencyFilter(month.autorizado, '')
        currencyFilter(month.pago, '')
        currencyFilter(month.rppago, '')
        currencyFilter(month.pagamentos, '')
        month.label]

  restrict: 'E',
  scope:
    entity: '=',
    totals: '=',
    year: '='
  template: '<my-data-table class="table graph-numbers" columns="columns" options="options" data="data"></my-data-table>'
  link: (scope, element, attributes) ->
    scope.columns = columns
    scope.options = options
    scope.$watch 'entity.autorizado', ->
      entity = scope.entity
      if entity? and entity.autorizado?
        scope.data = processData(entity)
]

