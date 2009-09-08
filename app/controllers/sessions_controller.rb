require 'openid'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'
class SessionsController < ApplicationController
  def new
  end

  def create
    # let's take the openid_identifier and go through the process
    # session[:user_id] =

    start
    
    #respond_to do |format|
    #    #flash[:notice] = 'Content was successfully created.'
    #    #format.html { render :partial => @comment }
    #end
  end

  def destroy
    reset_session

    flash[:notice] = "You're now logged out. kthxbai!"
    respond_to do |format|
      format.html { redirect_to(root_url) }
    end
  end

  def start
    begin
      identifier = params[:openid_identifier]
      if identifier.nil?
        flash[:error] = "Enter an OpenID identifier"
        redirect_to :action => 'new'
        return
      end
      oidreq = consumer.begin(identifier)
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for #{identifier}: #{e}"
      redirect_to :action => 'new'
      return
    end

    #if params[:use_sreg]
      sregreq = OpenID::SReg::Request.new
      # required fields
      sregreq.request_fields(['email', 'nickname'], true)
      # optional fields
      # sregreq.request_fields(['dob', 'fullname'], false)
      oidreq.add_extension(sregreq)
      oidreq.return_to_args['did_sreg'] = 'y'
    #end
    if params[:use_pape]
      papereq = OpenID::PAPE::Request.new
      papereq.add_policy_uri(OpenID::PAPE::AUTH_PHISHING_RESISTANT)
      papereq.max_auth_age = 2*60*60
      oidreq.add_extension(papereq)
      oidreq.return_to_args['did_pape'] = 'y'
    end
    if params[:force_post]
      oidreq.return_to_args['force_post']='x'*2048
    end
    return_to = complete_sessions_url
    realm = root_url

    if oidreq.send_redirect?(realm, return_to, params[:immediate])
      redirect_to oidreq.redirect_url(realm, return_to, params[:immediate])
    else
      render :text => oidreq.html_markup(realm, return_to, params[:immediate], {'id' => 'openid_form'})
    end
  end

  def complete
    # FIXME - url_for some action is not necessarily the current URL.
    current_url = complete_sessions_url
    logger.info params.inspect
    parameters = params.reject{|k, v|request.path_parameters[k]}
    oidresp = consumer.complete(parameters, current_url)
    case oidresp.status
      when OpenID::Consumer::FAILURE
        if oidresp.display_identifier
          flash[:error] = ("Verification of #{oidresp.display_identifier}"\
                         " failed: #{oidresp.message}")
        else
          flash[:error] = "Verification failed: #{oidresp.message}"
        end
      when OpenID::Consumer::SUCCESS
        flash[:success] = ("Verification of #{oidresp.display_identifier}"\
                         " succeeded.")
          sreg_resp = OpenID::SReg::Response.from_success_response(oidresp)
          sreg_message = "Simple Registration data was requested"
          if sreg_resp.empty?
            sreg_message << ", but none was returned."
          else
            sreg_message << ". The following data were sent:"
            sreg_resp.data.each {|k, v|
              sreg_message << "<br/><b>#{k}</b>: #{v}"
            }
          end
          flash[:sreg_results] = sreg_message
        if params[:did_pape]
          pape_resp = OpenID::PAPE::Response.from_success_response(oidresp)
          pape_message = "A phishing resistant authentication method was requested"
          if pape_resp.auth_policies.member? OpenID::PAPE::AUTH_PHISHING_RESISTANT
            pape_message << ", and the server reported one."
          else
            pape_message << ", but the server did not report one."
          end
          if pape_resp.auth_time
            pape_message << "<br><b>Authentication time:</b> #{pape_resp.auth_time} seconds"
          end
          if pape_resp.nist_auth_level
            pape_message << "<br><b>NIST Auth Level:</b> #{pape_resp.nist_auth_level}"
          end
          flash[:pape_results] = pape_message
        end

        # hey, we should do the login here

        # first let's see if the user is created already

        openid_identity = params[:openid1_claimed_id] || params['openid.identity']
        @user = User.by_openid(:key => openid_identity)

        logger.info "USER: #{params.inspect}"
        logger.info "USER: #{@user.inspect}"

        if @user.size == 0
          # create the user
          @user = User.new(:openid => openid_identity,
            :username => params['openid.sreg.nickname'] || "no username",
            :display_name => params['openid.sreg.nickname'] || 'no display name',
            :email => params['openid.sreg.email'] || "no email",
            :type => "user"
          )
          logger.info "USER222: #{@user.inspect}"
          @user.save
        else
          @user = @user[0]
        end

        session[:user_id] = @user.id

        flash[:success] = "It worked! You're in."
        if @user.display_name == 'no username'
          flash[:success] = "#{flash[:success]} BUT, we need to enter a nickname, and if you need us to get in touch with you, please leave an email address as well."
          redirect_to edit_sessions_path
          return true
        end  
        if session[:return_to]
          redirect_to session[:return_to]
          session[:return_to] = nil
          return true
        end
      
      when OpenID::Consumer::SETUP_NEEDED
        flash[:alert] = "Immediate request failed - Setup Needed"
      when OpenID::Consumer::CANCEL
        flash[:alert] = "OpenID transaction cancelled."
      else
    end
    redirect_to root_url
  end

  def edit
  end

  def update
    respond_to do |format|
      if current_user.update_attributes(params[:user])
        flash[:notice] = 'Your details were successfully updated.'
        format.html do
          if session[:return_to]
            redirect_to(session[:return_to]) 
          else
            redirect_to(edit_sessions_path) 
          end
        end
      else
        format.html { render :action => "edit" }
      end
    end
  end

  private

  def consumer
    if @consumer.nil?
      dir = Pathname.new(RAILS_ROOT).join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end

end
