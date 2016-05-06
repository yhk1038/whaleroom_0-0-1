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
      @start_num = 79999991   # 예제) 82425426 번은 악동뮤지션 200% 곡의 넘버임
    else
      # @start_num = 79999991
      @start_num = Song.last.song_num + 1
    end
    last_saved_song_count = Song.count
    
    
    ## 정탐색 갯수 설정(파생탐색 및 탐색 손실은 측정하지 않음)
    if params[:id].nil?
      how_many_songs_do_you_want = 1000                 # 갯수 지정 안할 시 기본값 1천개(예상 소요시간: 5분)
    else
      how_many_songs_do_you_want = params[:id].to_i     # 지정된 갯수대로 크롤링(속도: 100여개/30초, 200여개/분, 2천여개/10분)
    end
    
    @must_break_id_limit_count = last_saved_song_count + how_many_songs_do_you_want
    # @must_break_id_limit_count = last_saved_song_count + how_many_songs_do_you_want
    #-----------------------------------------------------------------------------------------------------
    
    num = @start_num
    loop do
      if Song.where(song_num: num).take.present?
        num += 1
        next
      end
      
      # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
      uri = URI("http://www.genie.co.kr/detail/songInfo?xgnm=#{num}")   # 크롤러가 접속하게 될 주소.
      html_doc = Nokogiri::HTML(Net::HTTP.get(uri))   # 쉽게, {{ 주소창에 uri(주소)를 get방식으로 넣고 return받은 HTML을 전부 html_doc에 담는다 }} 라는 노코기리 문법.
      
      # 이후 작업은 html_doc에 담아온 HTML문서를 파싱하는 과정
      @result     = html_doc.css("div#body-content")   # [중간테스트] 여기까지는 잘 가져오는가.
      @result1    = html_doc.css("div#body-content//div.info-zone")   # [중간테스트] 여기까지는 잘 가져오는가.
      
      
      @song_title = html_doc.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip!
      @song_ganre1 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').first.to_s
      @song_ganre2 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').last.to_s
      
      # 다음 상황에서는 루프를 스킵한다.
        # =>유형1. @song_title = "제목이 발견되지 않는다"
        if @song_title.length == 0  
          num += 1
          next
        end
        
        # =>유형2. @song_ganre1 == "CCM"
        # =>유형3. @song_ganre1 == "클래식"<<>
        if @song_ganre1 == "CCM" || @song_ganre1 == "클래식"
          num += 1
          next
        end
        
        # =>유형4. @song_ganre2 == "불교음악"
        # =>유형5. @song_ganre2 == "뮤직테라피"
        # =>유형6. @song_ganre2 == "뉴에이지"
        if @song_ganre2 == "불교음악" || @song_ganre2 == "뮤직테라피" || @song_ganre2 == "뉴에이지"
          num += 1
          next
        end
      
      
      # 루프가 스킵 되지 않았다면 본격적으로 데이터를 작성하자.
        # 임의로 때려넣은 지니넘버 주소에 노래정보 있는거 확인했으니까 
        # 긁어올거 일단 다 긁어오고나서 저장하자
          
          ###################################
          #**      Song Table Details     **#
          song = Song.new
          # 음원 정보(보통)
          ## title(제목)
            song.title = @song_title
          ## ganre1(장르1)
            song.ganre1 = @song_ganre1
          ## ganre2(장르2)
            song.ganre2 = @song_ganre2
          ## runtime(재생시간)
            @runtime = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value").inner_html.to_s
            song.runtime = @runtime
          ## lyrics(가사) %% 주 의 %% 가사는 뷰에서 사용할때 <pre><%= @lyrics.html_safe %></pre> 이렇게 출력해야함!
            @lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            song.lyrics = @lyrics
          ## songwriter(작사)
            #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            #song.lyrics = @lyrics
          ## composer(작곡)
            #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            #song.lyrics = @lyrics
          
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
      break if num >= 83525426
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
  
  
  def songs_rematch_for_correct_album # =>노래와 앨범이 다시 제대로 매치시켜주는 함수
    
    @song = Song.all
    unmathed_song = Array.new
    
    @song.each do |song|                                                # 일단 노래를 다 돌린다.
      if Album.where(id: song.album_id).count == 0                      # 이 노래가 앨범을 못찾고있는지?
        unmathed_song << song                                               # 그럼 문제있는놈.
      else                                                              # 앨범찾으면 1차 통과.
      
        if Album.find(song.album_id).album_num != song.album_num        # 찾은 앨범이 안맞는 앨범인지?
          unmathed_song << song                                             # 그럼 문제있는놈.
        end                                                             # 끝
      
      end
    end
    
    i = 1
    unmathed_song.each do |x|
      x.album_id = Album.where(album_num: x.album_num).take.id
      x.save
      i += 1
    end
    
    puts "#{i.to_s}개의 노래가 수정되었습니다"
  end
  
  def data_filler # =>존재하는 데이터에 빵꾸를 메꿔줌
    
    songs_array_what_needs_filler = Array.new
    @filled_songs_array = Array.new
    @filled_songs_array2 = Array.new
    @filled_albums_array = Array.new
    @filled_albums_array2 = Array.new
    
    all_songs = Song.all
    all_songs.each do |xsong|
      Song.attribute_names.each do |column|
        next if column == "id" || column == "lowkey" || column == "songwriter" || column == "composer" || column == "highkey" || column == "created_at" || column == "updated_at"
        if eval("xsong.#{column}") == nil
          songs_array_what_needs_filler << xsong
        end
      end
    end
    
    songs_array_what_needs_filler.each do |song|
      
      # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
      uri = URI("http://www.genie.co.kr/detail/songInfo?xgnm=#{song.song_num}")   # 크롤러가 접속하게 될 주소.
      html_doc = Nokogiri::HTML(Net::HTTP.get(uri))   # 쉽게, {{ 주소창에 uri(주소)를 get방식으로 넣고 return받은 HTML을 전부 html_doc에 담는다 }} 라는 노코기리 문법.
      
      # 이후 작업은 html_doc에 담아온 HTML문서를 파싱하는 과정
      @result     = html_doc.css("div#body-content")   # [중간테스트] 여기까지는 잘 가져오는가.
      @result1    = html_doc.css("div#body-content//div.info-zone")   # [중간테스트] 여기까지는 잘 가져오는가.
      
      
      @song_title = html_doc.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip!
        # 앨범번호 에러시 루프 스킵
          # =>0. Error @album_num == nil
          guess_error = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value//a")[0]
          if guess_error.nil?
            @filled_songs_array2 << song
            next
          end
      @song_ganre1 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').first.to_s
      @song_ganre2 = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value").inner_html.to_s.split(' / ').last.to_s
      
      # 다음 상황에서는 루프를 스킵한다.
        # =>1. @song_title = "제목이 발견되지 않는다"
        if @song_title.length == 0  
          
          next
        end
        
        # =>2. @song_ganre1 == "CCM"
        # =>3. @song_ganre1 == "클래식"
        if @song_ganre1 == "CCM" || @song_ganre1 == "클래식"
          
          next
        end
        
        # =>4. @song_ganre2 == "불교음악"
        # =>5. @song_ganre2 == "뮤직테라피"
        # =>6. @song_ganre2 == "뉴에이지"
        if @song_ganre2 == "불교음악" || @song_ganre2 == "뮤직테라피" || @song_ganre2 == "뉴에이지"
          
          next
        end
      
      
      # 루프가 스킵 되지 않았다면 본격적으로 데이터를 작성하자.
        # 임의로 때려넣은 지니넘버 주소에 노래정보 있는거 확인했으니까 
        # 긁어올거 일단 다 긁어오고나서 저장하자
          
          ###################################
          #**      Song Table Details     **#
          
          # 음원 정보(보통)
          ## title(제목)
            song.title = @song_title
          ## ganre1(장르1)
            song.ganre1 = @song_ganre1
          ## ganre2(장르2)
            song.ganre2 = @song_ganre2
          ## runtime(재생시간)
            @runtime = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(4)//span.value").inner_html.to_s
            song.runtime = @runtime
          ## lyrics(가사) %% 주 의 %% 가사는 뷰에서 사용할때 <pre><%= @lyrics.html_safe %></pre> 이렇게 출력해야함!
            @lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            song.lyrics = @lyrics
          ## songwriter(작사)
            #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            #song.lyrics = @lyrics
          ## composer(작곡)
            #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            #song.lyrics = @lyrics
          
          # 음원 정보(참조)
          ## artist_num(아티스트 번호)
            @artist_num = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(1)//span.value//a")[0]['onclick'].to_s.gsub("fnGoMore('artistInfo','","").first(8)
            song.artist_num = @artist_num
            puts "#{@song_title}, #{song.song_num}"
          ## album_num(앨범 번호)
            @album_num = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(2)//span.value//a")[0]['onclick'].to_s.gsub("fnGoMore('albumInfo','","").first(8)
            song.album_num = @album_num
          
              #**       Album Table Details    **#
              # if Album.where(album_num: @album_num).count == 0
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
          
          #기타
          ## songwriter(작사)
            song.songwriter = nil
          ## composer(작곡)
            song.composer = nil
          #**                              **#
          ####################################
          
        # 다 긁었으니까 노래도 마저 저장하자
        song.save
        
        @filled_songs_array << song
        @filled_albums_array << album
      
    end
    
    @filled_songs_array2.each do |song2|
       
      # 타겟 문서 가져오기(속칭 긁어오기 또는 크롤링)
      uri = URI("http://www.genie.co.kr/detail/songInfo?xgnm=#{song2.song_num}")   # 크롤러가 접속하게 될 주소.
      html_doc = Nokogiri::HTML(Net::HTTP.get(uri))   # 쉽게, {{ 주소창에 uri(주소)를 get방식으로 넣고 return받은 HTML을 전부 html_doc에 담는다 }} 라는 노코기리 문법.
      
      # 이후 작업은 html_doc에 담아온 HTML문서를 파싱하는 과정
      @result     = html_doc.css("div#body-content")   # [중간테스트] 여기까지는 잘 가져오는가.
      @result1    = html_doc.css("div#body-content//div.info-zone")   # [중간테스트] 여기까지는 잘 가져오는가.
      
      
      @song_title = html_doc.css("div#body-content//div.info-zone//h2.name").inner_html.to_s.strip!
        # 앨범번호 에러시 루프 스킵
          # =>0. Error @album_num == nil
          puts "여기까진 잘 왔다. #{song2.title}, #{song2.song_num}"
          guess_error = html_doc.css("div#body-content//div.info-zone//ul.info-data//li//span.value").to_s.split('</span>') #@guess_error = html_doc.css("div#body-content//div.info-zone//ul.info-data//li:nth-child(3)//span.value//a")[0]['onclick'].gsub("fnGoMore('albumInfo','","").first(8)
          
      @song_ganre1 = guess_error[2].gsub('<span class="value">','').split(' / ').first.to_s
      @song_ganre2 = guess_error[2].gsub('<span class="value">','').split(' / ').last.to_s
      
      # 다음 상황에서는 루프를 스킵한다.
        # =>1. @song_title = "제목이 발견되지 않는다"
        if @song_title.length == 0  
          
          next
        end
        
        # =>2. @song_ganre1 == "CCM"
        # =>3. @song_ganre1 == "클래식"
        if @song_ganre1 == "CCM" || @song_ganre1 == "클래식"
          
          next
        end
        
        # =>4. @song_ganre2 == "불교음악"
        # =>5. @song_ganre2 == "뮤직테라피"
        # =>6. @song_ganre2 == "뉴에이지"
        if @song_ganre2 == "불교음악" || @song_ganre2 == "뮤직테라피" || @song_ganre2 == "뉴에이지"
          
          next
        end
      
      
      # 루프가 스킵 되지 않았다면 본격적으로 데이터를 작성하자.
        # 임의로 때려넣은 지니넘버 주소에 노래정보 있는거 확인했으니까 
        # 긁어올거 일단 다 긁어오고나서 저장하자
          
          ###################################
          #**      Song Table Details     **#
          
          # 음원 정보(보통)
          ## title(제목)
            song2.title = @song_title
          ## ganre1(장르1)
            song2.ganre1 = @song_ganre1
          ## ganre2(장르2)
            song2.ganre2 = @song_ganre2
          ## runtime(재생시간)
            @runtime = guess_error[3].gsub('<span class="value">','').to_s
            song2.runtime = @runtime
          ## lyrics(가사) %% 주 의 %% 가사는 뷰에서 사용할때 <pre><%= @lyrics.html_safe %></pre> 이렇게 출력해야함!
            @lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            song2.lyrics = @lyrics
          ## songwriter(작사)
            #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            #song.lyrics = @lyrics
          ## composer(작곡)
            #@lyrics = html_doc.css("div#body-content//div.lyrics-area//div.tit-box//pre").inner_html.to_s
            #song.lyrics = @lyrics
          
          # 음원 정보(참조)
          ## artist_num(아티스트 번호)
            @artist_num = guess_error.first.gsub('<a href="#" onclick="fnGoMore(\'artistInfo\',\'' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
            song2.artist_num = @artist_num
            puts "#{@song_title}, #{song2.song_num}"
          ## album_num(앨범 번호)
            @album_num = guess_error.second.gsub('<a href="#" onclick="fnGoMore(\'albumInfo\',\'' , '/////').gsub('\');return false;">' , '/////').split('/////')[1].to_i
            song2.album_num = @album_num
          
              #**       Album Table Details    **#
              # if Album.where(album_num: @album_num).count == 0
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
            song2.artist_photo = @artist_photo
          ## jacket(자켓사진)
            song2.jacket = @jacket
          
          # 앨범테이블 릴레이션
          ## album_id(앨범아이디)
            song2.album_id = Album.where(album_num: @album_num).take.id
          # 음원 정보(고유값)
          
          #기타
          ## songwriter(작사)
            song2.songwriter = nil
          ## composer(작곡)
            song2.composer = nil
          #**                              **#
          ####################################
          
        # 다 긁었으니까 노래도 마저 저장하자
        song2.save
        
        @filled_songs_array << song2
        @filled_albums_array << album
        
    end
    
    render layout: false
  end
  
  
  
  def tj_linker
    
    @query = Array.new
    
    
    strText = @query
    "http://www.tjmedia.co.kr/tjsong/song_search_list.asp?strType=0&strText=#{strText}&strCond=0&strSize01=100&strSize02=15&strSize03=15&strSize04=15&strSize05=15"
  end
end
