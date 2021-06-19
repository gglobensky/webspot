require 'jwt_process_token'
class DirectUploadsController < ActiveStorage::DirectUploadsController
    include JwtProcessToken
    protect_from_forgery with: :exception
    skip_before_action :verify_authenticity_token
    before_action :process_token

    def create
        @avatar = current_user.avatar
        @avatar.purge_later
        blob = ActiveStorage::Blob.create_before_direct_upload!(filename: blob_args[:filename], byte_size: blob_args[:byte_size], checksum: blob_args[:checksum], content_type: blob_args[:content_type], metadata: blob_args[:metadata])
        respond_to do |format|
            format.html { redirect_to authenticated_root_path }
            format.json { render json: direct_upload_json(blob) }
        end
    end

    def direct_upload_json(blob)
        blob.as_json(root: false, methods: :signed_id).merge(service_url: url_for(blob)).merge(direct_upload: {
            url: blob.service_url_for_direct_upload,
            headers: blob.service_headers_for_direct_upload
        })
    end

    private

    def current_user
        User.find(@current_user_id)
    end




end