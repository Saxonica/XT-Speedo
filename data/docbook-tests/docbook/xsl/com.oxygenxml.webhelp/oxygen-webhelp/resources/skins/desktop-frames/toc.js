/*

Oxygen Webhelp plugin
Copyright (c) 1998-2013 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

*/

var wh=parseUri(window.location);
var whUrl=wh.protocol+'://'+wh.host+wh.directory;           
var lastLoadedPage="";
var noFoldableNodes=0;

/**
 *  Get the localized string for the specified key.
 */
function getLocalization(localizationKey) {
	if (localization[localizationKey]){
		return localization[localizationKey];
	}else{
		return localizationKey;
	}
}
/**
 * Hide and show div-s
 */
 
function showMenu(displayTab){
    parent.termsToHighlight = Array();
    var contentLinkText = getLocalization("Content");
    var searchLinkText = getLocalization("Search");
    var indexLinkText = getLocalization("Index");
    var tabs = document.getElementById('tocMenu').getElementsByTagName("div");
    for (var i = 0 ; i < tabs.length; i++){
        var currentTabId = tabs[i].id;
        // generates menu tabs        
        document.getElementById(currentTabId).innerHTML = '<span onclick="showMenu(\'' + currentTabId + '\')">' + eval(currentTabId + "LinkText") + '</span>';
        
        // show selected block
        selectedBlock = displayTab + "Block";
        if (currentTabId == displayTab){
            document.getElementById(selectedBlock).style.display = "block";
            $('#' + currentTabId).addClass('selected');
        } else  {
            document.getElementById(currentTabId + 'Block').style.display = "none";
            $('#' + currentTabId).removeClass('selected');
         }   
    }
	if (displayTab == 'content') {        
      if (lastLoadedPage!=""){
        expandToTopic(parent.contentwin.location.href);        
      }
    }
   
    if (displayTab == 'search') {
        $('.textToSearch').focus();
    }
    if (displayTab == 'index') {
        $('#id_search').focus();
    }
  //  $('*', window.parent.contentwin.document).unhighlight();
} 

 
function hideDiv(hiddenDiv,showedDiv){   
    parent.termsToHighlight = Array();
    document.getElementById(hiddenDiv).style.display = "none";
    document.getElementById(showedDiv).style.display = "block";
    var contentLinkText = getLocalization("Content");
    var searchLinkText = getLocalization("Search");
    
	if (hiddenDiv == 'searchDiv') {
		document.getElementById('divContent').innerHTML = '<font class="normalLink">' + contentLinkText + '</font>';
		document.getElementById('divSearch').innerHTML = '<a href="javascript:void(0);" class="activeLink" id="searchLink" onclick="hideDiv(\'displayContentDiv\',\'searchDiv\')">' + searchLinkText + '</a>';
        expandToTopic(window.location.href);
    } else {
		document.getElementById('divContent').innerHTML = '<a href="javascript:void(0);" class="activeLink" id="contentLink" onclick="hideDiv(\'searchDiv\',\'displayContentDiv\')">' + contentLinkText + '</a>';
		document.getElementById('divSearch').innerHTML = '<font class="normalLink">' + searchLinkText + '</font>';
	}
    
  //  $('*', window.parent.contentwin.document).unhighlight();
}

/**
 * Opens a page (topic) file and highlights a word from it.
 */
function openAndHighlight(page, words, linkName){
    var links = document.getElementsByTagName('a');
    for (var i = 0 ; i < links.length ; i++){
        if (links[i].id == linkName ){
            document.getElementById(linkName).className = 'otherLink';
        } else if (startsWith(links[i].id, 'foundLink')) {
            document.getElementById(links[i].id).className = 'foundResult';
        }
    }
    
	parent.termsToHighlight = words;
	parent.frames['contentwin'].location = page;	
}


function stripUri(uri){
  var toReturn="";
      
  var ret=new Array();
  if (typeof uri !=="undefined"){
  var bar = uri.split("/");
  var reti=-1;
  var i=bar.length;
  for (var i=bar.length; i>0; i--){
    if (bar[i]=='..'){          
      for (var j=i-1; j>0; j--){
        if (bar[j]!='..' && bar[j]!=''){
          bar[j]='';
          bar[i]='';
          break;
        }
      }
    }
  }
  for(var i=0;i<bar.length;i++){
    if (bar[i]!=''){
      toReturn=toReturn+bar[i];
      if (i<bar.length-1){
        toReturn=toReturn+'/';
      }
    }else{
      if (i==0){
        toReturn=toReturn+'/';
      }
    }
  }
}
  log.info('stripUri('+uri+')='+toReturn);
  return toReturn;
}           
function normalizeLink(origLink){   
  log.info('normalizeLink(',origLink);
  if (origLink!=""){
  var relLink=origLink;
  var logStr='';  
  if (!$.support.hrefNormalized){
    var relp=window.location.pathname.substring(0,window.location.pathname.lastIndexOf('/'));
    //ie7
    logStr=' IE7 ';
    var srv=window.location.protocol+'//'+window.location.hostname;    
    var localHref=parseUri(origLink);
              
    if (window.location.protocol.toLowerCase()!='file:' 
      && localHref.protocol.toLowerCase()!=''){            
      log.debug('ie7 file://');
      relLink=origLink.substring(whUrl.length);
    }
  }else{
    if (startsWith(relLink, whUrl)){
      relLink=relLink.substr(whUrl.length);
    }
  }
  var toReturn=stripUri(relLink);
  log.info(logStr+'normalizeLink('+origLink+')='+toReturn);
  return toReturn;
  }else{
    log.info(logStr+'normalizeLink('+origLink+')='+"\"\"");
  return "";
  }
}

