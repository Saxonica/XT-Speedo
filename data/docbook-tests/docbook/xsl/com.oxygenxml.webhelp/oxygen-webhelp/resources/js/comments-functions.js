/*

Oxygen Webhelp plugin
Copyright (c) 1998-2013 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

/**
 * init.js must be included before and var conf must be defined after call of init();
 */

var productName = $("#oxy_productID").text();
var productVersion = $("#oxy_productVersion").text();
var pageSearch = window.location.href;
var pageHash= window.location.hash;
var isModerator=false;
var isAnonymous=false;
var pathName = window.location.pathname;
var scrollAfterAjax=null;
var commentsPosition=0; // default 0 not visible
var showAddNewComment=true;

var pageWSearch = pageSearch.replace(window.location.search,"");
pageWSearch = pageWSearch.replace(window.location.hash,"");

var lastPreloadMessage=null;

var scripts = document.getElementsByTagName("script"),
src = scripts[scripts.length-1].src;
src=src.substring(src.lastIndexOf('/')+1);

if (typeof debug !== 'function') {
  function debug(msg,obj){
    if (top !== self){
    if (typeof parent.debug !== 'function') {    
      //
    }else{
      parent.debug("["+src+']'+msg,obj);
    }
    }else{
      // local log
    }
  }
}
if (typeof info !== 'function') {
  function info(msg,obj){
    if (top !== self){
    if (typeof parent.info !== 'function') {    
      //
    }else{
      parent.info("["+src+']'+msg,obj);
    }
    }else{
      // local log
    }
  }
}
if (typeof warn !== 'function') {
  function warn(msg,obj){
    if (top !== self){
    if (typeof parent.warn !== 'function') {    
      //
    }else{
      parent.warn("["+src+']'+msg,obj);
    }
    }else{
      // local log
    }
  }
}
if (typeof error !== 'function') {
  function error(msg,obj){
    if (top !== self){
    if (typeof parent.error !== 'function') {    
      //
    }else{
      parent.error("["+src+']'+msg,obj);
    }
    }else{
      // local log
    }
  }
}
window.onerror = function (msg, url, line) {
  error("[JS]: "+msg+" in page: "+url+" al line: "+ line);   
}     

debug('productName ='+productName);
debug('productVersion ='+productVersion);
debug('pageSearch = '+pageSearch);
debug('pageHash= '+pageHash);
debug('pathName = '+pathName);
debug('pageWSearch ='+pageWSearch);

function initNewComment(){  
  if ($("#newComment").parent().get(0).tagName != "BODY") {
		$("#newComment").appendTo("body");
	}
	if (showAddNewComment){
		$('#commentTitle').html(getLocalization('newPost'));
		$('#newComment').show();
  }
	refreshEditor();
	$("#commentText").cleditor()[0].clear();
	$('#newComment').hide();
}
function getLocalization(localizationKey) {
	var toReturn=localizationKey;
	if((localizationKey in localization)){
				toReturn=localization[localizationKey];
			}
	    return toReturn;
	}

function resetData() {
	$('#loginData').hide();
//	$('#newComment').hide();
  initNewComment();
  if ($("#newComment").parent().get(0).tagName != "BODY") {
		$("#newComment").appendTo("body");
	}
	
  $('#commentTitle').html(getLocalization('newPost'));
	$('#newComment').hide();    
	$('#signUp').hide();
	$('#editedId').val("");
	$('#u_Profile').hide();
	$("#u_Profile input").attr("type", function(arr) {
		var inputType = $(this).attr("type");
		if (inputType == "text" || inputType == "password") {
			$(this).val("");
		}
	});
	$('#recoverPwd').hide();
	if ($("#confirmDelete").parent().get(0).tagName != "BODY") {
		$("#confirmDelete").appendTo("body");
		$("#commentToDelete").html('');
		$("#confirmDelete").hide();
	}
	

	$("#newComment textarea").val("");
	$("#loginResponse").html("");
	$("#loginData input").attr("type", function(arr) {
		var inputType = $(this).attr("type");
		if (inputType == "text" || inputType == "password") {
			$(this).val("");
		}
	});
}

