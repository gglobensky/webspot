module JwtProcessToken
    def process_token
        if request.headers['Authorization'].present?
            begin
                jwt_payload = JWT.decode(request.headers['Authorization'].split(' ')[0].remove('"'), Rails.application.secrets.secret_key_base).first
                @current_user_id = jwt_payload['id']
            rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
                head :unauthorized
            end
        end
    end

end