function expandToTopic(url){
  log.debug('expandToTopic(',url);
  url=normalizeLink(url);
  var parent="";
  var getAux = false;
 
  if($.cookie("wh_pn")!="undefined" && $.cookie("wh_pn") && $.cookie("wh_pn")!=""){
    var sibblings=JSON.parse($.cookie("wh_pn"));
    parent=sibblings[1];
    getAux=sibblings[1]!=""?true:false;
  }
  
  if (startsWith(url, '../')){
    url=url.substr(url.lastIndexOf('../')+3);
  }
  
  var relp=window.location.pathname.substring(0,window.location.pathname.lastIndexOf('/'));
  log.debug('relp:'+relp);
  var toFind=url;
    log.debug('expandToTopic('+toFind+') - loaded');
    var loc='#contentBlock a[href^="'+toFind+'"]';
    if (getAux){
        var aux=$('#contentBlock a[href^="'+parent+'"]').closest("li");
        var auxLoc=$(aux).find('a[href^="'+toFind+'"]');
    }
    log.info('search:'+toFind);  
     if (lastLoadedPage!=""){
      // not first load
      if (getAux){
       toggleItem($(auxLoc).parent(),true);
      } else {
       toggleItem($(loc).parent(),true);
      }
    }    
    lastLoadedPage=url;
    $('#contentBlock li span').removeClass('menuItemSelected');
    
    if (getAux){
            var item=$(auxLoc);
        } else {
            var item=$(loc);
        }
    showParents();
    item.parent('li span').addClass('menuItemSelected');
}
function redirect(link){
  log.debug('redirect('+link+');');
  window.parent.contentwin.location.href = link;
}
function showHideExpandButtons(){
  if (noFoldableNodes>0){
    if (BrowserDetect.browser='Explorer' && BrowserDetect.version<8){
      //debug('IE7');
      $('#expandAllLink').show();
      $('#collapseAllLink').show();
    }else{
      if ($('#tree > ul li > span.hasSubMenuOpened').size() != noFoldableNodes){
        $('#expandAllLink').show();
      }else{
        $('#expandAllLink').hide();
      }
      if ($('#tree > ul > li > span.hasSubMenuOpened').size()<=0){
        $('#collapseAllLink').hide();
      }else{
        $('#collapseAllLink').show();
      }
    }
  }else{
    $('#expandAllLink').hide();
    $('#collapseAllLink').hide();
  }
}

function showParents(){    
        if($.cookie("wh_pn")!="" && $.cookie("wh_pn")!="undefined" && $.cookie("wh_pn")!=null){
            var sibblings=JSON.parse($.cookie("wh_pn"));
            var parent=sibblings[1];
            var next=(sibblings[2]!=null && sibblings[2]!='undefined')?sibblings[2]:"";
            var prev=(sibblings[0]!=null && sibblings[0]!='undefined')?sibblings[0]:"";
            
            var navLinks = top.frames["contentwin"].document.getElementsByClassName('nav');
            var parentSpan=$(navLinks).find('.navheader .navparent a[href*="'+parent+'"]').length;
            var nextSpan=$(navLinks).find('.navheader .navnext a[href*="'+next+'"]').length;
            var prevSpan=$(navLinks).find('.navheader .navprev a[href*="'+prev+'"]').length;
            
            if(parentSpan!=0) {
              $(navLinks).find('.navheader .navparent').hide();
              $(navLinks).find('.navheader .navparent a[href*="'+parent+'"]').parent().show();
            }
            if(prevSpan!=0) {
              $(navLinks).find('.navheader .navprev').hide();
              $(navLinks).find('.navheader .navprev a[href*="'+prev+'"]').parent().show();
            } else {
              $(navLinks).find('.navheader .navprev').hide();
              $(navLinks).find('.navheader .navprev a[href*="'+parent+'"]').parent().show();
            }
            if(nextSpan!=0) {
              $(navLinks).find('.navheader .navnext').hide();
              $(navLinks).find('.navheader .navnext a[href*="'+next+'"]').parent().show();
            } else {
              $(navLinks).find('.navheader .navnext').hide();
            }
            $.cookie("wh_pn","");
        }
}

