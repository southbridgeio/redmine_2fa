class BaseProtocol
  def second_step_partial
    'account/otp'
  end

  def initial_partial
    "account/init_2fa/#{id}"
  end

  def send_code(_user); end

  def id
    raise NotImplementedError
  end
end
