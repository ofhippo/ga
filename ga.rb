require './game.rb'
require './player.rb'
class GA
  SELECTION = :tournament || :roulette
  NUM_PLAYERS = 100
  ELITISM_SURVIVORS = 10
  NUM_GAMES_PER_GENERATION = 1
  TOURNAMENT_SIZE = 10
  TOURNAMENT_PREFERS_FITTER_P = 0.9
  MUTATION_RATE = 0.04

  REPORT_INTERVAL = 10

  QBF = "the quick brown fox jumps over the lazy dog"

  def go
    @gen_num = 0
    @players = NUM_PLAYERS.times.map{ Player.new }
    assign_fitness
    until best_decode == QBF
      report if (@gen_num % REPORT_INTERVAL == 0)
      breed
      @gen_num += 1
      assign_fitness
    end
    puts
    report
  end
  alias :run :go

  def report
    puts "Gen #{@gen_num}"
    puts "max: #{max_fitness}"
    puts "avg: #{avg_fitness}"
    puts "std: #{std_fitness}"
    puts "best: #{best_decode}"
  end

  def fitnesses
    @players.map(&:fitness)
  end

  def best_decode
    g = Game.new(QBF)
    p = best_player
    p.decode(g.question)
  end

  def best_player
     @players.max_by(&:fitness)
  end

  def max_fitness
    fitnesses.max rescue 0
  end

  def avg_fitness
    fitnesses.inject(&:+) / @players.size
  end

  def std_fitness
    mean = avg_fitness

    sum = 0
    fitnesses.
      each do |x|
        sum += (x - mean)**2
      end
    sum ** 0.5
  end

  def players
    @players
  end

  def assign_fitness
    games = NUM_GAMES_PER_GENERATION.times.map{ Game.new}#(') }
    @players.each do |p|
              sum = 0
              games.each do |g|
                     sum += g.guess(p.decode(g.question))
                   end
              p.fitness = sum.to_f / games.size
            end
  end

  def breed
    case SELECTION
    when :tournament
      tournament_for_parents
    when :roulette
      roulette_for_parents
    else
      raise "Wat SELECTION?"
    end
    old_count = @players.size
    if ELITISM_SURVIVORS == 0
      @players = crossover_breed
    else
      @players = crossover_breed(@players.size - ELITISM_SURVIVORS) + @players.sort_by(&:fitness).reverse[0...ELITISM_SURVIVORS]
    end
    raise "# of players changed: old: #{old_count} new: #{@players.size}" unless @players.size == old_count
    mutate_players
  end

  def tournament_for_parents
    @parents = NUM_PLAYERS.times.
               map do
                 competitors = TOURNAMENT_SIZE.times.map{ @players[rand(@players.size)] }
                 if (rand(1000) / 1000.0 < TOURNAMENT_PREFERS_FITTER_P)
                   competitors.max_by(&:fitness)
                 else
                   competitors[rand(competitors.size)]
                 end
               end
  end

  def roulette_for_parents
    t = @players.map(&:fitness).inject(&:+)
    results = []
    @players.size.times do |i|
                   sum = 0
                   goal = rand((t * 10000).to_i) / 10000.to_f
                   @players.each do |p|
                             sum += p.fitness
                             if sum > goal
                               results << p
                               break
                             end
                           end
                 end
    @parents = results
  end

  def crossover_breed(num_breeders = nil)
    if num_breeders.nil?
      parents = @parents
    else
      parents = @parents.shuffle[0...num_breeders]
    end
 
    parents.map do |parent|
             crossover(parent, parents[rand(parents.size)])
           end
  end

  def crossover(p1, p2)
    s1 = p1.strategy
    s2 = p2.strategy
    i = rand(s1.size)
    s = s1[0...i] + s2[i..s1.size]
    raise "strategy fail" unless s.size == s2.size && s1.size == s2.size
    Player.new(s)
  end
  
  def mutate_players
    @players = @players.each{|p| mutate(p) }
  end

  def mutate(p)
    p.strategy = p.strategy.split("").map{|x| rand(10000) / 10000.0 < MUTATION_RATE ? ("a".."z").to_a[rand(26)] : x }.join
  end
end
