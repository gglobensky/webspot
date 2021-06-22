class TagsController < ApplicationController
    include JwtProcessToken
    respond_to :json
    before_action :process_token

    def interests
        message = InterestTag.all.as_json(only: [:name])
        render json: { status: 'success', message: message }
    end
end