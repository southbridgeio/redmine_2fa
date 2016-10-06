function startOtpTimer() {
  var duration = 30,
      display = document.querySelector('#otpCodeResendTimer'),
      timer = duration,
      seconds,
      nIntervId;

  $('#otpCodeResendLink').hide();
  $('#otpCodeResentInstruction').show();

  nIntervId = setInterval(function () {

    seconds = parseInt(timer, 10);

    display.textContent = seconds;

    if (--timer < 0) {
      $('#otpCodeResendLink').show();
      $('#otpCodeResentInstruction').hide();
      display.textContent = duration;
      clearInterval(nIntervId);
    }
  }, 1000);
}

$(document).ready(function () {
  $('#ignore_2fa').change(
      function () {
        if ($(this).is(':checked')) {
          $('.instruction2FA').hide();
          $('input:radio[name="auth_source_id"]').prop('checked', false);
          $('#init2FAFormAuthSources').hide();
          $('#init2FAFormSubmitRow').show();
        } else {
          $('#init2FAFormAuthSources').show();
          $('#init2FAFormSubmitRow').hide();
        }
      });

  $('input:radio[name="auth_source_id"]').change(
      function () {
        if ($(this).is(':checked')) {
          console.log($(this));
          var protocol = $(this).data('protocol');
          $('.instruction2FA').hide();
          $('.' + protocol + 'Instruction').show();
        }
      });

  $('.next2FAStep input[type=submit]').on("click", function () {
    $('#init2FAForm').submit();
  });
});

