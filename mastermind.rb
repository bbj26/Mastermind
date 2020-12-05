module MastermindFunctions
  def showWelcomeScreen
    puts "        M A S T E R M I N D       "
    puts ""
    puts "Mastermind is a game where you have to guess your opponent’s secret 4 digit code within a 12 turns"
    puts "Each turn you get some feedback about how good your guess was – whether it was exactly correct or just the correct digit but in the wrong space."
    puts " -> ¤ <- means correct digit and position"
    puts " -> * <- means correct digit but wrong position"
    puts " -> - <- means wrong guess"
    puts ""
    puts "Let's start! Good luck!"
    puts ""
  end

  def choice
    puts "Select game mode"
    puts "1. Player trying to guess computer's secret code"
    puts "2. Player generates secret code and computer trying to guess it"
    choice = ""
    puts ""
    print "Select game mode: "
    choice = gets.chomp.to_i
    until choice == 1 || choice == 2 do
      puts ""
      print "Please chose 1 or 2: "
      choice = gets.chomp.to_i
    end
    choice
  end

  def checkForwardDigitsToIgnore(currIndex, guesss, code)
    guess_digits_map = Hash.new(0)
    code_digits_map = Hash.new(0)
    guess_digits_to_ignore = Hash.new(0)

    #count how many of each number the secret code and guess have
    code.each {|num| code_digits_map[num] += 1} 
    guesss.each {|num| guess_digits_map[num] += 1}
    
    #count how many repeating values in guess needs to be ignored
    guess_digits_map.each {|gkey, gvalue|
      code_digits_map.each {|ckey, cvalue|
        if gkey == ckey && gvalue > cvalue
          guess_digits_to_ignore[gkey] += 1
        end
      }
    }

    if guess_digits_to_ignore[guesss[currIndex]] == nil 
      return 0
    else
      return guess_digits_to_ignore[guesss[currIndex]]
    end
  end

  def feedback(guesss, code, comp_flag = 1)
    #puts "šifra je #{code}"
    feedback = Array.new(4)
    code_digits = Hash.new(0)
    code.each {|num| code_digits[num] = code.count(num)}
    no_of_same_digits_forward_to_ignore = 0
    if (guesss === code)
      #puts "Congratulations, you guessed the secret code: #{code}"
      return 1
    end

    guesss.each_with_index { |num, indexx|
      if code.include?(num)
        if num == code[indexx]
          feedback.push(" ¤ ")
        else
          no_of_same_digits_forward_to_ignore = checkForwardDigitsToIgnore(indexx, guesss, code)
          if  no_of_same_digits_forward_to_ignore == 0
            feedback.push(" * ")
          else
            feedback.push(" - ")
            no_of_same_digits_forward_to_ignore -= 1
          end
        end
      else
        feedback.push(" - ")
      end
    }
    #if computer is guessing players code, return feedback to comp
    if comp_flag == 1
      return feedback 
    end
    puts ""
    puts feedback.join
    puts ""
  end
end

class Computer
  include MastermindFunctions
  def generateCode
    code = Array.new(4)
    code.map! {|num| num = rand(0..9)}
  end

  def compGuessCode(last_guess = nil, feedback = nil)
    feedback.delete_if {|item| item == nil}
    code = Array.new(4) ##comp guess
    ok_indexes = Array.new(4) 
    wrong_guesses = Array.new

    code.map! {|num|
      num = rand(0..9)
      while wrong_guesses.none? {|n| n == num} == false
        num = rand(0..9)
      end
      num
    }
    
    #puts "my last guess was #{last_guess}"
    #puts "i have gotten this feedback: #{feedback}"
    feedback.each_with_index {|value, index|
      if value == " ¤ "
        code[index] = last_guess[index]
        ok_indexes[index] = index
      elsif value == " * "
        new_index = ok_indexes.find_index {|val|
          val == nil
        }
        code[new_index] = last_guess[index]
      elsif value == " - "
        wrong_guesses.push(value)
      end        
    }
    return code
  end
end

class Player < Computer
  attr_accessor :secret_code, :name
  def initialize
    print "Enter your name: "
    name = gets.chomp
    @name = name
  end

  def code
    self.secret_code
  end

  def generate
    self.generateCode
  end

  def guess
    self.guessCode
  end

  private

  @secret_code = Array.new

  def guessCode
    puts ""
    print "Guess computer's secret code: "
    guess = gets.chomp
    until (guess.length == 4 && guess.split("").all? {|num| num == num.to_i.to_s || num == num.to_f.to_s}) do
      puts ""
      print "Please enter 4 numbers, 0-9: "
      guess = gets.chomp
    end
    #puts "your guess is: "
    guess = guess.split("").map! {|num| num.to_i}
    self.secret_code = guess
  end

  def generateCode
    print "\nEnter your secret code (4 digits, 0-9): "
    code = gets.chomp
    until (code.length == 4 && code.split("").all? {|num| num == num.to_i.to_s || num == num.to_f.to_s}) do
      puts "Please enter 4 valid numbers between 0 and 9. Do not enter spaces between numbers."
      code = gets.chomp
    end
    code = code.split("").map! {|num| num.to_i}
    self.secret_code = code
    #puts " your secret code is: #{self.secret_code}"
    self.secret_code
  end
end

class Mastermind
  include MastermindFunctions
  attr_accessor :game_ended
  @@game_ended = false;
  
  def play
    self.showWelcomeScreen 
    if self.choice == 1 
      self.playerGuessingMode
    else
      self.computerGuess
    end
  end

  def playerGuessingMode
    self.playerGuess
  end

  private

  def computerGuess
    comp = Computer.new
    #comp.showWelcomeScreen
    plr = Player.new
    plr_secret_code = plr.generate
    puts "#{plr.name}'s secret code is: #{plr_secret_code}"    
    feedback = []
    last_guess = []
    i = 0
    12.times do
      print "Round #{i}: "
      i = i + 1
      print "Computer guessing..."
      sleep(3)

      if @@game_ended == false
        comp_guess = comp.compGuessCode(last_guess, feedback)
        last_guess = comp_guess
        puts "Computer guess is: #{comp_guess}"
        feedback = plr.feedback(comp_guess, plr_secret_code)
        if feedback == 1
          @@game_ended = true
          break
        end
      end
    end
    if @@game_ended == false
      puts "Congratulations #{plr.name}, you won! Computer failed to guess your secret code: #{plr_secret_code}."
      puts "Game over!"
    end
  end

  def playerGuess
    comp = Computer.new
    #comp.showWelcomeScreen
    #choice = comp.choice
    plr = Player.new
    sifra = comp.generateCode
    i = 1  
    12.times do 
      if @@game_ended == false 
        print "Round #{i}: "
        i = i + 1      
        mozda = plr.guess
        if (comp.feedback(mozda, sifra, 0) == 1)
          puts "Congratulations #{plr.name}, you won by successfully guessing computer's secret code: #{sifra}"
          @@game_ended = true
          break
        end  
      end
    end
    if @@game_ended == false
      puts "Game over!"
      puts "Unfortunately, you failed to guess computer's secret code: #{sifra}."
      puts "Computer won!"
    end
  end
end

newGame = Mastermind.new
newGame.play

