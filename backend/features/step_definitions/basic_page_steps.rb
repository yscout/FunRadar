When('I GET the root path') do
  get '/'
  @last_response_status = last_response.status
  @last_response_body = last_response.body
end