function checkConfig(){
	var page=conf.htpath + "oxygen-webhelp/resources/php/checkInstall.php";	
	
	var response=false;
      //{"installPresent":"true","configPresent":"false"};
    
	$.ajax({
		type : "POST",
		url : page,
		data : "",
        async : false,
		success : function(data_response) {
          debug('check page:'+page);
		  var config= eval("("+data_response+")");
          if (config.installPresent=="true" && config.configPresent=="true"){
	//	window.location.href=conf.baseUrl+"oxygen-webhelp/resources/removeInstallDir.html";
		$("#commentsContainer").parent().append("<div id=\"fbUnavailable\"><strong>"+getLocalization('label.fbUnavailable')+"<br/>" +getLocalization('label.removeInst')+"</strong></div>");        
		$("#fbUnavailable").addClass('red');
        $("#commentsContainer").hide();
        $("#commentsContainer").remove();
        debug('showComments() - red');
	}else if (config.configPresent=="true"){
      response=true;      
      // show comments
    }else{      
      debug('Redirect to Install ...');
		$('#bt_logIn').hide();
		$('#bt_signUp').hide();
		$('#bt_new').hide();
		$('#cm_title').append(' - '+getLocalization('configInvalid'));
		window.parent.location.href=conf.htpath +"install/";
	}
		}});	
    debug('checkConfig() -',response);
	return response;
}


function showComments() {
	hideAll();
//	if ($('#commentsContainer').find('#fbUnavailable').size()>0){
      debug('showComments()-');
    if (document.getElementById('comments')&&(!lastCmdLocation)){
      lastCmdLocation =document.getElementById('comments').style.top;
    }            
    showPreload(getLocalization('label.plsWaitCmts'));	
    resetData();
	displayUserAccount();
	var processComments = conf.htpath+"oxygen-webhelp/resources/php/showComments.php";
	
	//var page = '&page=' + pageWSearch + "&productName=" + productName + "&productVersion=" + productVersion;
    var pageWPath=window.location.pathname;
	var page = '&page=' + pageWPath + "&productName=" + productName + "&productVersion=" + productVersion;
	
	$.ajax({
		type : "POST",
		url : processComments,
		data : page,
		success : function(data_response) {
			hidePreload();
			$('#oldComments').show();
			$('#oldComments').html(data_response);			
			
			var count=$(".commentStyle").children('li').size();
			var toApprove = $("li .bt_approve").size();
			
			if (isModerator && count>0 && toApprove >0){				
				$("#approveAll").show();
			}else{
				$("#approveAll").hide();			
			}
			
			if (count>0){
				$('#cm_count').html(count);
			}else{
				$('#cm_count').html("");
			}
			
			if ($.trim(pageHash)!=''){
				window.location.href=pageHash;
			}
			if (scrollAfterAjax){
				goToByScroll(scrollAfterAjax);
			}
			
		},
		error : function(data_response) {
			
			hidePreload();
		}
	});
			
	//initNewComment();
	
	if(getParam('a') != ''){					
			$("#loginResponse").html(getLocalization('recoveryConfirmation'));
			showLoggInDialog();
	}
//    }
}
function getParam(name){
  var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(window.location.href);
  if (results != null && results.length>1){
  	return results[1]; 
  }else{
  	return  "";	
  }  
}

function displayUserAccount() {
	$("#cmt_info").removeClass('textError');
	$("#cmt_info").removeClass('textInfo');	  	
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/checkUser.php",
		data : "check=true&productName=" + productName + "&productVersion=" + productVersion + "&delimiter=|",
		success : function(data_response) {
			
			var response = eval("("+data_response+")");
			isAnonymous=(response.isAnonymous=='true' ? true : false);
			
			showMessage(response);
			if (response.loggedIn == 'true'){
				$("#accountInfo").html(response.name + " [" + response.userName + "]");								
				if (response.level == "admin" || response.level == "moderator") {
				isModerator=true;
					if(isModerator == true){
						if ($("#approveAll").parent().attr('id') != "bt_new") {
							$("#approveAll").appendTo('#bt_new');
						}
						}
					$("#accountInfo").append(" <span class='level'>" + getLocalization("label."+response.level) + "</span>");
				}else{
				isModerator=false;
				}
				if (response.level != "user") {
					$("#accountInfo").append("<span id='adminLink'> <a href='"+conf.htpath+"oxygen-webhelp/resources/admin.html' onclick='setLastPage()'>"+ getLocalization("label.adminPanel")+"</a> </span>");
				}
				
				if(isAnonymous){
					$('#userAccount #show_profile').hide();					
					$('#bt_editProfile').hide();													
					$('#userAccount #bt_logIn').show();
					$('#userAccount #bt_signUp').show();
					$("#loginData").hide();
					$("#o_captcha").show();
				}else{
					$("#o_captcha").hide();
					$('#userAccount #show_profile').show();
					$('#userAccount #bt_logIn').hide();
					$('#userAccount #bt_signUp').hide();
					$('#bt_editProfile').show();
					$("#loginData").hide();
				}
				if (response.minVisibleVersion<=productVersion){
					$('#bt_new').show();					
				}
        showAddNewComment=true;
      //loggin to moderatePost
				if(getParam('l') != ''){					
					$("#loginResponse").html(getLocalization('label.logAdmin'));
					showLoggInDialog();
				}
			} else {	
				$("#accountInfo").html(getLocalization("label.guest") );
				$('#userAccount #show_profile').hide();
				$('#userAccount #bt_logIn').show();
				$('#userAccount #bt_signUp').show();
				$('#newComment').hide();
				if (response.minVisibleVersion<=productVersion){
					$('#bt_new').show();					
				}
        showAddNewComment=false;
			}
		}
	});
}
function showMessage(response){
	if (response.msgType){
		if (response.msgType == 'error'){
			$("#cmt_info").addClass('textError');
			$("#cmt_info").removeClass('textInfo');
		}else{
			$("#cmt_info").removeClass('textError');
			$("#cmt_info").addClass('textInfo');
		}
		$("#cmt_info").html(getLocalization('checkUser.'+response.msg));
	}	
}
function setLastPage(){
    setCookie("backLink", window.location.href, 7);
}

