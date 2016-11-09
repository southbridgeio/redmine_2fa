function startOtpTimer() {
  var duration = 30,
      display = document.querySelector('#otpCodeResendTimer'),
      timer = duration,
      seconds,
      nIntervId;

  $('#otpCodeResendLink').hide();
  $('#otpCodeResentInstruction').show();

  nIntervId = setInterval(function() {

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
