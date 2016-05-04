class CrawlController < ApplicationController
  def tj_monthly_new
  end

  def tj_monthly_popular
  end

  def tj_daily_popular

    #-----------------------------------------------------------------------------------------------------
    # Parameter Mapping(TJ와 같은 방식으로) : 설정기간 {'언제부터' '언제까지' 기간 중에 인기 Top100 보기}
    ## 언제부터
    @syy = params[:syy]
    @smm = params[:smm]
    @sdd = params[:sdd]
    
    ## 언제까지
    @eyy = params[:eyy]
    @emm = params[:emm]
    @edd = params[:edd]
    #-----------------------------------------------------------------------------------------------------
    
    # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
    uri = URI("http://m.tjmedia.co.kr/tjsong/song_Popular.asp?SYY=#{@syy}&SMM=#{@smm}&SDD=#{@sdd}&EYY=#{@eyy}&EMM=#{@emm}&EDD=#{@edd}")   # 크롤러가 접속하게 될 주소.
    html_doc = Nokogiri::HTML(Net::HTTP.get(uri))   # 쉽게, {{ 주소창에 uri(주소)를 get방식으로 넣고 return받은 HTML을 전부 html_doc에 담는다 }} 라는 노코기리 문법.
    
    # 이후 작업은 html_doc에 담아온 HTML문서를 파싱하는 과정
    @result     = html_doc.css("table.board_type1")   # 순위 전체를 담은 테이블(표)를 잘 가져오는가.
    @result1    = html_doc.css("table.board_type1//tr:nth-child(2)")   # 1위에 해당하는 한 행을 잘 뽑아오는가. => 규칙성 확인.
    @result100  = html_doc.css("table.board_type1//tr:nth-child(101)") # 100위에 해당하는 한 행을 잘 뽑아오는가. => 원하는 크롤링 범위의 처음과 끝이 규칙을 가지고 잘 파싱됨을 확인.
    
    # 규칙성을 가진 한 주기(여기서는 순위별로 한개의 행)를 반복문에 넣어 전부 파싱.
    (1..100).to_a.each do |ii|
      i = ii.to_i
      
      # 주석은 코드리뷰를 위한 과거형 코드
      @result_0    = html_doc.css("table.board_type1//tr:nth-child(#{i+1})")    # @result   = html_doc.css("table.board_type1").to_s
      eval("@result#{i}_1 = @result_0.css(\"tr//td:nth-child(1)\").inner_html") # a_rank    = result.css("tr//td:nth-child(1)").inner_html  # a_rank = eval("@result#{i}_1")
      eval("@result#{i}_2 = @result_0.css(\"tr//td:nth-child(2)\").inner_html") # b_songNum = result.css("tr//td:nth-child(2)").inner_html  # b_songNum = eval("@result#{i}_2")
      eval("@result#{i}_3 = @result_0.css(\"tr//td:nth-child(3)\").inner_html") # c_title   = result.css("tr//td:nth-child(3)").inner_html  # c_title = eval("@result#{i}_3")
      eval("@result#{i}_4 = @result_0.css(\"tr//td:nth-child(4)\").inner_html") # d_songBy  = result.css("tr//td:nth-child(4)").inner_html  # d_songBy = eval("@result#{i}_4")
    end
    
  end
  
  def save_daily_popular
    a = DailyTjPopularRank.new
    DailyTjPopularRank.attribute_names.each do |atn|
      next if atn == "id" || atn == "created_at" || atn == "updated_at"
      eval("a.#{atn} = params[:#{atn}]")
    end
    a.save
    
    redirect_to :back
  end
  
  ###############################################################################
  
  def songs_do
    #-----------------------------------------------------------------------------------------------------
    # Setting( Focus.한번에 몇개 긁어올지 - 권장 20개, 장기크롤링 - 100개 )
    ## 언제부터
    if Song.last == nil
      @start_num = 00000001   # 예제) 82425426 번은 악동뮤지션 200% 곡의 넘버임
      last_saved_song_count = Song.count
    else 
      @start_num = Song.last.song_num + 1
      last_saved_song_count = Song.count
    end
    
    
    
    ## 정탐색 갯수 설정(파생탐색 및 탐색 손실은 측정하지 않음)
    how_many_songs_do_you_want = params[:id].to_i
    
    @must_break_id_limit_count = last_saved_song_count + how_many_songs_do_you_want
    # @must_break_id_limit_count = last_saved_song_count + how_many_songs_do_you_want
    #-----------------------------------------------------------------------------------------------------
    
    num = @start_num
    loop do
      
      # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
      uri = URI("http://www.genie.co.kr/detail/songInfo?xgnm=#{num}")   # 크롤러가 접속하게 될 주소.
      html_doc = Nokogiri::HTML(Net::HTTP.get(uri))   # 쉽게, {{ 주소창에 uri(주소)를 get방식으로 넣고 return받은 HTML을 전부 html_doc에 담는다 }} 라는 노코기리 문법.
      
      # 이후 작업은 html_doc에 담아온 HTML문서를 파싱하는 과정
      @result     = html_doc.css("div#body-content")   # [중간테스트] 여기까지는 잘 가져오는가.
      @result1    = html_doc.css("div#body-content//div.info-zone")   # [중간테스트] 여기까지는 잘 가져오는가.
      
      
      @song_title = html_doc.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip!
      
      # @song_title = "제목이 발견되지 않는다"
      if @song_title.length == 0
        num += 1
        next
      end
      
      # @song_title = "제목 있다"
        # 임의로 때려넣은 지니넘버 주소에 노래정보 있는거 확인했으니까 
        # 긁어올거 일단 다 긁어오고나서 저장하자
          
          ###################################
          #**      Song Table Details     **#
          song = Song.new
          # 음원 정보(보통)
          ## title(제목)
            song.title = @song_title
          ## ganre1(장르1)
            @song_ganre1 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').first.to_s
            song.ganre1 = @song_ganre1
          ## ganre2(장르2)
            @song_ganre2 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').last.to_s
            song.ganre2 = @song_ganre2
          ## runtime(재생시간)
            @runtime = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value").inner_html.to_s
            song.runtime = @runtime
          ## lyrics(가사) %% 주 의 %% 가사는 뷰에서 사용할때 <pre><%= @lyrics.html_safe %></pre> 이렇게 출력해야함!
            @lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            song.lyrics = @lyrics
          
          # 음원 정보(참조)
          ## artist_num(아티스트 번호)
            @artist_num = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(1)//span.value//a")[0]['onclick'].to_s.gsub("fnGoMore('artistInfo','","").first(8)
            song.artist_num = @artist_num
          ## album_num(앨범 번호)
            @album_num = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value//a")[0]['onclick'].to_s.gsub("fnGoMore('albumInfo','","").first(8)
            song.album_num = @album_num
          
              #**       Album Table Details    **#
              if Album.where(album_num: @album_num).count == 0
                album = Album.new
                uri_album = URI("http://www.genie.co.kr/detail/albumInfo?axnm=#{@album_num}")   # 크롤러가 접속하게 될 앨범주소.
                html_doc_album = Nokogiri::HTML(Net::HTTP.get(uri_album))
                ## title(앨범제목)
                  @album_title = html_doc_album.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip
                  album.title = @album_title
                ## ganre1(앨범장르1)
                  @album_ganre1 = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value").inner_html.to_s.split(' / ').first.to_s
                  album.ganre1 = @album_ganre1
                ## ganre2(앨범장르2)
                  @album_ganre2 = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value").inner_html.to_s.split(' / ').last.to_s
                  album.ganre2 = @album_ganre2
                ## publisher(발매사)
                  @publisher = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s
                  album.publisher = @publisher
                ## agency(기획사)
                  @agency = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value").inner_html.to_s
                  album.agency = @agency
                ## released_date(발매일)
                  @released_date = html_doc_album.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(5)//span.value").inner_html.to_s
                  album.released_date = @released_date
                ## jacket(앨범자켓 :: 이미지)
                  @jacket = "http:" + html_doc_album.css("div#body-content//div.photo-zone//a")[0]['href'].to_s
                  album.jacket = @jacket
                  
                uri_artist = URI("http://www.genie.co.kr/detail/artistInfo?xxnm=#{@artist_num}")
                html_doc_artist = Nokogiri::HTML(Net::HTTP.get(uri_artist))
                ## artist_num(아티스트 번호)
                  album.artist_num = @artist_num
                ## artist_photo(아티스트 사진)
                  @artist_photo = "http:" + html_doc_artist.css("div#body-content//div.photo-zone//a")[0]['href'].to_s
                  album.artist_photo = @artist_photo
                ## artist_name(아티스트 이름)
                  @artist_name = html_doc_artist.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip
                  album.artist_name = @artist_name
                
                ## album_num(앨범 고유번호)
                  album.album_num = @album_num
                  album.save #아래 앨범아이디 만들려면 먼저저장해야함.
              else
                album = Album.where(album_num: @album_num).take
                @album_title    = album.title
                @album_ganre1   = album.ganre1
                @album_ganre2   = album.ganre2
                @publisher      = album.publisher
                @agency         = album.agency
                @released_date  = album.released_date
                @jacket         = album.jacket
                # @artist_num     = album.artist_num
                @artist_photo   = album.artist_photo
                # @artist_name    = album.artist_name
                # @album_num      = album.album_num
                
              end
              #**                              **#
          
          
          # 음원 정보(참조추출)
          ## artist_photo(아티스트 사진)
            song.artist_photo = @artist_photo
          ## jacket(자켓사진)
            song.jacket = @jacket
          
          # 앨범테이블 릴레이션
          ## album_id(앨범아이디)
            song.album_id = Album.where(album_num: @album_num).take.id
          # 음원 정보(고유값)
          ## song_tjnum(노래방번호 :: 나중에 따로 받아야 할듯)
            song.song_tjnum = nil
          ## song_num(지니뮤직 고뮤번호)
            song.song_num = num
          #**                              **#
          ####################################
          
        # 다 긁었으니까 노래도 마저 저장하자
        song.save
        
        
      break if Song.count >= @must_break_id_limit_count
      # break if num == @must_break_id_limit_count
      break if num >= 82525426
      num += 1
    end
    
    
    
    
    
    
    
    
    
            # @result100  = html_doc.css("table.board_type1//tr:nth-child(101)") # 100위에 해당하는 한 행을 잘 뽑아오는가. => 원하는 크롤링 범위의 처음과 끝이 규칙을 가지고 잘 파싱됨을 확인.
    
    # 규칙성을 가진 한 주기(여기서는 순위별로 한개의 행)를 반복문에 넣어 전부 파싱.
            # (1..100).to_a.each do |ii|
            #   i = ii.to_i
              
            #   # 주석은 코드리뷰를 위한 과거형 코드
            #   @result_0    = html_doc.css("table.board_type1//tr:nth-child(#{i+1})")    # @result   = html_doc.css("table.board_type1").to_s
            #   eval("@result#{i}_1 = @result_0.css(\"tr//td:nth-child(1)\").inner_html") # a_rank    = result.css("tr//td:nth-child(1)").inner_html  # a_rank = eval("@result#{i}_1")
            #   eval("@result#{i}_2 = @result_0.css(\"tr//td:nth-child(2)\").inner_html") # b_songNum = result.css("tr//td:nth-child(2)").inner_html  # b_songNum = eval("@result#{i}_2")
            #   eval("@result#{i}_3 = @result_0.css(\"tr//td:nth-child(3)\").inner_html") # c_title   = result.css("tr//td:nth-child(3)").inner_html  # c_title = eval("@result#{i}_3")
            #   eval("@result#{i}_4 = @result_0.css(\"tr//td:nth-child(4)\").inner_html") # d_songBy  = result.css("tr//td:nth-child(4)").inner_html  # d_songBy = eval("@result#{i}_4")
            # end
    
    # Start debugger
      @message = how_many_songs_do_you_want.to_s + "개 저장완료! 확인하셈!"
    # End debugger
    render layout: false
    puts "요청하신 크롤링이 종료되었습니다."
  end
end
