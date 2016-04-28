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
  
end
