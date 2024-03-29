ready = ->
  $('#start_date_start_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#end_date_end_date').datepicker({
    changeMonth:true,
    changeYear:true
  });
  $('#order_date_order_date').datepicker({
    showAnim:"blind",
    changeMonth:true,
    changeYear:true
  });
  $('#return_date_return_date').datepicker({
    changeYear: true,       
    changeMonth: true,      
    dateFormat: "yy-mm"
  });
  
$(document).ready(ready)
$(document).on('page:load', ready)