function expandAll(){
  $('#contentBlock li ul').parent().find('>span').removeClass('hasSubMenuClosed');
  $('#contentBlock li ul').parent().find('>span').addClass('hasSubMenuOpened');
  $('#contentBlock li ul').show();
  showHideExpandButtons();
  return false;
}    
function collapseAll(){
  $('#contentBlock li ul').parent().find('>span').removeClass('hasSubMenuOpened');
  $('#contentBlock li ul').parent().find('>span').addClass('hasSubMenuClosed');
  $('#contentBlock li ul').hide();
  showHideExpandButtons();
  return false;
}  
  function toggleItem(loc,forceOpen){
  log.debug('toggleItem('+loc.prop("tagName")+', '+forceOpen+')');
  $(loc).parent().parents('#contentBlock li').find('>span').addClass('hasSubMenuOpened');
  $(loc).parent().parents('#contentBlock li').find('>span').removeClass('hasSubMenuClosed');
  if (loc.hasClass('hasSubMenuOpened') && !(forceOpen==true)){
    if ($(loc).parent().find('>ul').size()>0){
      $(loc).removeClass('hasSubMenuOpened');    
      $(loc).addClass('hasSubMenuClosed');
      $(loc).parent('#contentBlock li').find('>ul').hide();
    }
  }else{
    if ($(loc).parent().find('>ul').size()>0){
      $(loc).addClass('hasSubMenuOpened');    
      $(loc).removeClass('hasSubMenuClosed');        
      $(loc).parent('#contentBlock li').find('>ul').show();
    }
    $(loc).parent().parents('#contentBlock li').find('>ul').show();
  }
 showHideExpandButtons();
}
 
  
$(document).ready(function(){
$('#contentBlock li a').each(function(){
    var old=$(this).attr('href');         
    if (old=='javascript:void(0)'){          
      $(this).attr('href','#!_'+$(this).text());
    }else{
      $(this).attr('href',normalizeLink(old));
      log.info('alter link:'+$(this).attr('href')+' from '+old);
    }
  });
  
  $('#contentBlock li>span').click(function (){
    toggleItem($(this));
  })
            
  $('#contentBlock li a').click(function(){
    toggleItem($(this).parent(),true);
    if ($(this).attr('href').indexOf('#!_')==0){
        // do nothing
        toggleItem($(this));
      }else{
        $('#contentBlock li span').removeClass('menuItemSelected');
        $(this).parent('li span').addClass('menuItemSelected');
        var parentNode = $(this).closest('ul').prev().find('a').attr("href");
        var prevNode = $(this).closest('li').prev().find('a').attr("href");
        var nextNode = $(this).closest('li').next().find('a').attr("href");
        
        parentNode=(parentNode != 'undefined' && parentNode != null)?parentNode:"";
        nextNode=(nextNode != 'undefined' && nextNode != null)?nextNode:"";
        prevNode=(prevNode != 'undefined' && prevNode != null)?prevNode:"";
        var nephews = $(this).closest('li').prev().find('ul').children();
        
        if(nephews.length>0){
           prevNode=nephews.last().find('a').attr('href');
        }
        
        if(prevNode==""){
            prevNode=parentNode;
        }
        
        var children = $(this).closest('li').find('ul').first('li');
        if(children.length>0){
          nextNode=children.find('a').attr('href');
        }
            
        if(nextNode=="" && parentNode!=""){
            nextNode=$(this).closest('ul').closest('li').next().find('span a').attr("href");
        }
        // prev, parent, next
        var sibblings = [prevNode, parentNode, nextNode];
        var str = JSON.stringify(sibblings);
        $.cookie('wh_pn', str);
        redirect($(this).attr('href'));
      }
    return false;
  });  
        
  $('#contentBlock li>span').each(function(){
    if ($(this).parent().find('>ul').size()>0){
      $(this).addClass('hasSubMenuClosed');
    }else{
      $(this).addClass('topic');
    }                    
  })
  log.info('loaded!..');
  $('#preload').hide();
  log.debug('discover foldables '+$('#tree > ul li > span').size()+' - '+$('#tree > ul li > span.topic').size());
  noFoldableNodes=$('#tree > ul li > span').size()-$('#tree > ul li > span.topic').size();
  showHideExpandButtons();
  $('#expandAllLink').attr('title', getLocalization("ExpandAll"));
  $('#collapseAllLink').attr('title', getLocalization("CollapseAll"));
  });
 $.fn.highlightContent = function(what,spanClass) {
    return this.each(function(){
        var container = this,
            content = container.innerHTML,
            pattern = new RegExp('(>[^<.]*)(' + what + ')([^<.]*)','g'),
            replaceWith = '$1<span ' + ( spanClass ? 'class="' + spanClass + '"' : '' ) + '">$2</span>$3',
            highlighted = content.replace(pattern,replaceWith);
        container.innerHTML = highlighted;
    });
}