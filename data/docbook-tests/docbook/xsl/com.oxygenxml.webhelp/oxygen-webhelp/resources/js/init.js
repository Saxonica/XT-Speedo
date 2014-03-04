/*

Oxygen Webhelp plugin
Copyright (c) 1998-2013 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

var dif = 0;
var last = 0;
var start = 0;
var currentReq=null;
var conf=null;

function logLocal(msg){
  var date = new Date();
  if (start == 0) {
    start = date.getTime();
  }
  dif = date.getTime() - last;
  last = date.getTime();
  var total = last - start;
//console.log(total + ":" + dif + " " + msg);
}

if (typeof debug !== 'function') {
  function debug(msg,obj){
    if (top !== self){
      if (typeof parent.debug !== 'function') {    
        logLocal(msg);
      }else{
        if (typeof msg!=="undefined"){
          if (typeof msg==="object"){
            parent.debug('['+src+']',msg);
          }else{
            parent.debug('['+src+']'+msg,obj);
          }
        }
      }
    }else{
      logLocal(msg);  
    }
  }
}
if (typeof error !== 'function') {
  function error(msg,obj){
    if (top !== self){
      if (typeof parent.error !== 'function') {    
        logLocal(msg);
      }else{
        if (typeof msg!=="undefined"){
          if (typeof msg==="object"){
            parent.error('['+src+']',msg);
          }else{
            parent.error('['+src+']'+msg,obj);
          }
        }
      }
    }else{
      logLocal(msg);  
    }
  }
}
if (typeof info !== 'function') {
  function info(msg,obj){
    if (top !== self){
      if (typeof parent.info !== 'function') {    
        logLocal(msg);
      }else{
        if (typeof msg!=="undefined"){
          if (typeof msg==="object"){
            parent.info('['+src+']',msg);
          }else{
            parent.info('['+src+']'+msg,obj);
          }
        }
      }
    }else{
      logLocal(msg);  
    }
  }
}
if (typeof warn !== 'function') {
  function warn(msg,obj){
    if (top !== self){
      if (typeof parent.warn !== 'function') {    
        logLocal(msg);
      }else{
        if (typeof msg!=="undefined"){
          if (typeof msg==="object"){
            parent.warn('['+src+']',msg);
          }else{
            parent.warn('['+src+']'+msg,obj);
          }
        }
      }
    }else{
      logLocal(msg);  
    }
  }
}
function objToString (obj) {
    var str = '';
    for (var p in obj) {
        if (obj.hasOwnProperty(p)) {
            str += p + '::' + obj[p] + '\\n';
        }
    }    
    return str;
}
$.ajaxSetup({
  cache	  	: true,
  timeout 	: 60000,
  error 	: function(jqXHR, errorType, exception) {
			error("[AJX] error :["+jqXHR.status +":"+jqXHR.responseText +"]:"+errorType+":"+objToString(exception));
			},
  complete 	: function(jqXHR, textStatus){
  			if (textStatus != "success"){
					//console.log(\"?complete :\"+jqXHR+\":\"+textStatus);
  			}
			}
});
window.onerror = function (msg, url, line) {
  error("[JS]: "+msg+" in page: "+url+" al line: "+ line);   
}     


function init(depth) {
  var depthArray=depth.split('../');  
  var loc= window.location.pathname.split('/');  
  var basePath="/";
  for(var i=(loc.length-depthArray.length-1);i>0;i--){
    basePath='/'+loc[i]+basePath;
  }
  var baseUrl=window.location.protocol+'//'+window.location.host+basePath
  debug('depth = '+depth);
  debug('new relpath='+basePath);
  debug('location='+baseUrl);
  conf = {"htpath":basePath,"baseUrl":baseUrl};
  debug('new conf=',conf);
  $('#passwordIframe').attr('src', baseUrl+'oxygen-webhelp/noScript.html');
  highlightSearchTerm();
  
  if (window.location.href.indexOf('file://') !== 0){
//        realInclude = depth + 'oxygen-webhelp/resources/comments.html';
//
//        $.get(realInclude, function(data) {
//    
//          var text = data.replace(/@relPath@/g, depth);
//    
//          /*
//    		 * var div = document.getElementById("commentsContainer"); div.innerHTML =
//    		 * text; runScripts(div);
//    		 */
//          $('#commentsContainer').html(text);
//        });
    if(checkConfig()) {
        isInstaller=false;
    } else {
        isInstaller=true;
    }
    
    $.ajax({
      type : "POST",
      url : depth + "oxygen-webhelp/resources/php/cmts.php",
      data : "&depth="+depth+"&isInstaller="+isInstaller,
      success : function(data_response) {
        $('#cmts').html(data_response);
      }
    });    
  }
}
