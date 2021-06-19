class CustomFailureApp < Devise::FailureApp
    def respond
      if request.format == :json
        json_error_response
      else
        super
      end
    end
  
    def json_error_response
      self.status = 200
      self.content_type = "application/json"
      msg = i18n_message.to_json
      self.response_body = { status: "error", message: i18n_message }.to_json
    end
  end