function checkUser(button) {
    debug("checkUser("+button.attr('id')+")");
	// check if user is logged on
	var processLogin = conf.htpath+"oxygen-webhelp/resources/php/checkUser.php";
	
	$("#loginResponse").html("");
	$.ajax({
		type : "POST",
		url : processLogin,
		data : "check=true&productName=" + productName + "&productVersion=" + productVersion + "&delimiter=|",
		success : function(data_response) {
            debug("checkUser.php=",data_response);
			var response=eval('(' + data_response + ')');
			isAnonymous=(response.isAnonymous=='true' ? true : false);
			
			if ($("#newComment").parent().attr('id') != button.attr('id')) {
				$("#newComment").appendTo(button);
			}
			
			//if ($("#signUp").parent().attr('id') != button.attr('id')) {
				//$("#signUp").appendTo(button);
			//}
			if ($("#recoverPwd").parent().attr('id') != button.attr('id')) {
				$("#recoverPwd").appendTo(button);
			}
			
			if (response.loggedIn == 'true'){
				$('#commentTitle').html(getLocalization('newPost'));
				showNewComment();
				refreshEditor();
				$("#commentText").cleditor()[0].clear();
				
			} else {
				isModerator=false;
				$("#signUp").hide();
				$("#recoverPwd").hide();
				
				showLoggInDialog();
					
				//setTimeout("goToByScroll('loginData')",160);
			}
			
		}
	});

}

// reply click
function reply(element, commentId) {
	hideAll();
	setScrollTo(commentId);
	$('#referedCmtId').val(commentId);	
	$('#editedId').val('');
	checkUser($(element).parent());  
	setTimeout("goToByScroll("+commentId+")",100);
}

function showSignUp() {
  debug('showSignUp()');
	$("#loginData").hide();
	$("#recoverPwd").hide();
	$("#u_Profile").hide();
  $("#signUpResponse").html('');
  $("#signUp tbody tr").show();
	document.getElementById('signUp').style.top=$(document).scrollTop()+$(window).height()/2+'px';
	$("#signUp").fadeIn('100');
    showPreload(getLocalization('label.plsWaitUpProfile'));
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/sharedFrom.php",
		data : 'version=' + productVersion,
		success : function(data_response) {
			debug("Share comments from: "+data_response);
			hidePreload();
			if (data_response!=""){
				$('#shareWith').html(data_response);
				$('#shareWith').show();
			}								
		},
		error : function(data_response) {
			hidePreload();
		}
	});
	//setTimeout("goToByScroll('signUp')",100);
}
/**
 * Set scroll to after ajax execution on show comments
 * 
 * @param ids element id to scroll to 
 */
function setScrollTo(ids){
	scrollAfterAjax=ids;
}

function goToByScroll(id){	
  debug("goToByScroll("+id+")");
//	  var el = window.document.getElementById(id);
//	  if (el){
//	  	el.scrollIntoView(true);
//	  }	
      var rowpos = $('#'+id).position();
      // IE
      $('html').scrollTop(rowpos.top);
      // FF Chrome
      $('body').scrollTop(rowpos.top);
}


