module AuthenticationHelpers
  def sign_in(user)
    session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    Current.session = session
    cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
  end

  def sign_out
    Current.session&.destroy
    Current.session = nil
    cookies.delete(:session_id)
  end

  def current_user
    Current.user
  end
end
