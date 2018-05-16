class JwtAuthController < AccountController
  def issue_token
    user = User.find(params[:user_id])

    (render_403 && return) if user.anonymous?

    payload = { id: user.id, iss: issuer }
    token = JWT.encode(payload, secret)

    jwt_issue_strategy.call(token, user)
  end

  def check
    payload, header = JWT.decode(params[:token], secret, true, algorithm: 'HS256', iss: issuer, verify_iss: true)
    user = User.find(payload['user_id'])
    if user.logged?
      successful_authentication(user)
    else
      render_403
    end
  rescue JWT::DecodeError
    render_401
  rescue JWT::ExpiredSignature, JWT::InvalidIssuerError, JWT::InvalidIatError
    render_403
  end

  private

  def render_401(options = {})
    @project = nil
    render_error(message: :notice_not_authorized, status: 401, **options)
    false
  end

  def secret
    Rails.application.config.secret_key_base
  end

  def issuer
    Setting.host_name
  end

  def jwt_issue_strategy
    Redmine2FA::JWT.strategies[params[:strategy]]
  end
end
