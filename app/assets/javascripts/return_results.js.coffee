# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$ ->
  ready()
  $('#registration_no').focus();

$(document).on "page:load",->
  ready()
  $('#registration_no').val("");
  $('#registration_no').focus();

ready = ->
  $("#registration_no").keypress(enterpress)
  $("#return_reason").keypress(enterpress2)
  $("#setreason").keypress(enterpress3)

find_query_result = -> 
        $.ajax({
          type : 'GET',
          url : '/return_results/find_query_result/',
          data: { registration_no: $('#registration_no').val()},
          dataType : 'script'
          });

do_return = -> 
        $.ajax({
          type : 'GET',
          url : '/return_results/do_return/',
          data: { registration_no: $('#registration_no').val(), return_reason: $('#return_reason option:selected').text()
                },
          dataType : 'script'
          });

enterpress = (e) ->
  e = e || window.event;   
  if e.keyCode == 13   
    if $('#registration_no').val() != ""
      find_query_result()
      return false;

enterpress2 = (e) ->
  e = e || window.event;   
  if e.keyCode == 13    
    $('#setreason').focus();
    return false;

enterpress3 = (e) ->
  e = e || window.event;   
  if e.keyCode == 13   
    if confirm("确定录入吗?") 
      do_return()
      $('#registration_no').val("");
      $('#registration_no').focus();
      return false;