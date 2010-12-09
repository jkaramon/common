/*global jQuery */

(function($) {
  
  $.extend({
    animated_ajax: function(settings, anim_settings) {
      var anim_config = {elem : "body", message: "Please wait"};
      $.extend(anim_config, anim_settings);
      $.loadanim.start(anim_config);
      if(!settings.complete)
        settings.complete = function(){
          $.loadanim.stop(anim_config);
        }

      return $.ajax(settings);
    },

    animated_put: function(url, data, type, anim_settings, callback) {
      return jQuery.animated_ajax({
        type: "PUT",
        url: url,
        data: data,
        success: callback,
        dataType: type
      }, anim_settings);
    },

    // delete is a reserved word, so appending an underscore
    animated_delete_: function(url, data, type, anim_settings, callback) {
      
      return jQuery.animated_ajax({
        type: "DELETE",
        url: url,
        data: data,
        success: callback,
        dataType: type
      }, anim_settings);
    },

    animated_get: function(url, data, type, anim_settings, callback) {
      return jQuery.animated_ajax({
        type: "GET",
        url: url,
        data: data,
        success: callback,
        dataType: type
      }, anim_settings);
    },

    animated_post: function(url, data, type, anim_settings, callback) {
      return jQuery.animated_ajax({
        type: "POST",
        url: url,
        data: data,
        success: callback,
        dataType: type
      }, anim_settings);
    }
  });

})(jQuery);