function showLostPwd() {
	$("#loginData").hide();
	$('#loginResponse').removeClass("textInfo");
	$('#loginResponse').removeClass("textError");
	$("#loginResponse").html("");
	$("#loginResponse").hide();
	document.getElementById('recoverPwd').style.top=$(document).scrollTop()+$(window).height()/2+'px';
	$('#recoverPwdResponse').removeClass("textInfo");
	$('#recoverPwdResponse').removeClass("textError");
	$("#recoverPwdResponse").html("");
	$("#recoverPwdResponse").hide();

	$("#recoverPwd").fadeIn('80');
	//setTimeout("goToByScroll('recoverPwd')",100);
}
function toggleReply(id){
	var currentNode = "li#"+ id;
	$(currentNode + " ul").slideToggle("1000");
	
	if($("#toggle_"+id).attr('class') == 'minus'){
		$("#toggle_"+id).removeClass('minus').addClass('plus');	
	} else{
		$("#toggle_"+id).removeClass('plus').addClass('minus');
	}

}

function showAsk(id){	
	hideAll();
	if ($("#confirmDelete").parent().attr('id') != id) {
		$("#confirmDelete").appendTo("li#" + id + " .head");
		var content= $("#cmt_text_" + id).html();		
		$("#commentToDelete").html(content);
		$("#idToDelete").val(id);
	}
	$("#confirmDelete").show();
	setTimeout("goToByScroll('confirmDelete')",100);
}

function moderatePost(id, action) {
	if (action == 'suspended'){
		toggleReply(id);
	}
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/moderate.php",
		data : "uncodedId=" + id + "&action=" + action + '&product=' + productName + '&version=' + productVersion,
		success : function(data_response) {
			if (data_response != "") {
				setScrollTo(id);
				showComments();
			} else {
				$("#cmt_info").html("Action not performed !");
			}
		}
	});
	return false;
}


function refreshEditor(){	
    
	$("#commentText").cleditor({"width":"98%", "height":"300"});	
	$("#commentText").cleditor()[0].refresh();
	$("#commentText").cleditor()[0].focus();
	var editor=$("#commentText").cleditor()[0];		
  editor.$area.hide();
  editor.$frame.show();
}

function editPost(id){
	hideAll();
	var comment = "#" + id + " div#cmt_text_"+ id;
	var getComment = $(comment).html();
	if ($("#newComment").parent().attr('id') != 'c_'+id) {
		$('#newComment').appendTo("div#c_" + id);
	}
	$('#commentTitle').html(getLocalization('editPost'));
	$('#editedId').val(id);
	$('#referedCmtId').val('');	
	$('#commentText').val(getComment);
	showNewComment();
	refreshEditor();		
	setTimeout("goToByScroll("+id+")",100);
}


function showProfileChange() {
    hideAll();
	$('#u_response').html('');
	$("#u_notify_page").attr('checked', true);
	var dataString = 'select=true' + '&delimiter=|&product=' + productName + '&version=' + productVersion;
	var processLogin = conf.htpath+"oxygen-webhelp/resources/php/profile.php";
	showPreload(getLocalization('label.plsWaitChProfile'));
	$('#u_Profile').show();	
	setTimeout("goToByScroll('u_Profile')",100);  
	$.ajax({
		type : "POST",
		url : processLogin,
		data : dataString,
		success : function(data_response) {
			hidePreload();
			if (data_response != '') {
				var response = eval('('+data_response+')');				
				if (response.isLogged=='true'){
					$("#u_name").val(response.name);
					$("#u_email").val(response.email);
					if (response.notifyPage == 'yes') {
						$("#u_notify_page").attr('checked', true);
					} else {
						$("#u_notify_page").attr('checked', false);
					}
					if (response.notifyReply == 'yes') {
						$("#u_notify_reply").attr('checked', true);
					} else {
						$("#u_notify_reply").attr('checked', false);
					}
					if (response.notifyAll == 'yes') {
						$("#u_notify_all").attr('checked', true);
					} else {
						$("#u_notify_all").attr('checked', false);
					}					
				}				
			} else {
				$('#u_Profile').show();
				$('#u_response').html('').show();
			}
		},
		error : function(data_response) {
			
			hidePreload();
		}
	});
	return false;
}



function readCookie(a) {
	var b = "";
	a = a + "=";
	if (document.cookie.length > 0) {
		offset = document.cookie.indexOf(a);
		if (offset != -1) {
			offset += a.length;
			end = document.cookie.indexOf(";", offset);
			if (end == -1)
				end = document.cookie.length;
			b = unescape(document.cookie.substring(offset, end));
		}
	}
	return b;
}

