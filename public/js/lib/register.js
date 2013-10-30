// Generated by CoffeeScript 1.6.3
(function() {
  var checkExists;

  checkExists = function(field, value) {
    var data, helpContainer, thisDiv;
    data = {};
    data[field] = value;
    helpContainer = $('#' + field).parent().find('span');
    thisDiv = $('#' + field).parents('.control-group');
    $.ajax({
      url: '/checkExists',
      type: 'GET',
      data: data
    }.done(reply)(function() {
      var callback;
      helpContainer.text('That ' + field + ' is available!');
      thisDiv.addClass('success');
      callback = function() {
        thisDiv.removeClass('success');
        helpContainer.text('');
      };
      setTimeout(callback, 1000);
      return true;
    }).fail(xhr, err)(function() {
      if (xhr.status === 409) {
        thisDiv.addClass('error');
        helpContainer.text('Oops! That ' + field + ' is already taken!');
        $('#' + field).focus();
      } else {
        thisDiv.addClass('error');
        helpContainer.text('Something went wrong, please try again.');
        $('#' + field).focus();
      }
      return false;
    }));
  };

  $(function() {
    $(':input[required]').change(function() {
      var inputCount, readyToGo, thisField;
      thisField = $(this).attr('name');
      console.log(thisField);
      readyToGo = true;
      if (thisField === 'username') {
        $(this).parents('.control-group').removeClass('error');
        readyToGo = checkExists('username', $(this).val());
      } else if (thisField === 'email') {
        $(this).parents('.control-group').removeClass('error');
        readyToGo = checkExists('email', $(this).val());
      }
      inputCount = $(':input[required]').length;
      $(':input[required]').each(function(i) {
        if ($(this).val() === '') {
          readyToGo = false;
        }
        if ($(this).parents('.control-group').hasClass('error')) {
          readyToGo = false;
        }
        if (i === (inputCount - 1)) {
          if (readyToGo) {
            $(':submit').removeAttr('disabled').focus();
          } else {
            $(':submit').attr('disabled', true);
          }
        }
      });
    });
  });

}).call(this);
