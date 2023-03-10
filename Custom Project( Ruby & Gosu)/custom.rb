require 'gosu'
include Gosu

class Pong < Gosu::Window 
 
   HEIGHT  = 400
   WIDTH = 800
  
  def initialize
     super(WIDTH, HEIGHT)
	 self.caption = "Ping Pong Game"
    @ball = Ball.new(self, WIDTH, HEIGHT)
    @player1 = Player.new(self, 40, HEIGHT/2, 'Player 1')
    @player2 = Player.new(self, WIDTH - 40, HEIGHT/2, 'Player 2')
    @players = [@player1, @player2]
    @winner = nil
    @score_board = ScoreBoard.new(self, WIDTH)
    @background_image = Gosu::Image.new("back.jpg", :tileable => true)
	@state = :stopped
	load_music
  end

  def update
   if @state == :in_play
     if button_down?(KbW) 
         @player1.go_up
     end
     if button_down?(KbS)
       @player1.go_down
     end
     if button_down?(KbK)
       @player2.go_down
     end
     if button_down?(KbI)
       @player2.go_up
     end
     if @player1.strike_ball(@ball)
       @ball.strike_stick(@player1.y - @ball.y)
	   @touch_sound.play
     end
     if @player2.strike_ball(@ball)
       @ball.strike_stick(@player2.y - @ball.y)
	   @touch_sound.play
     end
     if @ball.x < 0
	   @over_sound.play
       @player2._score
       @players.each(&:reset)
       @ball.reset
       @state = :stopped
     end
     if @ball.x > WIDTH
	   @over_sound.play
       @player1._score
       @players.each(&:reset)
       @ball.reset
       @state = :stopped
     end
     if @player1.score == 5
       @winner = @player1
       @state = :ended
     elsif  @player2.score == 5
         @winner = @player2
         @state = :ended
       end
       @ball.update
     elsif @state == :stopped
       if button_down?(KbSpace)
         @state = :in_play
       end
     end
    end
    
	def draw
      @background_image.draw(0, 0, 0)
      if @state == :ended
        @score_board.draw_win(@winner)
      end
      @score_board.draw(@players)
      @player1.draw
      @player2.draw
      @ball.draw
    end

    def load_music
	@touch_sound = Gosu::Sample.new("touch.wav")
	@over_sound = Gosu::Sample.new("over.wav")
    end
   end
  
  class Player

  HEIGHT = 60
  WIDTH = 10

  attr_reader :x
  attr_reader :y
  attr_reader :score
  attr_reader :name

  def initialize(window, x, y, name)
    @window = window
    @init_x = x
    @init_y = y
    @x = x
    @y = y
    @name = name
    @score = 0
   end

  def go_up
    @y -= 6
    @y = [HEIGHT/2, @y].max
  end
  
  def go_down
    @y += 6
    @y = [400 - HEIGHT/2, @y].min
  end

  def strike_ball(ball)
    (@x - ball.x).abs < 4 && (@y - ball.y).abs < 40
  end

  def reset
    @x = @init_x
    @y = @init_y
  end

  def _score
    @score += 1
  end

  def draw
    @window.draw_quad(
               @x - WIDTH/2, @y - HEIGHT/2, Color::BLUE,
               @x + WIDTH/2, @y - HEIGHT/2, Color::BLUE,
               @x + WIDTH/2, @y + HEIGHT/2, Color::BLUE,
               @x - WIDTH/2, @y + HEIGHT/2, Color::BLUE
              )
  end
end


class ScoreBoard
  
  def initialize(window, width)
    @window = window
    @width = width - 125
    @width2 = width - 250
    @font = Font.new(window, 'Arial', 60)
    @font2 = Font.new(window, 'Arial', 40)
  end

  def draw(players)
    @font.draw_text("#{players.map(&:score).join(' - ')}", @width/2 , 20, 0)
  end

  def draw_win(player)
     @font2.draw_text("#{player.name} has won!", @width2/2 , 300, 0)
  end
 end
 
  class Ball

  attr_accessor :x, :y

  def initialize(window, x, y)
    @window = window
    @init_y = y/2
    @init_x = x/2
    reset
    @vy = 0
    @vx = 8
  end

  def update
    @x += @vx
    @y += @vy
    if @y > 400 || @y < 0
      @vy *= -1
    end
   end

  def draw
    @window.draw_quad(
        @x -4, @y -4, Gosu::Color::RED,
        @x -4, @y +4, Gosu::Color::RED,
        @x +4, @y -4, Gosu::Color::RED,
        @x +4, @y +4, Gosu::Color::RED
        )

  end
  
  def strike_stick(merging_point)
    @vx *= -1
    @vy += merging_point / 10
  end

  def reset
    @x = @init_x
    @y = @init_y
    @vx = 10
    @vy = 0
  end
 end


Pong.new.show
