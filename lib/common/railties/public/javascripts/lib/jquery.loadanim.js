/*
 *
 * Loading Animation
 * Author: Matus Nickel <matus.nickel@gmail.com>
 * 
 */

var version = 1.0;
//var started = false;
var started = {};

jQuery.loadanim = {

    start : function (options) {
        var defaults = {
            elem: 'body',
            message: "Loading...<br /> Please wait"
        };
        var options = $.extend(defaults, options);
        started[options.elem] = started[options.elem] || 0;
        started[options.elem]++;
        
        if (started[options.elem] == 1) {
          if($(options.elem).height() < 45) {
            $(options.elem).block({
              message: '<div style="height:'+ ($(options.elem).height()-20)+'px; "><img src="/images/ajax-loader.gif" style="height: 100%;"><b>'+options.message+'</b></div>',
              css: { border: '3px solid #b0bb24', padding: '5px' }
            });
          } else {
            $(options.elem).block({
              message: '<img src="/images/ajax-loader.gif" ><br /><b>'+options.message+'</b>',
              css: { border: '3px solid #b0bb24', padding: '5px' }
            });
          }
        }
        //started[options.elem] = true;
    },
    
    stop : function (options) {
        
        var defaults = {
            elem: 'body'
        };
        var options = $.extend(defaults, options);

        started[options.elem] = started[options.elem] || 1;
        started[options.elem]--;

        if (started[options.elem]==0) {
          $(options.elem).unblock();
        }
    }
};

