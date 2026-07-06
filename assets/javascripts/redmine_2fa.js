function copyTotpSecret(button) {
  var secret = button.getAttribute('data-totp-secret'),
      copiedLabel = button.getAttribute('data-copied-label'),
      originalLabel = button.innerHTML;

  function showCopied() {
    button.innerHTML = copiedLabel;
    setTimeout(function () {
      button.innerHTML = originalLabel;
    }, 2000);
  }

  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(secret).then(showCopied);
  } else {
    // Fallback for browsers without the async Clipboard API: select the
    // secret element itself and copy the current selection.
    var secretEl = document.getElementById('totpSecret'),
        selection = window.getSelection(),
        range = document.createRange();
    range.selectNodeContents(secretEl);
    selection.removeAllRanges();
    selection.addRange(range);
    if (document.execCommand('copy')) {
      showCopied();
    }
    selection.removeAllRanges();
  }
}

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