function setCookie(c_name, value, exdays) {
	var exdate = new Date();
	exdate.setDate(exdate.getDate() + exdays);
	var c_value = escape(value) + ((exdays == null) ? "" : "; expires=" + exdate.toUTCString());
	document.cookie = c_name + "=" + c_value + "; path=/";
}


function eraseCookie(name) {
	setCookie(name,"",-1);
}
/**
* show recover password dialog
*/
		function recover() {
			hideAll();
			var email = $("#recoverEmail").val();
			var username = $("#recoverUser").val();
			var dataString = 'userName=' + username + '&email=' + email + '&product=' + productName + '&version='
					+ productVersion;
			showPreload(getLocalization('label.plsWaitRecover'));
			$('#recoverPwd').hide();
			$.ajax({
				type : "POST",
				url : conf.htpath+"oxygen-webhelp/resources/php/recover.php",
				data : dataString,
				success : function(data_response) {
				  var thisDomain = location.protocol + "//" +  location.host;
					var pageShort = pageWSearch.replace(thisDomain,"");				
					setCookie("page", conf.baseUrl+"?q="+pageShort, 7);
					var response = eval("("+data_response+")");
					
					hidePreload();
					if (response.success == "true"){
						$("#recoverPwd input").attr("type", function(arr) {
							var inputType = $(this).attr("type");
							if (inputType == "text") {
								$(this).val("");
							}
						});
						
						showLoggInDialog();
						$('#loginResponse').addClass("textInfo");
						$("#loginResponse").html(response.message);
						$("#loginResponse").show();
						$('#newComment').hide();
					}else{
						$('#recoverPwd').show();
						$('#recoverPwdResponse').addClass("textError");
						$('#recoverPwdResponse').html(response.message).show();
					}					
				},
				error : function(data_response) {
					hidePreload();
				}
			});
			return false;
		}
		
		/* loggin user */
function loggInUser(){
			
			// process form
			var userName = $("#myUserName").val();
			var password = $("#myPassword").val();
			var rememberMe = "no";
			if ($("#myRemember").is(':checked')) {
				rememberMe = "yes";
			}
			var dataString = '&userName=' + userName + '&password=' + password + "&productName=" + productName + "&productVersion=" + productVersion;

			var processLogin = conf.htpath+"oxygen-webhelp/resources/php/checkUser.php";
			if (userName != '' && password != '') {				
				showPreload(getLocalization("label.plsWaitAuth"));
				$('#loginData').hide();
				$.ajax({
					type : "POST",
					url : processLogin,
					data : dataString,
					success : function(data_response) {
						var response=eval('(' + data_response + ')');
						if (window.location.href != pageWSearch){
							if (response.authenticated == 'false'){
								showLoggInDialog();
								if (response.error){
									var msg=getLocalization('checkUser.loginError');
									msg=msg+"<!--" + response.error + " -->";
									$('#loginResponse').html(msg).show();
								}else{
									$('#loginResponse').html(getLocalization('checkUser.loginError')).show();
								}
							}else{
								if (rememberMe == "yes") {
									var pss = Base64.encode(userName + "|" + password);
									setCookie("oxyAuth", pss, 14);
								}else{
									eraseCookie("oxyAuth");
								}
								$('#loginResponse').html("").hide();
								window.location.href = pageWSearch;
							}
						}else{
							hidePreload();
							if (response.authenticated == 'true'){
								$('#loginResponse').html("").hide();
								if (isAnonymous){
									$('#bt_editProfile').hide();
									$("#o_captcha").show();
								}else{
									$("#o_captcha").hide();
								}
								$('#userAccount #show_profile').show();
								$('#userAccount #bt_logIn').hide();
								$('#userAccount #bt_signUp').hide();
								if ($('#reloadComments').val() == "true") {
									showComments();									
									$('#reloadComments').val("");
									//$('#newComment').hide();
									if (rememberMe == "yes") {
										var pss = Base64.encode(userName + "|" + password);
										setCookie("oxyAuth", pss, 14);
									}else{
										eraseCookie("oxyAuth");
									}
								} else {
									displayUserAccount();
									$('#newComment').show();
									$("#commentText").cleditor();
									$('#commentText').focus();
									setTimeout("goToByScroll('l_bt_submit_nc')",100);
								}
					 		} else {
					 			if (response.error){
									var msg=getLocalization('checkUser.loginError');
									msg=msg+"<!-- " + response.error + " -->";
									$('#loginResponse').html(msg).show();
								}else{
									$('#loginResponse').html(getLocalization('checkUser.loginError')).show();
								}
					 			showLoggInDialog();
							}
						}
					},
					error : function(jqXHR, textStatus, errorThrown) {
						hidePreload();
					}
				});
		}
			//return false; //false or the form will post your data to login.php
			return true; 
		}
