class AdminController < ApplicationController
  def admin_login
    
    render layout: false
  end
  
  def admin_signin
    unless Administer.where(username: "#{params[:username]}").take.nil?
      unless Administer.where(username: "#{params[:username]}", password: "#{params[:password]}").take.nil?
        redirect_to '/admin/awesome_4d'
      else
        redirect_to :back
      end
    else
      redirect_to :back
    end
  end
  
  def admin_signout
    redirect_to '/'
  end
  
  def admin_signup
    a = Administer.new
    a.username  = params[:username]
    a.email     = params[:email]
    a.password  = params[:password]
    a.created_at = Time.parse(Time.zone.now.to_s)
    a.updated_at = Time.parse(Time.zone.now.to_s)
    a.save
    redirect_to '/admin/admin_login'
  end
  
  def admin_forgotpwd
    
    redirect_to :back
  end
  
  def profile_about
    
  end
  
  def awesome_4d
    
    # render layout: "../admin_layouts/application.html.erb"
    render layout: false
  end
  
  def index
    
    render layout: "../admin_layouts/application.html.erb"
  end
  
  def songs_info
    @song = Song.all
    @top100 = DailyTjPopularRank.all
    @mod_song = Song.find(params[:mod]) unless params[:mod] == nil
    ### 노래방 번호 또는 지니뮤직 노래번호가 입력되지 않은 노래는
    ### SongController에서 TJ 와 Ginnie 의 노래링크로 저장했으므로
    ### 저장된 링크를 버튼으로 출력하여 이동 후 찾아서 저장하도록 한다.
      @song_miss = Array.new
      @song.each do |song|
        if song.tjnum.length > 10 || song.gininum.length > 10
          @song_miss << song
        end
      end
    
    render layout: "../admin_layouts/application.html.erb"
  end
  
  def gui_vr_info
    @song = Song.all
    
    render layout: "../admin_layouts/application.html.erb"
  end
  
  def list_range
    
    render layout: "../admin_layouts/application.html.erb"
  end
  
  def test #css 개행 도구
    a = ""
    a = a.gsub!("{", "{\n\t").gsub!(";", ";\n\t").gsub!("}", ";\n}\n\r")
    a = "<pre>#{a}</pre>".html_safe
    render text: a
  end
  
end