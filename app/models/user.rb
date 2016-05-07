class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :omniauthable, :omniauth_providers => [:facebook]

    # Devise의 RegistrationsControoler는 기본으로 "User.new_with_session"을 호출한다.
    # 페이스북 로그인을 할 경우 아래 코드를 추가해주어야 한다.

    def self.from_omniauth(auth)
        where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
            user.email = auth.info.email
            user.password = Devise.friendly_token[0,20]
            user.name = auth.info.name  # assuming the user model has a name
            # user.image = auth.info.image # assuming the user model has an image
        end
    end

    # 페이스북 유저가 처음 로그인 했을 때
    def self.new_with_session(params, session)
        super.tap do |user|
            if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
                # user.email = data["email"] if user.email.blank? << 기존 코드
                user.email = data["email"]
                user.name = data["name"]
                user.id = data["id"]
                user.password = Devise.friendly_token[0,20]
                user.save
            end
        end
    end


end