function closeDialog(){
	$(this).parent().hide();
	return false;
}		
function showNewCommentDialog() {
  debug("showNewCommentDialog()");
	hideAll();
	setScrollTo('new_comment');
	checkUser($("#new_comment"));
	setTimeout("goToByScroll('l_bt_submit_nc')",100);
	
}

function checkReal() {   
	if (isAnonymous){
    var value = $('.hasRealPerson').val();
		var hash = 5381;
		for (var i = 0; i < value.length; i++) {
			hash = ((hash << 5) + hash) + value.charCodeAt(i);
		}
             
    if (hash==$('.realperson-hash').val()){
        return true;
    };
		return false;	
}else{
	return true;
}
}

function showNewComment(){	
	if (isAnonymous){	
		$(".realperson-regen").click();
		$("#defaultReal").val("");
		$("#defaultReal").html("");
	}
	//$("#newComment").fadeIn('100');		
	$("#newComment").show();
	if (scrollAfterAjax){
		goToByScroll(scrollAfterAjax);
	}
}

function submitComment() {  
}

function postNewComment(){
	if (!checkReal()){
		alert(getLocalization('invalidCode'));
    return false;
  }else{  	
    // captcha
    ////("Captcha " + $('.hasRealPerson').val() );
    
// process form
//var commentNo = $(this).closest('li').attr('id');
var commentNo = $('#referedCmtId').val();
var text = jQuery.trim($("#commentText").val());					
//var text = $("#commentText").val();
var pageWPath=window.location.pathname;
//var dataString = {text: text, page: pageWSearch, comment: commentNo, product: productName,version: productVersion, editedId: $('#editedId').val()};
var dataString = {text: text, page: pageWPath, comment: commentNo, product: productName,version: productVersion, editedId: $('#editedId').val()};

var postComment = conf.htpath+"oxygen-webhelp/resources/php/comment.php";
$('#l_plsWait').html(getLocalization('label.insertCmt'));      
if ((text != '') && (text != '<br>')) {
$.ajax({
	type : "POST",
	url : postComment,
	contentType: "application/x-www-form-urlencoded",
	data : dataString,
	success : function(data_response) {
		var result=data_response.split("|");
		
		if (result[0] == 'Comment not inserted!') {
			$('#cmt_info').html(data_response);
		} else {			
			$('#referedCmtId').val(0);
			setScrollTo(result[1]);
			showComments();
      	if (isAnonymous){
      	  $(".anonymous_post_cmt").remove();
	      $("#bt_new").append("<div class='anonymous_post_cmt'>" + getLocalization('comment.moderate.info') + "</div>");	
          $(".realperson-regen").click();
          $("#defaultReal").val("");
          $("#defaultReal").html("");
        }						
		}
	}
});        
}
$('#l_plsWait').html(getLocalization('label.plsWait'));
return false;
  	return true;
  }
}

function validateEmail(email) { 
  var re =/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}
function validateUserName(name) {   
  var patt=/^[^\W]{3,}$/;
  return patt.test(name);
}
function validatePassword(pswd) {   
  var patt=/^.{5,}$/;
  return patt.test(pswd);
}
function signUpShowInfo(key){
	var info =getLocalization(key);
	var keyInfo=getLocalization(key+'.info');
	if (keyInfo!=key+'.info'){
		info =info + "<br/><div class='info'>"+getLocalization(key+'.info')+"<div>";
	}
	$('#signUpResponse').html(info);				
	$('#signUpResponse').show();
	$('#signUp').show();
}

		function signUp() {
			hideAll();
			// process form
			var userName = $("#myNewUserName").val();
			
			var myName = $("#myName").val();
			var myEmail = $("#myEmail").val();
			var password = $("#myNewPassword").val();
			var password1 = $("#myNewPassword1").val();
			
			
			$("#signUpResponse").css('color','#cc0000');
			if (!validateUserName(userName)){
				signUpShowInfo('signUp.err.6');
			}else if (!validateEmail(myEmail)){
				signUpShowInfo('signUp.err.3');				
			}else if (!validatePassword(password,password1)) {
				signUpShowInfo('pwd.tooShort');				
			}else if (password==password1){
				var dataString = 'userName=' + userName + '&name=' + myName + '&password=' + password + '&email=' + myEmail
						+ '&product=' + productName + '&version=' + productVersion;
				var processLogin = conf.htpath+"oxygen-webhelp/resources/php/signUp.php";
				showPreload(getLocalization('label.plsWaitSignUp'));
				//$('#signUp').hide();
				$.ajax({
					type : "POST",
					url : processLogin,
					data : dataString,
					success : function(data_response) {
						hidePreload();
						$('#signUpResponse').hide();
						var response=eval("("+data_response+")");
						if (response.error == 'false') {
							var thisDomain = location.protocol + "//" +  location.host;
							var pageShort = pageWSearch.replace(thisDomain,"");				
					    setCookie("page", conf.baseUrl+"?q="+pageShort, 7);

							$("#signUp tbody tr").hide();
							$("#signUpResponse").html(getLocalization('checkEmail-signUp'));
							$("#signUpResponse").css('color','#000000');
							

							$('#signUpResponse').append('<div id="bt_close" onclick=$("#signUp").hide();>'+getLocalization('label.close')+'</div>');
							
							//showLoggInDialog();
							$('#newComment').hide();
							$('#signUpResponse').show();
							$('#signUp').show();
						} else {
							showSignUp();
							$("#signUpResponse").css('color','#cc0000');
							$('#signUpResponse').html(getLocalization("signUp.err."+response.errorCode));
							$('#signUpResponse').show();
						}
					},
					error : function(data_response) {
						
						hidePreload();
					}
				});
			} else {
				signUpShowInfo('pwd.repeat');				
			}
			return false;
		}		
