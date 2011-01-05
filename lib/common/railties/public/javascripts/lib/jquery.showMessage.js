/*global jQuery setTimeout window parent document event clearTimeout */
/*
 * jQuery.showMessage.js 2.1 - jQuery plugin
 * Author: Andrew Alba
 * http://showMessage.dingobytes.com/
 *
 * Copyright (c) 2009-2010 Andrew Alba (http://dingobytes.com)
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * Built for jQuery library
 * http://jquery.com
 *
 * Date: Mon May 06 15:52:00 2010 -0500
 */
(function(a){var c;a.fn.showMessage=function(i){var b=a.extend({thisMessage:[""],className:"notification",position:"top",opacity:90,useEsc:true,displayNavigation:true,autoClose:false,delayTime:5E3,disableClose:false},i);this.each(function(){a("#showMessage",window.parent.document).length&&a("#showMessage",window.parent.document).remove();var d=a("<div></div>").css({display:"none",position:"fixed","z-index":101,left:0,width:"100%",margin:0,filter:"Alpha(Opacity="+b.opacity+")",opacity:b.opacity/100}).attr("id","showMessage").addClass(b.className);
b.position=="top"?a(d).css("top",0):a(d).css("bottom",0);b.useEsc?a(window).keydown(function(h){if((h===null?event.keyCode:h.which)==27){a("#showMessage",window.parent.document).fadeOut();typeof c!="undefined"&&clearTimeout(c)}}):a(window).unbind("keydown");if(b.displayNavigation){var e=a("<span></span>").css({"float":"right","padding-right":"1em","font-weight":"bold","font-size":"small"});b.useEsc&&a(e).html("Esc Key or ");var f=a("<a></a>").attr({href:"",title:"close"}).css("text-decoration","underline").click(function(){if(b.disableClose == false){a("#showMessage",
window.parent.document).fadeOut();clearTimeout(c);return false}}).text("close");a(e).append(f);a(d).append(e)}else if(b.disableClose == false){a(window).click(function(){if(a("#showMessage",window.parent.document).length){a("#showMessage",window.parent.document).fadeOut();a(window).unbind("click");typeof c!="undefined"&&clearTimeout(c)}})};e=a("<div></div>").css({width:"90%",margin:"0em auto",padding:"0.1em"});f=a("<ul></ul>").css({"font-size":"large","font-weight":"bold","margin-left":0,"padding-left":0});for(var g=0;g<b.thisMessage.length;g++){var j=
a("<li></li>").html(b.thisMessage[g]).css({"list-style-image":"none","list-style-position":"outside","list-style-type":"none"});a(f).append(j)}a(e).append(f);a(d).append(e);b.position=="top"?a("body",window.parent.document).prepend(d):a("body",window.parent.document).append(d);a(d).fadeIn();if(b.autoClose){typeof c!="undefined"&&clearTimeout(c);c=setTimeout(function(){a("#showMessage",window.parent.document).fadeOut()},b.delayTime)}})};a.fn.showMessage.closeMessage=function(){if(a("#showMessage",
window.parent.document).length){clearTimeout(c);a("#showMessage",window.parent.document).fadeOut()}}})(jQuery);