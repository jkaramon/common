/**
 * CHANGES
 * v.2.1.2 - Fixed bug in which nested fieldsets do not work correctly.
 * v.2.1.1 - Forgot to put the new filter from v.2.1 into the if (settings.closed)
 * v.2.1 - Changed $(this).parent().children().filter( ELEMENTS HERE) to $(this).parent().children().not('label').  Prevents you from having to guess what elements will be in the fieldset.
 * v.2.0 - Added settings to allow a fieldset to be initiated as closed.
 *
 * This script may be used by anyone, but please link back to me.
 *
 * Copyright 2009-2010.  Michael Irwin (http://michael.theirwinfamily.net)
 */

       
$.fn.collapse = function(options) {
  
  var inProgress = false;
	return this.each(function() {
		var obj = $(this);
    var close = i18n.common.close.toUpperCase();
    var open = i18n.common.open.toUpperCase();
		obj.find("div.legend:first").addClass('collapsible').click(function() {
		  if (inProgress && !obj.hasClass('collapsed')) { return; }
			if (obj.hasClass('collapsed'))
				obj.removeClass('collapsed').addClass('collapsible');
			$(this).removeClass('collapsed');
			inProgress = true;
			// Ensure Reset inProgress after some time 
			window.setTimeout(function() { inProgress = false; }, 2000);
	    
	    obj.find('ol:first').toggle("slow", function() {
	      // Reset inProgress after some time 
	      window.setTimeout(function() { inProgress = false; }, 400);
			  if ($(this).is(":visible")) {
					obj.find("div.legend:first").addClass('collapsible');
					obj.find('.excerpt').css('display', 'none');
          obj.find('.collapse-state-text').html(close);
				}
				else {
				  obj.addClass('collapsed').find("div.legend").addClass('collapsed');
			    obj.find('.excerpt').css('display', 'inline-block');
          obj.find('.collapse-state-text').html(open);
			  }
			 });
		});
		if (obj.hasClass('collapsed')) {
			obj.addClass('collapsed').find("div.legend:first").addClass('collapsed');
			obj.find('ol:first').css('display', 'none');
			obj.find('.excerpt').css('display', 'inline-block');
      obj.find('.collapse-state-text').html(open);
		}
		else {
		  obj.find('.excerpt').css('display', 'none');
      obj.find('.collapse-state-text').html(close);
		}
		
	});
};