function deleteComment() {
	moderatePost($("#idToDelete").val(),"deleted");	
	hideAll();
}		
function hideDeleteDialog() {
	hideAll();	
}		
function hideAll(){
    debug("hideAll()");
    $('#u_Profile').hide();
	$('#preload').hide();
	$('#preload1').hide();
	$('#newComment').hide();
	$('#recoverPwd').hide();
	$('#loginData').hide();
	$('#signUp').hide();
	$("#confirmDelete").hide();
	$('#showConfirmApproveAll').hide();
}
function showApproveAllDialog(){
	hideAll();
	$("#approveInfo").html(getLocalization('approveAllConfirmation'));
	$('#showConfirmApproveAll').show();
	
}		
function approveAllComments(){
	hideAll();
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/moderate.php",
		data : "page=" + pageWSearch + '&product=' + productName + '&version=' + productVersion,
		success : function(data_response) {
			if (data_response != "") {
				showComments();
				$('#showConfirmApproveAll').hide();
			} else {
				$("#approveInfo").html("Action not performed !");
			}
		}
	});
	return false;
}		
function hideAproveDialog() {
	hideAll();
	$("#showConfirmApproveAll").hide();
}		
function showLoggInDialog() {
	hideAll();
	$("#reloadComments").val("true");
	
	var encoded = readCookie("oxyAuth");
	var pss = Base64.decode(encoded);
	var auth = pss.split("|");
	
	$('#myUserName').val(auth[0]);
	$('#myPassword').val(auth[1]);	
	$("#myRemember").attr('checked', (readCookie("oxyAuth")!=""));
	document.getElementById('loginData').style.top=$(document).scrollTop()+$(window).height()/2+'px';
	$('#loginData').show();	
	$("#recoverPwd").hide();
	$("#u_Profile").hide();
	$("#signUp").hide();		
	showPreload(getLocalization('label.plsWaitUpProfile'));
	$.ajax({
		type : "POST",
		url : conf.htpath+"oxygen-webhelp/resources/php/sharedFrom.php",
		data : 'version=' + productVersion,
		success : function(data_response) {
			debug("Share comments from: "+data_response);
			hidePreload();
			if (data_response!=""){
				$('#shareWith').html(data_response);
				$('#shareWith').show();
			}								
		},
		error : function(data_response) {
			hidePreload();
		}
	});
	//setTimeout("goToByScroll('loginData')",160);

	return false;
}
		function updateUserProfile() {
			// alert("data!!! ");
			var name = $("#u_name").val();
			var email = $("#u_email").val();
			var notifyPage = "no";
			var notifyAll = "no";
			var notifyReply = "no";
			if ($("#u_notify_page").is(':checked')) {
				notifyPage = "yes";
			}
			if ($("#u_notify_all").is(':checked')) {
				notifyAll = "yes";
			}
			if ($("#u_notify_reply").is(':checked')) {
				notifyReply = "yes";
			}
			var oldPassword = $("#u_Cpass").val();
			var dataString = 'update=true' + '&name=' + name + '&notifyReply=' + notifyReply + '&notifyAll=' + notifyAll
			+ '&notifyPage=' + notifyPage + '&email=' + email + '&product=' + productName + '&version=' + productVersion 
			+ '&oldPassword=' + oldPassword;
			
			var password = $("#u_pass").val();
			var password1 = $("#u_pass1").val();
			if (password == password1) {
				if (password != '') {
					dataString=dataString+ '&password=' + password;
				}

			var processLogin = conf.htpath+"oxygen-webhelp/resources/php/profile.php";
			if ($("#u_name").val().length < 3) {
				$('#u_response').html("Name to short!").show();
			} else {
				showPreload(getLocalization('label.plsWaitUpProfile'));
				$('#u_response').removeClass('.textError');
				$('#u_response').removeClass('.textInfo');
				$('#u_response').html("");
				$('#u_Profile').hide();	
				$.ajax({
					type : "POST",
					url : processLogin,
					data : dataString,
					success : function(data_response) {
						hidePreload();
						var response = eval('('+data_response+')');						
							if (response.updated!='true'){
								$('#u_Profile').show();
								if (response.msgType=='error'){
									$('#u_response').removeClass('.textInfo');
									$('#u_response').addClass('.textError');
								}else{
									$('#u_response').removeClass('.textError');
									$('#u_response').addClass('.textInfo');
								}
								//$('#u_response').html(data_response + " " + getLocalization('label.changesNotApplied')).show();
								$('#u_response').html(response.msg);
								setTimeout("goToByScroll('u_Profile')",100);
							}else{
								showComments();								
							}					
					},
					error : function(data_response) {

						hidePreload();
					}
				});
			}			
			}else{
				$('#u_response').html(getLocalization('pwd.repeat')).show;
			}
			return false;
		}		 
function loggOffUser() {
	// process form
	var dataString = "&logOff=true&productName=" + productName + "&productVersion=" + productVersion;
	var processLogin = conf.htpath+"oxygen-webhelp/resources/php/checkUser.php";
	$.ajax({
		type : "POST",
		url : processLogin,
		data : dataString,
		success : function(data_response) {
			isModerator=false;
			showComments();
			$("#approveAll").hide();
		}
	});
	resetData();
	return false;
}
function submitForm(formName){	 
	document.forms[formName].submit();
}

function showPreload(text){
	if (text){
		lastPreloadMessage=$('#l_plsWait').html();
		$('#l_plsWait').html(text);
	}else{
    $('#l_plsWait').html(getLocalization('label.plsWait'));
  }
/*
if (commentsPosition==2){  
  document.getElementById('preload').style.top=$(document).scrollTop()+$(window).height()/2+'px';
}else if (commentsPosition==0){
  var p = $("#commentsContainer");
  if (p){
    var offset = p.offset();
    if (offset){
    document.getElementById('preload').style.top=offset.top+$(window).height()/2+'px';
    }
  }
}else if (commentsPosition==1){
  document.getElementById('preload').style.top=$(document).scrollTop()+$(window).height()/2+'px';
}
*/
	$('#cm_count').hide();
	$('#cm_title').hide();
	$('#preload').show();
	
}

function hidePreload(){
	$('#preload').hide();
	$('#cm_count').show();
	$('#cm_title').show();
	if (lastPreloadMessage){
		$('#l_plsWait').html(lastPreloadMessage);
	}
}

var lastCmdLocation=null;
function evaluateCmtPos() {
  var p = $("#commentsContainer");
  if (p){    
    var offset = p.offset();
    if (offset){ 
      if (offset.top<$(document).scrollTop()){
        commentsPosition=2; //full visible  
      }else if (offset.top>($(document).scrollTop()+$(window).height())){
        commentsPosition=0; //invisible
      }else if (offset.top<($(document).scrollTop()+$(window).height())){
        commentsPosition=1; //partial visible
      } 
    }
  }  
}
    
window.onbeforeunload = function() {  
	var text=$('#commentText').val();
	if (text){
		if ((text!="") 
  			&& ($('#commentText').val()!="<br>")
  			&& ($('#commentText').val()!="<p></p>")){		
    	var ss=getLocalization('label.Unsaved');
    	return ss; 
  	}else{
  		//return true;
  	}
	}
};


function float(){
  evaluateCmtPos();
  if (commentsPosition==2){
    document.getElementById('comments').style.top=$(document).scrollTop()+'px';
    document.getElementById('comments').style.position='absolute';
    $(window).css("margin-top","100px");        
  }else{
    document.getElementById('comments').style.top=lastCmdLocation+'px';
    document.getElementById('comments').style.position='static';
  }
  
}

evaluateCmtPos();
$(window).scroll(evaluateCmtPos);

